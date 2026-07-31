import XCTest

@MainActor
final class InvestmentGrowthCalculatorUITests: XCTestCase {
    private let scenarioStoreIdentifier = UUID().uuidString

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCleanLaunchShowsExactCustomBaselineAndStableTabs() {
        let app = launch()

        XCTAssertTrue(app.navigationBars["IGC"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Start with the example"].exists)
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
        XCTAssertTrue(app.navigationBars["IGC"].waitForExistence(timeout: 2))
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
        XCTAssertTrue(waitForEnabled(app.buttons["projection.save"]))
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

        XCTAssertTrue(app.navigationBars["IGC"].exists)
        XCTAssertFalse(app.navigationBars["Projection"].exists)
        XCTAssertTrue(app.staticTexts["calculator.error.principal"].waitForExistence(timeout: 3))
        XCTAssertEqual(app.textFields["calculator.principal"].value as? String, "0 pounds")
        XCTAssertEqual(app.textFields["calculator.contribution"].value as? String, "0 pounds")
    }

    func testNextDoneFocusLossAndCorrectionValidationLifecycle() {
        let app = launch()
        let dismissCoach = app.buttons["calculator.coach.dismiss"]
        if dismissCoach.exists {
            scrollToElement(dismissCoach, in: app)
            dismissCoach.tap()
        }
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
        XCTAssertTrue(app.navigationBars["IGC"].exists)
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
        XCTAssertTrue(app.navigationBars["IGC"].waitForExistence(timeout: 4))
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

    func testProjectionBlocksSaveWithAccessibleReasonForUnusableStores() {
        let states = [
            (
                argument: "-uiUnavailableStore",
                identifier: "projection.saveState.unavailable",
                title: "Can’t save while storage is unavailable"
            ),
            (
                argument: "-uiCorruptStore",
                identifier: "projection.saveState.corrupt",
                title: "Resolve saved-scenario recovery before saving"
            ),
            (
                argument: "-uiUnsupportedStore",
                identifier: "projection.saveState.unsupported",
                title: "Can’t save to the newer saved format"
            ),
        ]

        for state in states {
            let app = launch(arguments: [state.argument])
            openProjection(in: app)

            let reason = app.descendants(matching: .any)[state.identifier]
            XCTAssertTrue(
                reason.waitForExistence(timeout: 5),
                "Missing Projection reason for \(state.argument)"
            )
            XCTAssertTrue(reason.label.contains(state.title))
            XCTAssertTrue(app.descendants(matching: .any)["projection.finalBalance"].exists)
            XCTAssertTrue(app.buttons["projection.viewAnnualDetail"].exists)

            let saveButton = app.buttons["projection.save"]
            XCTAssertTrue(saveButton.exists)
            XCTAssertFalse(saveButton.isEnabled)
            XCTAssertFalse(app.textFields["projection.saveSheet.name"].exists)
            app.terminate()
        }
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

    func testCoachChoosePresetMovesToPickerWithoutSelectionAndPersists() {
        let app = launch()
        XCTAssertTrue(app.staticTexts["Start with the example"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.buttons["calculator.preset"].label.contains("Custom"))

        let choosePreset = app.buttons["calculator.coach.choosePreset"]
        scrollToElement(choosePreset, in: app)
        choosePreset.tap()
        XCTAssertTrue(
            app.staticTexts["Start with the example"].waitForNonExistence(timeout: 3)
        )
        let preset = app.buttons["calculator.preset"]
        XCTAssertTrue(preset.isHittable)
        XCTAssertTrue(preset.label.contains("Custom"))
        let baselineFields = [
            ("calculator.apr", "7 percent"),
            ("calculator.inflation", "3 percent"),
            ("calculator.fee", "0.20 percent"),
        ]
        for (identifier, expectedValue) in baselineFields {
            let field = app.textFields[identifier]
            scrollToElement(field, in: app)
            XCTAssertEqual(field.value as? String, expectedValue)
        }

        app.terminate()
        app.launch()
        XCTAssertTrue(app.navigationBars["IGC"].waitForExistence(timeout: 4))
        XCTAssertFalse(app.staticTexts["Start with the example"].exists)
        XCTAssertTrue(app.buttons["calculator.preset"].label.contains("Custom"))
    }

    func testCoachDismissFailureIsSessionOnlyAndReturnsOnRelaunch() {
        let app = launch(arguments: ["-uiCoachWriteFailure"])
        XCTAssertTrue(app.staticTexts["Start with the example"].waitForExistence(timeout: 4))

        let dismissCoach = app.buttons["calculator.coach.dismiss"]
        scrollToElement(dismissCoach, in: app)
        dismissCoach.tap()
        XCTAssertTrue(
            app.staticTexts["Start with the example"].waitForNonExistence(timeout: 3)
        )
        XCTAssertTrue(
            app.descendants(matching: .any)["calculator.preferenceFailure"]
                .waitForExistence(timeout: 3)
        )
        XCTAssertTrue(
            app.staticTexts[
                "The coach was dismissed for this session, but the preference was not saved."
            ].exists
        )

        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts["Start with the example"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.buttons["calculator.preset"].label.contains("Custom"))
    }

    func testEducationHierarchyGlossaryAndContextualRoutesStayFeatureLocal() {
        let app = launch()
        let dismissCoach = app.buttons["calculator.coach.dismiss"]
        scrollToElement(dismissCoach, in: app)
        dismissCoach.tap()
        tab(named: "Education", in: app).tap()
        XCTAssertTrue(app.navigationBars["Education"].waitForExistence(timeout: 4))

        for identifier in [
            "education.understanding",
            "education.calculations",
            "education.glossary",
            "education.exclusions",
            "education.disclaimer",
        ] {
            let route = app.buttons[identifier]
            scrollToElement(route, in: app)
            XCTAssertTrue(route.exists)
        }

        let understanding = app.buttons["education.understanding"]
        scrollBackToElement(understanding, in: app)
        understanding.tap()
        XCTAssertTrue(
            app.navigationBars["Understanding your projection"].waitForExistence(timeout: 3)
        )
        app.navigationBars["Understanding your projection"].buttons["Education"].tap()

        let calculations = app.buttons["education.calculations"]
        scrollBackToElement(calculations, in: app)
        calculations.tap()
        XCTAssertTrue(app.navigationBars["How calculations work"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Monthly calculation"].exists)
        XCTAssertTrue(app.staticTexts["Contributions and timing"].exists)
        app.navigationBars["How calculations work"].buttons["Education"].tap()

        app.buttons["education.glossary"].tap()
        XCTAssertTrue(app.navigationBars["Glossary"].waitForExistence(timeout: 3))
        let expectedTerms = [
            "Annual growth rate",
            "Compounding",
            "Inflation",
            "Annual fee",
            "After fees",
            "Today’s money / purchasing power",
            "Contribution frequency",
            "Contribution timing",
            "Preset and Custom",
            "Target",
        ]
        for term in expectedTerms {
            let row = app.buttons[term]
            scrollToElement(row, in: app)
            XCTAssertTrue(row.exists, "Missing glossary term \(term)")
        }
        app.navigationBars["Glossary"].buttons["Education"].tap()

        let exclusions = app.buttons["education.exclusions"]
        scrollToElement(exclusions, in: app)
        exclusions.tap()
        XCTAssertTrue(
            app.navigationBars["What this projection excludes"].waitForExistence(timeout: 3)
        )
        app.navigationBars["What this projection excludes"].buttons["Education"].tap()

        let educationDisclaimer = app.buttons["education.disclaimer"]
        scrollToElement(educationDisclaimer, in: app)
        educationDisclaimer.tap()
        XCTAssertTrue(
            app.navigationBars["Projection disclaimer"].waitForExistence(timeout: 3)
        )
        app.navigationBars["Projection disclaimer"].buttons["Education"].tap()

        tab(named: "Calculator", in: app).tap()
        let methodology = app.buttons["calculator.howCalculationsWork"]
        scrollToElement(methodology, in: app)
        methodology.tap()
        XCTAssertTrue(app.navigationBars["How calculations work"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.navigationBars["Education"].exists)
        app.navigationBars["How calculations work"].buttons["IGC"].tap()
        XCTAssertTrue(app.navigationBars["IGC"].waitForExistence(timeout: 3))

        let calculatorDisclaimer = app.buttons["calculator.projectionDisclaimer"]
        scrollToElement(calculatorDisclaimer, in: app)
        calculatorDisclaimer.tap()
        XCTAssertTrue(
            app.navigationBars["Projection disclaimer"].waitForExistence(timeout: 3)
        )
        app.navigationBars["Projection disclaimer"].buttons["IGC"].tap()

        openProjection(in: app)
        let projectionMethodology = app.buttons["projection.howCalculationsWork"]
        scrollToElement(projectionMethodology, in: app)
        projectionMethodology.tap()
        XCTAssertTrue(
            app.navigationBars["How calculations work"].waitForExistence(timeout: 3)
        )
        app.navigationBars["How calculations work"].buttons["Projection"].tap()

        let disclaimer = app.buttons["projection.projectionDisclaimer"]
        scrollBackToElement(disclaimer, in: app)
        disclaimer.tap()
        XCTAssertTrue(app.navigationBars["Projection disclaimer"].waitForExistence(timeout: 3))
        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(
                    format: "label BEGINSWITH %@",
                    "IGC creates an illustrative projection"
                )
            ).firstMatch.exists
        )
        app.navigationBars["Projection disclaimer"].buttons["Projection"].tap()
        XCTAssertTrue(app.navigationBars["Projection"].waitForExistence(timeout: 3))
    }

    func testSettingsAppearanceAboutPrivacyAndDisclaimerRoutes() {
        let app = launch()
        let dismissCoach = app.buttons["calculator.coach.dismiss"]
        scrollToElement(dismissCoach, in: app)
        dismissCoach.tap()
        tab(named: "Settings", in: app).tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 4))

        selectAppearance("Light", in: app)
        XCTAssertTrue(
            app.buttons["settings.appearance"].label.localizedCaseInsensitiveContains("Light")
        )
        selectAppearance("Dark", in: app)
        XCTAssertTrue(
            app.buttons["settings.appearance"].label.localizedCaseInsensitiveContains("Dark")
        )

        app.terminate()
        app.launch()
        tab(named: "Settings", in: app).tap()
        XCTAssertTrue(
            app.buttons["settings.appearance"].label.localizedCaseInsensitiveContains("Dark")
        )
        selectAppearance("System", in: app)

        app.buttons["settings.about"].tap()
        XCTAssertTrue(app.navigationBars["About IGC"].waitForExistence(timeout: 3))
        XCTAssertTrue(
            app.descendants(matching: .any)["about.productName"]
                .label.contains("Investment Growth Calculator")
        )
        XCTAssertTrue(
            app.descendants(matching: .any)["about.shorthand"].label.contains("IGC")
        )
        // Assert the display shape, not a literal build number: pinning the build here
        // breaks this test on every release bump. Exact agreement with the host bundle
        // is already covered by testAboutUsesActualHostAppBundleVersionAndBuild.
        let versionBuildLabel = app.descendants(matching: .any)["about.versionBuild"].label
        XCTAssertNotNil(
            versionBuildLabel.range(
                of: #"\d+\.\d+(\.\d+)? \(\d+\)"#,
                options: .regularExpression
            ),
            "About should show a version and build, got: \(versionBuildLabel)"
        )
        app.navigationBars["About IGC"].buttons["Settings"].tap()

        app.buttons["settings.privacy"].tap()
        XCTAssertTrue(app.navigationBars["Privacy"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Calculation"].exists)
        scrollToElement(app.staticTexts["Services not present"], in: app)
        XCTAssertTrue(app.staticTexts["Services not present"].exists)
        app.navigationBars["Privacy"].buttons["Settings"].tap()

        let settingsSupport = app.buttons["settings.support"]
        scrollToElement(settingsSupport, in: app)
        settingsSupport.tap()
        XCTAssertTrue(app.navigationBars["Support"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.descendants(matching: .any)["support.page"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["support.email"].exists)
        let supportMethodology = app.buttons["support.methodology"]
        scrollToElement(supportMethodology, in: app)
        supportMethodology.tap()
        XCTAssertTrue(app.navigationBars["How calculations work"].waitForExistence(timeout: 3))
        app.navigationBars["How calculations work"].buttons["Support"].tap()
        app.navigationBars["Support"].buttons["Settings"].tap()

        let settingsDisclaimer = app.buttons["settings.disclaimer"]
        scrollToElement(settingsDisclaimer, in: app)
        settingsDisclaimer.tap()
        XCTAssertTrue(app.navigationBars["Projection disclaimer"].waitForExistence(timeout: 3))
    }

    func testDeleteAllCancelThenSuccessResetsPersistentAndInMemoryState() {
        let app = launch()
        let dismissCoach = app.buttons["calculator.coach.dismiss"]
        scrollToElement(dismissCoach, in: app)
        dismissCoach.tap()
        saveCurrentProjection(as: "Delete all candidate", in: app)

        tab(named: "Saved", in: app).tap()
        scenarioRow(named: "Delete all candidate", in: app).tap()
        XCTAssertTrue(
            app.descendants(matching: .any)["calculator.loadedStatus"]
                .waitForExistence(timeout: 4)
        )

        tab(named: "Education", in: app).tap()
        app.buttons["education.understanding"].tap()
        XCTAssertTrue(
            app.navigationBars["Understanding your projection"].waitForExistence(timeout: 3)
        )

        tab(named: "Settings", in: app).tap()
        selectAppearance("Dark", in: app)
        let deleteButton = app.buttons["settings.deleteAllData"]
        scrollToElement(deleteButton, in: app)
        deleteButton.tap()
        XCTAssertTrue(app.alerts["Delete all app data?"].waitForExistence(timeout: 3))
        let confirmationBody = app.staticTexts.matching(
            NSPredicate(
                format: "label == %@",
                "This deletes saved scenarios and resets appearance, onboarding, and calculator state on this device. This can’t be undone. Device backups have their own lifecycle."
            )
        ).firstMatch
        XCTAssertTrue(
            confirmationBody.exists
        )
        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].exists)
        XCTAssertTrue(deleteButton.exists)

        deleteButton.tap()
        app.buttons["settings.confirmDeleteAllData"].firstMatch.tap()
        XCTAssertTrue(app.navigationBars["IGC"].waitForExistence(timeout: 6))
        XCTAssertTrue(
            app.descendants(matching: .any)["calculator.appStatus"]
                .waitForExistence(timeout: 3)
        )
        XCTAssertTrue(app.staticTexts["All app data deleted"].exists)
        XCTAssertTrue(app.staticTexts["Start with the example"].exists)
        XCTAssertFalse(app.descendants(matching: .any)["calculator.loadedStatus"].exists)
        let principal = app.textFields["calculator.principal"]
        scrollToElement(principal, in: app)
        XCTAssertEqual(principal.value as? String, "10000 pounds")
        let contribution = app.textFields["calculator.contribution"]
        scrollToElement(contribution, in: app)
        XCTAssertEqual(contribution.value as? String, "250 pounds")
        // Reaching the fields above scrolls the preset picker off the top, and a Form
        // drops off-screen rows from the hierarchy. Scroll back as the assertions above
        // do, rather than depending on incidental layout.
        let resetPreset = app.buttons["calculator.preset"]
        scrollBackToElement(resetPreset, in: app)
        XCTAssertTrue(resetPreset.label.contains("Custom"))

        tab(named: "Saved", in: app).tap()
        XCTAssertTrue(app.staticTexts["No saved scenarios"].waitForExistence(timeout: 3))
        tab(named: "Education", in: app).tap()
        XCTAssertTrue(app.navigationBars["Education"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.navigationBars["Understanding your projection"].exists)
        tab(named: "Settings", in: app).tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))
        XCTAssertTrue(
            app.buttons["settings.appearance"].label.localizedCaseInsensitiveContains("System")
        )

        app.terminate()
        app.launch()
        XCTAssertTrue(app.navigationBars["IGC"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Start with the example"].exists)
        tab(named: "Saved", in: app).tap()
        XCTAssertTrue(app.staticTexts["No saved scenarios"].waitForExistence(timeout: 3))
    }

    func testDeleteAllPartialFailureHasNoFalseSuccessAndRetryCompletes() {
        let app = launch(arguments: ["-uiScenarioEraseFailsOnce"])
        let dismissCoach = app.buttons["calculator.coach.dismiss"]
        scrollToElement(dismissCoach, in: app)
        dismissCoach.tap()
        saveCurrentProjection(as: "Partial reset candidate", in: app)
        tab(named: "Settings", in: app).tap()

        let deleteButton = app.buttons["settings.deleteAllData"]
        scrollToElement(deleteButton, in: app)
        deleteButton.tap()
        app.buttons["settings.confirmDeleteAllData"].firstMatch.tap()

        let failure = app.descendants(matching: .any)["settings.deleteFailure"]
        XCTAssertTrue(failure.waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS %@", "Deletion did not complete")
            ).firstMatch.exists
        )
        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(
                    format: "label CONTAINS %@",
                    "recovery-material erasure could not be verified"
                )
            ).firstMatch.exists
        )
        XCTAssertFalse(app.staticTexts["All app data deleted"].exists)
        XCTAssertTrue(app.navigationBars["Settings"].exists)

        app.buttons["Try again"].tap()
        let calculatorTab = tab(named: "Calculator", in: app)
        XCTAssertTrue(waitForSelected(calculatorTab))
        XCTAssertTrue(app.navigationBars["IGC"].waitForExistence(timeout: 6))
        XCTAssertTrue(
            app.descendants(matching: .any)["calculator.appStatus"]
                .waitForExistence(timeout: 3)
        )
        XCTAssertTrue(app.staticTexts["All app data deleted"].exists)
        XCTAssertTrue(app.staticTexts["Start with the example"].exists)
    }

    func testAccessibilitySizeDarkEducationAndPrivacyRemainReadable() {
        let app = launch(arguments: ["-uiAccessibilityText"])
        let dismissCoach = app.buttons["calculator.coach.dismiss"]
        scrollToElement(dismissCoach, in: app)
        dismissCoach.tap()
        tab(named: "Settings", in: app).tap()
        selectAppearance("Dark", in: app)

        tab(named: "Education", in: app).tap()
        let calculations = app.buttons["education.calculations"]
        scrollToElement(calculations, in: app)
        calculations.tap()
        XCTAssertTrue(app.navigationBars["How calculations work"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Monthly calculation"].exists)
        scrollToElement(app.staticTexts["Constant assumptions"], in: app)
        XCTAssertTrue(app.staticTexts["Constant assumptions"].exists)

        tab(named: "Settings", in: app).tap()
        let privacy = app.buttons["settings.privacy"]
        scrollToElement(privacy, in: app)
        privacy.tap()
        XCTAssertTrue(app.navigationBars["Privacy"].waitForExistence(timeout: 3))
        scrollToElement(app.staticTexts["Deletion"], in: app)
        XCTAssertTrue(app.staticTexts["Deletion"].exists)
    }

    /// The chart descriptor that provides Describe Chart and the audio graph is only
    /// reachable if VoiceOver can focus the chart itself. While each mark carried its
    /// own accessibility label, focus landed on individual sections and the whole-chart
    /// element was never offered. Assert the chart is one element carrying the summary,
    /// and that per-point elements are gone.
    func testProjectionChartIsOneFocusableElementCarryingItsSummary() {
        let app = launch()
        openProjection(in: app)

        let chart = app.descendants(matching: .any)["projection.chart"]
        scrollToElement(chart, in: app)
        XCTAssertTrue(chart.exists)
        XCTAssertEqual(chart.label, "Balance over time")

        let value = chart.value as? String ?? ""
        XCTAssertTrue(
            value.contains("£10,000.00") && value.contains("15 years"),
            "Chart should speak its factual summary, got: \(value)"
        )

        let perPointElements = app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS %@", "After fees in today’s money")
        )
        for index in 0..<perPointElements.count {
            let label = perPointElements.element(boundBy: index).label
            XCTAssertFalse(
                label.hasPrefix("Year "),
                "Per-point chart element still exposed: \(label)"
            )
        }
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
        XCTAssertTrue(waitForEnabled(saveButton))
        saveButton.tap()

        let nameField = app.textFields["projection.saveSheet.name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        replaceText(in: nameField, with: name)
        app.buttons["projection.saveSheet.confirm"].tap()
        let status = app.descendants(matching: .any)["projection.savedStatus"]
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Saved “\(name)”"].exists)
    }

    private func selectAppearance(_ appearance: String, in app: XCUIApplication) {
        let picker = app.buttons["settings.appearance"]
        scrollToElement(picker, in: app)
        picker.tap()
        let option = app.buttons[appearance].firstMatch
        XCTAssertTrue(option.waitForExistence(timeout: 3))
        option.tap()
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

    private func waitForEnabled(_ element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "enabled == true")
        let expectation = expectation(for: predicate, evaluatedWith: element)
        return XCTWaiter.wait(for: [expectation], timeout: 4) == .completed
    }

    private func waitForSelected(_ element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "selected == true")
        let expectation = expectation(for: predicate, evaluatedWith: element)
        return XCTWaiter.wait(for: [expectation], timeout: 6) == .completed
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
