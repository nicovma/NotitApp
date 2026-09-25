//
//  LaunchHelper.swift
//  NotitAppUITests
//
import XCTest

extension XCTestCase {
    /// Launches the app with an in-memory, empty SwiftData store so every
    /// test starts from the same clean state regardless of what previous
    /// runs (or the on-disk dev store) left behind.
    func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--ui-testing"]
        app.launch()
        return app
    }

    /// Drives the full "add note" flow, creating a brand-new category along
    /// the way, so tests that need a note to already exist (category count,
    /// category detail) don't have to repeat the whole flow inline. Assumes
    /// `app` is freshly launched with an empty store and currently on the
    /// Notes tab.
    @discardableResult
    func createNoteWithNewCategory(app: XCUIApplication, categoryName: String, title: String, body: String) -> Bool {
        app.buttons["notes.addButton"].tap()

        let noCategoriesPrompt = app.buttons["addNote.noCategoriesPrompt"]
        guard noCategoriesPrompt.waitForExistence(timeout: 5) else { return false }
        noCategoriesPrompt.tap()

        let categoryNameField = app.textFields["addCategory.nameField"]
        guard categoryNameField.waitForExistence(timeout: 5) else { return false }
        categoryNameField.tap()
        categoryNameField.typeText(categoryName)
        app.buttons["addCategory.saveButton"].tap()

        let titleField = app.textFields["addNote.titleField"]
        guard titleField.waitForExistence(timeout: 5) else { return false }
        titleField.tap()
        titleField.typeText(title)

        let bodyEditor = app.textViews["addNote.bodyEditor"]
        bodyEditor.tap()
        bodyEditor.typeText(body)

        let saveButton = app.buttons["addNote.saveButton"]
        guard saveButton.isEnabled else { return false }
        saveButton.tap()
        return true
    }
}
