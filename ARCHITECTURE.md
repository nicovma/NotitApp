# Architecture

## 1. Overview

NotitApp is a note-taking app with color-coded categories, built with SwiftUI, SwiftData, and Swift Concurrency. Notes and categories are fully local (no login, no network), and each note can optionally get an on-device AI-generated title/category suggestion via Apple Intelligence (FoundationModels) as the user types. The app is structured as a strict Clean Architecture split — View / ViewModel / UseCase / Repository — with a custom "Liquid Glass" design system layered independently on top.

## 2. Layers & data flow

```
View ── ViewModel ── UseCase ── Repository ── SwiftData (ModelContext)
```

- **View** (`NotitApp/Views`) — SwiftUI, no business logic. Reads a `ViewModelState<T>` and renders it.
- **ViewModel** (`NotitApp/ViewModels`) — `@MainActor` `ObservableObject`s. Own form state (`@Published var title`, `canSave`, etc.) and orchestrate calls to one or more UseCases.
- **UseCase** (`NotitApp/UseCases`) — thin protocols (`NoteUseCase`, `CategoryUseCase`, `NoteSuggestionUseCase`) with `Default*` implementations. This is the layer ViewModels depend on for testability: a mock UseCase lets a ViewModel test run with no persistence and no model access at all.
- **Repository** (`NotitApp/Repositories`) — the only layer that talks to SwiftData. `SwiftDataNoteRepository` / `SwiftDataCategoryRepository` wrap a `ModelContext` and expose plain `async throws` CRUD methods behind `NoteRepository`/`CategoryRepository` protocols.
- **`CompositionRoot`** — see §3.

### End-to-end flow: creating a note

```
AddNoteView
  → AddNoteViewModel.createNote()
    → NoteUseCase.add(_:)              (protocol)
      → DefaultNoteUseCase.add(_:)      (implementation)
        → NoteRepository.save(_:)       (protocol)
          → SwiftDataNoteRepository.save(_:)
            → ModelContext.insert(note) + ModelContext.save()
```

`AddNoteViewModel.createNote()` first validates locally (non-empty title, a category selected — see `canSave`) before ever reaching the UseCase. On success it sets `didSave = true`, which `AddNoteView` observes via `.onChange` to dismiss the sheet.

### End-to-end flow: AI note suggestions

```
AddNoteView (TextEditor onChange)
  → AddNoteViewModel.valueDidChange()        debounces 1s, needs isAvailable + ≥15 chars
    → AddNoteViewModel.requestSuggestion()
      → NoteSuggestionUseCase.suggest(...)                 (protocol)
        → DefaultNoteSuggestionUseCase.suggest(...)         (implementation)
          → LanguageModelSession (FoundationModels / SystemLanguageModel)
            → NoteSuggestion (@Generable struct: title, categoryName, isNewCategory)
      ← published to `suggestion` / `suggestedCategory`, rendered as SuggestionBanner
```

The suggestion is never applied automatically — `SuggestionBanner` (`Views/Components/AISuggestionBanner.swift`) renders it as two tappable chips ("Título" / "Categoría"), and the user explicitly accepts each one (`applySuggestedTitle()` / `applySuggestedCategory()`).

## 3. Key design decisions

### `CompositionRoot` as the only SwiftData importer outside Repository

`CompositionRoot.swift` is the single place that wires a concrete `ModelContext` into concrete `SwiftData*Repository` instances, then into `Default*UseCase`s, then into ViewModels (`makeAddNoteViewModel()`, `makeEditCategoryViewModel(for:)`, etc.). No View or ViewModel ever imports `SwiftData` or sees a `ModelContext`/`ModelContainer` directly — they only see protocol types (`NoteUseCase`, `CategoryUseCase`...). This is Dependency Inversion enforced structurally, not just by convention: swapping SwiftData for another persistence mechanism would touch `CompositionRoot` and the `Repositories/Implementations` folder only. It also means a ViewModel unit test never needs a `ModelContainer` at all — only `SwiftDataRepositoryTests` does.

**Alternative considered:** a global/singleton container accessed directly from ViewModels. Rejected — it collapses the dependency direction (ViewModels would import SwiftData) and makes every ViewModel test either need a real container or a protocol seam bolted on after the fact.

### `ModelContainer` retention (the SwiftData dangling-context bug)

A `ModelContext` does **not** hold a strong reference to the `ModelContainer` that created it. If a helper does something like:

```swift
func makeInMemoryContext() -> ModelContext {
    let container = try! ModelContainer(for: Note.self, configurations: .init(isStoredInMemoryOnly: true))
    return container.mainContext   // container has no other owner past this line
}
```

the `container` local variable goes out of scope the moment the function returns. Nothing else retains it — the returned `ModelContext` internally references storage owned by that container, but that reference isn't a *retaining* one. The container is deallocated, and the context is left pointing at torn-down storage. This doesn't crash at the call site; it crashes **later**, deterministically, on the first `context.save()` or `context.fetch()`, which makes it read like an unrelated, intermittent SwiftData bug if you don't know to look for it.

