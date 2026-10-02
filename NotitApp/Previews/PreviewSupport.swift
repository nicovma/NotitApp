import Foundation
import SwiftData

#if DEBUG
extension CompositionRoot {
    /// In-memory store shared by every `#Preview`, so Views never import
    /// SwiftData themselves. Held in a static so the container outlives the
    /// `ModelContext` handed to the root (see ARCHITECTURE.md §3 on retention).
    /// `try!` is acceptable here: previews only, and an in-memory container
    /// for these two models can't fail unless the schema itself is broken.
    private static let previewContainer = try! ModelContainer(
        for: Note.self, Category.self,
        configurations: .init(isStoredInMemoryOnly: true)
    )

    static func preview() -> CompositionRoot {
        CompositionRoot(modelContext: previewContainer.mainContext)
    }
}
#endif
