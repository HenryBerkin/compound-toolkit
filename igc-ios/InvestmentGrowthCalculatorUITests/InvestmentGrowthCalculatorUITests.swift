import XCTest

@MainActor
final class InvestmentGrowthCalculatorUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCleanLaunchShowsExactCustomBaselineAndStableTabs() {
        let app = launch()

        XCTAssertTrue(app.navigationBars["Calculator"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["calculator.preset"].label.contains("Custom"))
        XCTAssertEqual(app.textFields["calculator.principal"].value as? String, "10000 pounds")
        XCTAssertEqual(app.textFields["calculator.contribution"].value as? String, "250 pounds")

        scrollToElement(app.textFields["calculator.fee"], in: app)
        XCTAssertEqual(app.textFields["calculator.apr"].value as? String, "7 percent")
        XCTAssertEqual(app.textFields["calculator.inflation"].value as? String, "3 percent")
        XCTAssertEqual(app.textFields["calculator.fee"].value as? String, "0.20 percent")

        scrollToElement(app.textFields["calculator.years"], in: app)
        XCTAssertEqual(app.textFields["calculator.years"].value as? String, "15")

        for tab in ["Calculator", "Saved", "Education", "Settings"] {
            XCTAssertTrue(app.tabBars.buttons[tab].exists, "Missing stable \(tab) tab")
        }

        app.tabBars.buttons["Saved"].tap()
        XCTAssertTrue(app.staticTexts["No saved scenarios"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["Save"].exists)
        XCTAssertFalse(app.buttons["Compare"].exists)
        XCTAssertFalse(app.buttons["Export"].exists)

        app.buttons["Go to Calculator"].tap()
        XCTAssertTrue(app.navigationBars["Calculator"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.textFields["calculator.years"].value as? String, "15")
    }

    func testValidCalculatorProjectionChartAlternativeAndAnnualDetail() {
        let app = launch()
        let projectionButton = app.buttons["calculator.viewProjection"]
        scrollToElement(projectionButton, in: app)
        projectionButton.tap()

        XCTAssertTrue(app.navigationBars["Projection"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["projection.finalBalance"].exists)
        XCTAssertFalse(app.buttons["Save"].exists)
        XCTAssertFalse(app.staticTexts["Monthly detail"].exists)
        XCTAssertFalse(app.buttons["Export"].exists)
        XCTAssertFalse(app.buttons["Compare"].exists)

        let annualButton = app.buttons["projection.viewAnnualDetail"]
        scrollToElement(annualButton, in: app)
        XCTAssertTrue(app.descendants(matching: .any)["projection.chartSummary"].exists)
        annualButton.tap()

        XCTAssertTrue(app.navigationBars["Annual detail"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.descendants(matching: .any)["annual.row.1"].exists)
        let finalAnnualRow = app.descendants(matching: .any)["annual.row.15"]
        scrollToElement(finalAnnualRow, in: app)
        XCTAssertTrue(finalAnnualRow.exists)
        XCTAssertFalse(app.staticTexts["Month 1"].exists)
    }

    func testValidationFailureKeepsCalculatorAndFocusesError() {
        let app = launch(arguments: ["-uiInvalidBaseline"])
        let projectionButton = app.buttons["calculator.viewProjection"]
        scrollToElement(projectionButton, in: app)
        projectionButton.tap()

        XCTAssertTrue(app.navigationBars["Calculator"].exists)
        XCTAssertFalse(app.navigationBars["Projection"].exists)
        XCTAssertTrue(app.staticTexts["calculator.error"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.textFields["calculator.principal"].value as? String, "0 pounds")
        XCTAssertEqual(app.textFields["calculator.contribution"].value as? String, "0 pounds")
    }

    func testTargetStatusUsesTextAndTabStateRemainsStable() {
        let app = launch(arguments: ["-uiTargetBaseline"])
        let targetField = app.textFields["calculator.target"]
        scrollToElement(targetField, in: app)
        XCTAssertEqual(targetField.value as? String, "100000 pounds")

        let projectionButton = app.buttons["calculator.viewProjection"]
        scrollToElement(projectionButton, in: app)
        projectionButton.tap()

        XCTAssertTrue(app.navigationBars["Projection"].waitForExistence(timeout: 5))
        let targetStatus = app.descendants(matching: .any)["projection.targetStatus"]
        scrollToElement(targetStatus, in: app)
        XCTAssertTrue(targetStatus.label.localizedCaseInsensitiveContains("below the target"))

        app.tabBars.buttons["Education"].tap()
        XCTAssertTrue(app.navigationBars["Education"].waitForExistence(timeout: 2))
        app.tabBars.buttons["Calculator"].tap()
        XCTAssertTrue(app.navigationBars["Projection"].waitForExistence(timeout: 2))
    }

    func testNonUKLocaleKeepsGBPAndLandscapeNavigation() {
        XCUIDevice.shared.orientation = .portrait
        defer { XCUIDevice.shared.orientation = .portrait }

        let app = launch(arguments: [
            "-AppleLanguages", "(fr)",
            "-AppleLocale", "fr_FR",
        ])
        let projectionButton = app.buttons["calculator.viewProjection"]
        scrollToElement(projectionButton, in: app)
        projectionButton.tap()

        XCTAssertTrue(app.navigationBars["Projection"].waitForExistence(timeout: 5))
        let finalBalance = app.descendants(matching: .any)["projection.finalBalance"]
        XCTAssertTrue(finalBalance.exists)
        XCTAssertTrue(finalBalance.label.contains("£"))

        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(app.navigationBars["Projection"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.tabBars.buttons["Calculator"].exists)
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists)
    }

    private func launch(arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"] + arguments
        app.launch()
        return app
    }

    private func scrollToElement(_ element: XCUIElement, in app: XCUIApplication) {
        var attempts = 0
        while needsMoreScrolling(element, in: app), attempts < 20 {
            app.swipeUp()
            attempts += 1
        }
        XCTAssertTrue(element.exists)
    }

    private func needsMoreScrolling(_ element: XCUIElement, in app: XCUIApplication) -> Bool {
        guard element.exists, element.isHittable else { return true }
        let tabBar = app.tabBars.firstMatch
        let unobscuredBottom = tabBar.exists ? tabBar.frame.minY - 8 : app.frame.maxY - 8
        return element.frame.maxY > unobscuredBottom
    }
}