The fix used throughout this codebase (`SwiftDataRepositoryTests.makeContainer()`, and every production path via `CompositionRoot`) is to keep the `ModelContainer` alive for exactly as long as anything derived from its context is in use — a local `let container = try makeContainer()` at the top of each test, held for the test's duration, or `CompositionRoot` holding the app's single `ModelContext` (created from a container that's retained by `NotitAppApp`) for the app's lifetime. Never return only a `ModelContext` from a function that locally constructed the `ModelContainer` and lets it fall out of scope.

### Shared `NavigationPath` via `Binding`, not nested `NavigationStack`s

`CategoriesListView` owns a single `@State private var path = NavigationPath()` and passes it down as a `Binding` to `CategoryNotesListView`, which pushes further (`path.append(note)`) onto that *same* stack rather than opening its own nested `NavigationStack`.

**Anti-pattern avoided:** nesting a second `NavigationStack` inside a pushed destination. Two nested stacks each maintain independent navigation state and independent back-gesture/toolbar behavior; in practice this produces double navigation bars, a back button that doesn't do what the visual hierarchy implies, and deep links / programmatic pops that only work as they are wired for a single flat stack. Sharing one `NavigationPath` by `Binding` keeps "notes list → category → notes-in-category → note detail" as one coherent stack with one predictable back stack, at the cost of the intermediate view needing to accept and forward a `Binding<NavigationPath>` instead of being fully self-contained.

### Silent catch in `requestSuggestion`

```swift
} catch {
    // The suggestion is a bonus, not a requirement — the manual
    // flow keeps working untouched if the model fails.
    logger.debug("Suggestion request failed: \(error.localizedDescription)")
}
```

This catch intentionally never surfaces to the UI (no `errorMessage`, no alert). Product decision: the AI suggestion is a convenience layered on top of a fully-functional manual flow (type a title, pick a category yourself) — a `SystemLanguageModel` failure (model not ready, device ineligible, a generation error) is expected and recoverable by just... not using the suggestion. Surfacing it as a user-facing error would turn a bonus feature's hiccup into a false alarm about note-saving, which is the one thing that must never look broken. The failure is still not thrown away silently at the engineering level — it's logged at `.debug` via `os.log`'s `Logger` (subsystem `nicovma.NotitApp`, category `AISuggestion`) so it's inspectable in Console.app / Xcode's log stream while debugging, without ever reaching product surface.

## 4. Testing strategy

- **ViewModels** (`NotitAppTests/*ViewModelTests.swift`) — tested against mock UseCases (`Mocks/Mock*UseCase.swift`, `#if DEBUG`-only) and throwing stub UseCases (`TestDoubles.swift`). Covers validation rules (`canSave`, empty title/name), success paths (state transitions to `.loaded`, `didSave`), and error paths (state transitions to `.error`, `errorMessage` set) — all without touching SwiftData.
- **Repositories** (`SwiftDataRepositoryTests.swift`) — the one integration suite: real `SwiftDataNoteRepository`/`SwiftDataCategoryRepository` against a real, in-memory `ModelContainer` (see §3's retention note for why the container is captured in a local `let` for the test's duration). This is deliberately the only place SwiftData itself is exercised — every other layer treats persistence as an opaque protocol.
- **Not tested**: Views (no snapshot/UI tests), the "Liquid Glass" design system components, and `DefaultNoteSuggestionUseCase`'s actual call into `FoundationModels`/`SystemLanguageModel` — there's no seam to fake Apple's on-device model, and CI runners aren't guaranteed to have Apple Intelligence available (see §5). `AddNoteViewModel`'s suggestion-handling logic *is* tested, via `MockNoteSuggestionUseCase`/`ThrowingNoteSuggestionUseCase` — only the real model call itself is out of scope.

## 5. Known trade-offs

- **AI suggestions require real Apple Intelligence support** — an eligible device/simulator, Apple Intelligence enabled in Settings, and the model in a ready state. `NoteSuggestionUseCase.isAvailable`/`unavailableReason` surface this gracefully in the UI, but it means the feature is simply invisible (with an explanatory hint) on a large slice of real-world devices, and can't be exercised by CI at all.
- **No pagination** — `fetchAll()`/`fetch(byCategory:)` load every note into memory. Fine at personal-notes-app scale; would need to change for a large dataset.
- **No conflict handling on concurrent edits** — SwiftData's `ModelContext` here is single, main-actor-bound, and the app has no multi-window/multi-device sync story, so last-write-wins isn't a scenario that's been designed against.
- **`CompositionRoot` builds a fresh UseCase (and Repository) per ViewModel** — cheap (they're stateless wrappers over one shared `ModelContext`), but it does mean there's no caching layer between a Repository call and SwiftData; every `fetch()` is a real query.
