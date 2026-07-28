import XCTest

@MainActor
final class InvestmentGrowthCalculatorUITests: XCTestCase {
    private let scenarioStoreIdentifier = UUID().uuidString

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

        for tabName in ["Calculator", "Saved", "Education", "Settings"] {
            XCTAssertTrue(
                tab(named: tabName, in: app).exists,
                "Missing stable \(tabName) tab"
            )
        }

        tab(named: "Saved", in: app).tap()
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
        XCTAssertTrue(app.buttons["projection.save"].exists)
        XCTAssertEqual(app.buttons["projection.save"].label, "Save")
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
        XCTAssertTrue(app.staticTexts["calculator.error.principal"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.textFields["calculator.principal"].value as? String, "0 pounds")
        XCTAssertEqual(app.textFields["calculator.contribution"].value as? String, "0 pounds")
    }

    func testNextDoneFocusLossAndCorrectionValidationLifecycle() {
        let app = launch()
        let principal = app.textFields["calculator.principal"]
        replaceText(in: principal, with: "1,2")
        app.buttons["Next"].tap()

        XCTAssertTrue(app.staticTexts["calculator.error.principal"].waitForExistence(timeout: 2))
        assertHasKeyboardFocus(app.textFields["calculator.contribution"])

        replaceText(in: principal, with: "1,234.50")
        XCTAssertTrue(
            app.staticTexts["calculator.error.principal"].waitForNonExistence(timeout: 2)
        )

        let contribution = app.textFields["calculator.contribution"]
        replaceText(in: contribution, with: "1£2")
        app.buttons["Done"].tap()
        XCTAssertTrue(
            app.staticTexts["calculator.error.contribution"].waitForExistence(timeout: 2)
        )
        XCTAssertEqual(app.keyboards.count, 0)

        let apr = app.textFields["calculator.apr"]
        scrollToElement(apr, in: app)
        replaceText(in: apr, with: "+7")
        app.textFields["calculator.inflation"].tap()
        XCTAssertTrue(app.staticTexts["calculator.error.apr"].waitForExistence(timeout: 2))

        let correctedAPR = app.textFields["calculator.apr"]
        scrollBackToElement(correctedAPR, in: app)
        replaceText(in: correctedAPR, with: "7")
        XCTAssertTrue(app.staticTexts["calculator.error.apr"].waitForNonExistence(timeout: 2))
    }

    func testCollapsedInvalidTargetExpandsScrollsAndFocusesOnSubmission() {
        let app = launch(arguments: ["-uiCollapsedInvalidTarget"])
        XCTAssertFalse(app.textFields["calculator.target"].exists)

        let projectionButton = app.buttons["calculator.viewProjection"]
        scrollToElement(projectionButton, in: app)
        projectionButton.tap()

        let target = app.textFields["calculator.target"]
        XCTAssertTrue(target.waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["calculator.error.target"].exists)
        assertHasKeyboardFocus(target)
        XCTAssertTrue(app.navigationBars["Calculator"].exists)
        XCTAssertFalse(app.navigationBars["Projection"].exists)
    }

