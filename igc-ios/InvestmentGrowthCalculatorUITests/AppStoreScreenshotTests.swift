import XCTest

/// Generates App Store listing screenshots from the real app rather than from
/// mock-ups, so a listing image can never show a state the app cannot produce.
///
/// Skipped in normal runs. Generate with:
///
///     IGC_SCREENSHOTS=1 xcodebuild test \
///       -scheme InvestmentGrowthCalculator \
///       -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
///       -only-testing:InvestmentGrowthCalculatorUITests/AppStoreScreenshotTests
///
/// Then export the attachments from the resulting `.xcresult` bundle.
final class AppStoreScreenshotTests: XCTestCase {
    private var storeIdentifier = ""

    override func setUpWithError() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["IGC_SCREENSHOTS"] == "1",
            "Set IGC_SCREENSHOTS=1 to regenerate App Store screenshots."
        )
        continueAfterFailure = false
        storeIdentifier = "screenshots-\(UUID().uuidString)"
    }

    func testCaptureListingScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-uiScenarioStore", storeIdentifier]
        app.launch()

        XCTAssertTrue(app.navigationBars["IGC"].waitForExistence(timeout: 10))

        // 1 — Calculator, with the coach card dismissed so the inputs lead.
        let dismissCoach = app.buttons["calculator.coach.dismiss"]
        if dismissCoach.waitForExistence(timeout: 5) {
            scrollTo(dismissCoach, in: app)
            dismissCoach.tap()
        }
        capture(app, named: "01-calculator")

        // 2 — Projection headline: after-fee balance and today's-money value.
        let viewProjection = app.buttons["calculator.viewProjection"]
        scrollTo(viewProjection, in: app)
        viewProjection.tap()
        XCTAssertTrue(app.navigationBars["Projection"].waitForExistence(timeout: 10))
        capture(app, named: "02-projection-headline")

        // 3 — Breakdown and fee impact.
        scrollTo(app.staticTexts["Fee impact"], in: app)
        capture(app, named: "03-breakdown-and-fees")

        // 4 — Balance over time.
        scrollTo(app.buttons["projection.viewAnnualDetail"], in: app)
        capture(app, named: "04-chart")

        // 5 — Annual detail with a year expanded, showing the row reconciling.
        app.buttons["projection.viewAnnualDetail"].tap()
        XCTAssertTrue(app.navigationBars["Annual detail"].waitForExistence(timeout: 10))
        let finalYear = app.buttons.matching(
            NSPredicate(format: "identifier BEGINSWITH %@", "annual.row.")
        ).element(boundBy: 0)
        if finalYear.waitForExistence(timeout: 5) {
            finalYear.tap()
        }
        capture(app, named: "05-annual-detail")
        app.navigationBars["Annual detail"].buttons.element(boundBy: 0).tap()

        // 6 — Saved scenarios, populated.
        XCTAssertTrue(app.navigationBars["Projection"].waitForExistence(timeout: 10))
        app.buttons["projection.save"].tap()
        let nameField = app.textFields["projection.saveSheet.name"]
        if nameField.waitForExistence(timeout: 5) {
            nameField.tap()
            nameField.typeText("Retirement plan")
            app.buttons["projection.saveSheet.confirm"].tap()
        }
        tab(named: "Saved", in: app).tap()
        XCTAssertTrue(app.navigationBars["Saved scenarios"].waitForExistence(timeout: 10))
        capture(app, named: "06-saved-scenarios")

        // 7 — Education, the honesty story.
        tab(named: "Education", in: app).tap()
        XCTAssertTrue(app.navigationBars["Education"].waitForExistence(timeout: 10))
        capture(app, named: "07-education")

        // 8 — What the projection excludes.
        let exclusions = app.buttons["education.exclusions"]
        scrollTo(exclusions, in: app)
        exclusions.tap()
        XCTAssertTrue(
            app.navigationBars["What this projection excludes"].waitForExistence(timeout: 10)
        )
        capture(app, named: "08-exclusions")
    }

    private func capture(_ app: XCUIApplication, named name: String) {
        // Full-screen capture: App Store screenshots must be the device's exact
        // pixel dimensions, which a window-scoped screenshot may not match.
        _ = app
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func tab(named name: String, in app: XCUIApplication) -> XCUIElement {
        let compactTab = app.tabBars.buttons[name].firstMatch
        return compactTab.exists ? compactTab : app.buttons[name].firstMatch
    }

    private func scrollTo(_ element: XCUIElement, in app: XCUIApplication) {
        var attempts = 0
        while attempts < 20 {
            if element.exists, element.isHittable {
                let tabBar = app.tabBars.firstMatch
                let unobscuredBottom = tabBar.exists ? tabBar.frame.minY - 8 : app.frame.maxY - 8
                if element.frame.maxY <= unobscuredBottom { return }
            }
            app.swipeUp()
            attempts += 1
        }
    }
}
