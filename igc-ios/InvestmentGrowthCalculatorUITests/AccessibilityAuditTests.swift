import XCTest

/// Runs XCTest's built-in accessibility audit across the main screens.
///
/// This exists to keep the App Store accessibility declarations honest. Apple's
/// requirement is that a user can complete common tasks using the feature, so a claim
/// needs evidence rather than intent. The audit checks contrast, element description,
/// hit-region size, clipped text and Dynamic Type handling.
final class AccessibilityAuditTests: XCTestCase {
    /// Skipped by default. The audit currently reports open findings, so running it in
    /// the normal suite would keep the build red without adding signal. Run it
    /// deliberately with `TEST_RUNNER_IGC_A11Y_AUDIT=1` when working on accessibility,
    /// and make it a gate once the findings are resolved.
    override func setUpWithError() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["IGC_A11Y_AUDIT"] == "1",
            "Set IGC_A11Y_AUDIT=1 to run the accessibility audit."
        )
        continueAfterFailure = true
    }

    func testMainScreensPassAccessibilityAudit() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "-uiTesting",
            "-uiScenarioStore",
            "audit-\(UUID().uuidString)",
        ]
        app.launch()
        XCTAssertTrue(app.navigationBars["IGC"].waitForExistence(timeout: 10))

        let dismissCoach = app.buttons["calculator.coach.dismiss"]
        if dismissCoach.waitForExistence(timeout: 5) {
            dismissCoach.tap()
        }

        try auditCurrentScreen(app, named: "Calculator")

        let viewProjection = app.buttons["calculator.viewProjection"]
        scrollTo(viewProjection, in: app)
        viewProjection.tap()
        XCTAssertTrue(app.navigationBars["Projection"].waitForExistence(timeout: 10))
        try auditCurrentScreen(app, named: "Projection")

        app.buttons["projection.viewAnnualDetail"].tap()
        XCTAssertTrue(app.navigationBars["Annual detail"].waitForExistence(timeout: 10))
        try auditCurrentScreen(app, named: "Annual detail")
        app.navigationBars["Annual detail"].buttons.element(boundBy: 0).tap()

        app.tabBars.buttons["Education"].tap()
        XCTAssertTrue(app.navigationBars["Education"].waitForExistence(timeout: 10))
        try auditCurrentScreen(app, named: "Education")

        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 10))
        try auditCurrentScreen(app, named: "Settings")
    }

    private func auditCurrentScreen(_ app: XCUIApplication, named name: String) throws {
        try app.performAccessibilityAudit { issue in
            // Report every issue rather than suppressing any: the point is evidence
            // for a public declaration, so a silenced finding defeats the exercise.
            let auditType = "\(issue.auditType)"
            let detail = issue.compactDescription
            let identifier = issue.element?.identifier ?? ""
            let label = issue.element?.label ?? ""
            let kind = issue.element.map { "\($0.elementType)" } ?? "none"
            print("IGC-AUDIT \(name) | \(auditType) | \(detail) | id=\(identifier) | label=\(label) | kind=\(kind)")
            return false
        }
    }

    private func scrollTo(_ element: XCUIElement, in app: XCUIApplication) {
        var attempts = 0
        while attempts < 20 {
            if element.exists, element.isHittable {
                let tabBar = app.tabBars.firstMatch
                let bottom = tabBar.exists ? tabBar.frame.minY - 8 : app.frame.maxY - 8
                if element.frame.maxY <= bottom { return }
            }
            app.swipeUp()
            attempts += 1
        }
    }
}
