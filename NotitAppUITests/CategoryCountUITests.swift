//
//  CategoryCountUITests.swift
//  NotitAppUITests
//
import XCTest

final class CategoryCountUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCategoryShowsCorrectNoteCountAfterCreatingNote() {
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["notes.emptyState"].waitForExistence(timeout: 5))
        XCTAssertTrue(createNoteWithNewCategory(
            app: app,
            categoryName: "Ideas",
            title: "Concepto de widget",
            body: "Un widget de pantalla de inicio con la nota más reciente de cada categoría."
        ))

        let noteRows = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'notes.row.'"))
        XCTAssertTrue(noteRows.firstMatch.waitForExistence(timeout: 5))

        app.buttons["tabBar.categories"].tap()

        let categoryRows = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'categories.row.' AND NOT (identifier ENDSWITH '.noteCount')"))
        XCTAssertTrue(categoryRows.firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(categoryRows.count, 1)

        let noteCountLabels = app.staticTexts.matching(NSPredicate(format: "identifier ENDSWITH '.noteCount'"))
        XCTAssertTrue(noteCountLabels.firstMatch.waitForExistence(timeout: 5))
        // String Catalog plural rule: "1 nota" (singular), not "1 notas".
        XCTAssertEqual(noteCountLabels.firstMatch.label, "1 nota")

        categoryRows.firstMatch.tap()

        let categoryNoteRows = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'categoryNotes.row.'"))
        XCTAssertTrue(categoryNoteRows.firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(categoryNoteRows.count, 1)
    }
}