    func testRemoveTargetRequiresConfirmationAndCollapsesAfterRemoval() {
        let app = launch(arguments: ["-uiTargetBaseline"])
        let target = app.textFields["calculator.target"]
        scrollToElement(target, in: app)
        XCTAssertEqual(target.value as? String, "100000 pounds")

        let remove = app.buttons["calculator.removeTarget"]
        scrollToElement(remove, in: app)
        remove.tap()
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 2))
        app.buttons["Cancel"].tap()
        XCTAssertTrue(target.exists)
        XCTAssertEqual(target.value as? String, "100000 pounds")

        remove.tap()
        let confirm = app.buttons["calculator.confirmRemoveTarget"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 2))
        confirm.firstMatch.tap()
        XCTAssertTrue(target.waitForNonExistence(timeout: 2))
        XCTAssertFalse(app.buttons["calculator.removeTarget"].exists)
        XCTAssertTrue(app.buttons["Target in today’s money (optional)"].exists)
    }

    func testAccessibilityTextUsesAdaptiveContributionTimingMenu() {
        let app = launch(arguments: ["-uiAccessibilityText"])
        let menu = app.descendants(matching: .any)["calculator.timing.menu"]
        scrollToElement(menu, in: app)
        XCTAssertTrue(menu.exists)
        XCTAssertFalse(app.descendants(matching: .any)["calculator.timing.segmented"].exists)
        XCTAssertTrue(menu.label.contains("Contribution timing"))
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

        tab(named: "Education", in: app).tap()
        XCTAssertTrue(app.navigationBars["Education"].waitForExistence(timeout: 2))
        tab(named: "Calculator", in: app).tap()
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
        XCTAssertTrue(tab(named: "Calculator", in: app).exists)
        XCTAssertTrue(tab(named: "Settings", in: app).exists)
    }

    func testSavePopulatesSavedRootAndPersistsAcrossRelaunch() {
        let app = launch()
        saveCurrentProjection(as: "Lifecycle baseline", in: app)

        tab(named: "Saved", in: app).tap()
        XCTAssertTrue(app.descendants(matching: .any)["saved.populated"].waitForExistence(timeout: 4))
        XCTAssertEqual(app.staticTexts["saved.count"].label, "1 saved scenario")
        XCTAssertTrue(scenarioRow(named: "Lifecycle baseline", in: app).exists)

        app.terminate()
        app.launch()
        tab(named: "Saved", in: app).tap()

        XCTAssertTrue(app.staticTexts["saved.count"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["saved.count"].label, "1 saved scenario")
        XCTAssertTrue(scenarioRow(named: "Lifecycle baseline", in: app).exists)
    }

    func testLoadIntoCalculatorThenSaveAsNewCreatesAnotherRecord() {
        let app = launch()
        saveCurrentProjection(as: "Loaded plan", in: app)
        tab(named: "Saved", in: app).tap()
        XCTAssertTrue(app.staticTexts["saved.count"].waitForExistence(timeout: 4))

        scenarioRow(named: "Loaded plan", in: app).tap()
        XCTAssertTrue(app.navigationBars["Calculator"].waitForExistence(timeout: 4))
        let loadedStatus = app.descendants(matching: .any)["calculator.loadedStatus"]
        XCTAssertTrue(loadedStatus.waitForExistence(timeout: 3))
        XCTAssertTrue(loadedStatus.label.contains("Loaded “Loaded plan”"))

        openProjection(in: app)
        XCTAssertEqual(app.buttons["projection.save"].label, "Save as new")
        saveVisibleProjection(as: "Loaded plan review", in: app)

        tab(named: "Saved", in: app).tap()
        XCTAssertTrue(app.staticTexts["saved.count"].waitForExistence(timeout: 4))
        XCTAssertEqual(app.staticTexts["saved.count"].label, "2 saved scenarios")
        XCTAssertTrue(scenarioRow(named: "Loaded plan", in: app).exists)
        XCTAssertTrue(scenarioRow(named: "Loaded plan review", in: app).exists)
    }

    func testRenameAndDuplicateScenario() {
        let app = launch()
        saveCurrentProjection(as: "Lifecycle plan", in: app)
        tab(named: "Saved", in: app).tap()
        XCTAssertTrue(app.staticTexts["saved.count"].waitForExistence(timeout: 4))

        scenarioMenu(named: "Lifecycle plan", in: app).tap()
        app.buttons["Rename"].tap()
        let renameField = app.textFields["saved.rename.name"]
        XCTAssertTrue(renameField.waitForExistence(timeout: 3))
        XCTAssertEqual(renameField.value as? String, "Lifecycle plan")
        replaceText(in: renameField, with: "Lifecycle renamed")
        app.buttons["saved.rename.confirm"].tap()
        let renameStatus = app.descendants(matching: .any)["saved.status.success"]
        XCTAssertTrue(renameStatus.waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Renamed to “Lifecycle renamed”"].exists)

        scenarioMenu(named: "Lifecycle renamed", in: app).tap()
        app.buttons["Duplicate"].tap()
        XCTAssertTrue(waitForLabel("2 saved scenarios", element: app.staticTexts["saved.count"]))
        XCTAssertTrue(scenarioRow(named: "Lifecycle renamed", in: app).exists)
        XCTAssertTrue(scenarioRow(named: "Lifecycle renamed copy", in: app).exists)
    }

    func testDeleteRequiresConfirmationSupportsCancelThenDeletesOne() {
        let app = launch()
        saveCurrentProjection(as: "Delete candidate", in: app)
        tab(named: "Saved", in: app).tap()
        XCTAssertTrue(app.staticTexts["saved.count"].waitForExistence(timeout: 4))

        scenarioMenu(named: "Delete candidate", in: app).tap()
        app.buttons["Delete"].tap()
        XCTAssertTrue(app.alerts["Delete “Delete candidate”?"].waitForExistence(timeout: 3))
        app.buttons["Cancel"].tap()
        XCTAssertTrue(scenarioRow(named: "Delete candidate", in: app).exists)
        XCTAssertEqual(app.staticTexts["saved.count"].label, "1 saved scenario")

        scenarioMenu(named: "Delete candidate", in: app).tap()
        app.buttons["Delete"].tap()
        app.buttons["saved.confirmDelete"].firstMatch.tap()
        XCTAssertTrue(app.descendants(matching: .any)["saved.empty"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["No saved scenarios"].exists)
    }

    func testUnavailableStorageRecoveryStateIsAccessibleAtLargeDynamicType() {
        let app = launch(arguments: ["-uiUnavailableStore", "-uiAccessibilityText"])
        tab(named: "Saved", in: app).tap()

        let recovery = app.descendants(matching: .any)["saved.recovery.unavailable"]
        XCTAssertTrue(recovery.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Saved scenarios are temporarily unavailable"].exists)
        XCTAssertTrue(app.buttons["Try again"].exists)
        XCTAssertTrue(app.buttons["Continue with calculator"].exists)
        XCTAssertFalse(app.staticTexts["No saved scenarios"].exists)
    }

    func testCorruptAndUnsupportedRecoveryStatesRemainDistinctAndNonDestructiveFirst() {
        let corruptApp = launch(arguments: ["-uiCorruptStore"])
        tab(named: "Saved", in: corruptApp).tap()
        XCTAssertTrue(
            corruptApp.descendants(matching: .any)["saved.recovery.corrupt"]
                .waitForExistence(timeout: 5)
        )
        XCTAssertTrue(corruptApp.staticTexts["Saved scenarios need recovery"].exists)
        XCTAssertTrue(corruptApp.buttons["Try again"].exists)
        XCTAssertTrue(corruptApp.buttons["Continue without saved scenarios"].exists)
        XCTAssertTrue(corruptApp.buttons["Start with an empty saved list"].exists)
        XCTAssertFalse(corruptApp.staticTexts["No saved scenarios"].exists)

        corruptApp.terminate()
        let unsupportedApp = launch(arguments: ["-uiUnsupportedStore"])
        tab(named: "Saved", in: unsupportedApp).tap()
        XCTAssertTrue(
            unsupportedApp.descendants(matching: .any)["saved.recovery.unsupported"]
                .waitForExistence(timeout: 5)
        )
        XCTAssertTrue(unsupportedApp.staticTexts["Saved scenarios use a newer format"].exists)
        XCTAssertTrue(unsupportedApp.buttons["Keep data and continue"].exists)
        XCTAssertTrue(unsupportedApp.buttons["Delete saved scenarios"].exists)
        XCTAssertFalse(unsupportedApp.staticTexts["No saved scenarios"].exists)
    }

    private func launch(arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-uiTesting",
            "-uiScenarioStore",
            scenarioStoreIdentifier,
        ] + arguments
        app.launch()
        return app
    }

    private func tab(named name: String, in app: XCUIApplication) -> XCUIElement {
        let compactTab = app.tabBars.buttons[name].firstMatch
        return compactTab.exists ? compactTab : app.buttons[name].firstMatch
    }

    private func saveCurrentProjection(as name: String, in app: XCUIApplication) {
        openProjection(in: app)
        saveVisibleProjection(as: name, in: app)
    }

    private func openProjection(in app: XCUIApplication) {
        let projectionButton = app.buttons["calculator.viewProjection"]
        scrollToElement(projectionButton, in: app)
        projectionButton.tap()
        XCTAssertTrue(app.navigationBars["Projection"].waitForExistence(timeout: 5))
    }

    private func saveVisibleProjection(as name: String, in app: XCUIApplication) {
        let saveButton = app.buttons["projection.save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3))
        saveButton.tap()

        let nameField = app.textFields["projection.saveSheet.name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        replaceText(in: nameField, with: name)
        app.buttons["projection.saveSheet.confirm"].tap()
        let status = app.descendants(matching: .any)["projection.savedStatus"]
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Saved “\(name)”"].exists)
    }

    private func scenarioRow(named name: String, in app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(
            NSPredicate(
                format: "identifier BEGINSWITH %@ AND label CONTAINS %@",
                "saved.row.",
                name
            )
        ).firstMatch
    }

    private func scenarioMenu(named name: String, in app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(
            NSPredicate(
                format: "identifier BEGINSWITH %@ AND label == %@",
                "saved.menu.",
                "Actions for \(name)"
            )
        ).firstMatch
    }

    private func waitForLabel(_ label: String, element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "label == %@", label)
        let expectation = expectation(for: predicate, evaluatedWith: element)
        return XCTWaiter.wait(for: [expectation], timeout: 4) == .completed
    }

    private func replaceText(in field: XCUIElement, with replacement: String) {
        field.tap()
        let focusPredicate = NSPredicate(format: "hasKeyboardFocus == true")
        if !focusPredicate.evaluate(with: field) {
            field.tap()
        }
        let currentCount = (field.value as? String)?.count ?? 20
        field.typeText(
            String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentCount + 10)
        )
        field.typeText(replacement)
    }

    private func assertHasKeyboardFocus(
        _ element: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let focused = expectation(
            for: NSPredicate(format: "hasKeyboardFocus == true"),
            evaluatedWith: element
        )
        let result = XCTWaiter.wait(for: [focused], timeout: 2)
        XCTAssertEqual(result, .completed, file: file, line: line)
    }

    private func scrollToElement(_ element: XCUIElement, in app: XCUIApplication) {
        var attempts = 0
        while needsMoreScrolling(element, in: app), attempts < 20 {
            app.swipeUp()
            attempts += 1
        }
        XCTAssertTrue(element.exists)
    }

    private func scrollBackToElement(_ element: XCUIElement, in app: XCUIApplication) {
        var attempts = 0
        while needsScrollingBack(element, in: app), attempts < 20 {
            app.swipeDown()
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

    private func needsScrollingBack(_ element: XCUIElement, in app: XCUIApplication) -> Bool {
        guard element.exists, element.isHittable else { return true }
        let navigationBar = app.navigationBars.firstMatch
        let unobscuredTop = navigationBar.exists ? navigationBar.frame.maxY + 8 : 8
        return element.frame.minY < unobscuredTop
    }
}
