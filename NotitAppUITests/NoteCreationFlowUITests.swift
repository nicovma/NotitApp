//
//  NoteCreationFlowUITests.swift
//  NotitAppUITests
//
import XCTest

final class NoteCreationFlowUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testEmptyStateShownOnLaunch() {
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["notes.emptyState"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["notes.addButton"].exists)
    }

    /// End-to-end: empty app -> new note -> new category inline -> AI
    /// suggestion (best-effort, on-device model may be unavailable on the CI
    /// runner) -> save -> exactly one note shows up in the list.
    func testCreateNoteWithNewCategoryAndAISuggestion() {
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["notes.emptyState"].waitForExistence(timeout: 5))
        app.buttons["notes.addButton"].tap()

        // Fresh store has no categories yet — AddNoteView shows a prompt
        // instead of the chip picker.
        let noCategoriesPrompt = app.buttons["addNote.noCategoriesPrompt"]
        XCTAssertTrue(noCategoriesPrompt.waitForExistence(timeout: 5))
        noCategoriesPrompt.tap()

        let categoryNameField = app.textFields["addCategory.nameField"]
        XCTAssertTrue(categoryNameField.waitForExistence(timeout: 5))
        categoryNameField.tap()
        categoryNameField.typeText("Trabajo")
        app.buttons["addCategory.saveButton"].tap()

        // Back in AddNoteView: the new category loaded and got
        // auto-selected, so only title + body are left to fill.
        let bodyEditor = app.textViews["addNote.bodyEditor"]
        XCTAssertTrue(bodyEditor.waitForExistence(timeout: 5))
        bodyEditor.tap()
        bodyEditor.typeText("Repasar el flujo de onboarding y unificar los estilos de botones antes de la demo.")

        // The AI suggestion banner is debounced and depends on an on-device
        // model that may not be available on every runner — accept it if it
        // shows up in time, otherwise fall back to filling the title by
        // hand so the flow stays deterministic either way.
        let titleSuggestionChip = app.buttons["addNote.suggestion.titleChip"]
        if titleSuggestionChip.waitForExistence(timeout: 4) {
            titleSuggestionChip.tap()
        } else {
            let titleField = app.textFields["addNote.titleField"]
            titleField.tap()
            titleField.typeText("Ideas para el rediseño")
        }

        let saveButton = app.buttons["addNote.saveButton"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        // Dismissed back to the notes list with exactly the new note.
        // `.descendants(matching: .any)`, not `.otherElements` — a List row
        // combined into one accessibility element via `.accessibilityElement`
        // can surface as a cell rather than a generic "other" element.
        let noteRows = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'notes.row.'"))
        XCTAssertTrue(noteRows.firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(noteRows.count, 1)
    }
}
