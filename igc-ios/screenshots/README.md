# App Store screenshots

Generated from the running app by `AppStoreScreenshotTests`, not hand-captured or
mocked up, so a listing image cannot show a state the app does not produce. This is
what surfaced the duplicated percent symbol on the Calculator screen.

| Directory | Device | Pixels | Required |
| --- | --- | --- | --- |
| `iphone-6.9/` | iPhone 17 Pro Max | 1320 × 2868 | Yes |
| `ipad-13/` | iPad Pro 13-inch | 2064 × 2752 | Yes, while the app supports iPad |

Appearance: **dark** (owner decision, 2026-07-31). Status bars are normalised to 09:41
with full signal and a charged battery.

Suggested listing order: `02` headline, `01` calculator, `03` chart, `05` annual
detail, `08` exclusions.

Frame counts differ by device on purpose: a frame that would be pixel-identical to the
previous one is dropped rather than written, because how much fits without scrolling
varies by screen. The 13-inch iPad shows the whole Projection page at once, so it has
no separate `04-assumptions` frame.

## Regenerating

Boot the target simulator, then:

```sh
xcrun simctl ui <udid> appearance dark
xcrun simctl status_bar <udid> override --time "09:41" \
  --cellularMode active --cellularBars 4 --wifiMode active --wifiBars 3 \
  --batteryState charged --batteryLevel 100

TEST_RUNNER_IGC_SCREENSHOTS=1 xcodebuild test \
  -scheme InvestmentGrowthCalculator \
  -destination 'platform=iOS Simulator,id=<udid>' \
  -only-testing:InvestmentGrowthCalculatorUITests/AppStoreScreenshotTests \
  -resultBundlePath /tmp/shots.xcresult

xcrun xcresulttool export attachments --path /tmp/shots.xcresult --output-path /tmp/shots
```

The `TEST_RUNNER_` prefix is required. Without it the variable never reaches the test
process on the simulator, the test skips, and `xcodebuild` still reports
`** TEST SUCCEEDED **` — so check that attachments were actually produced rather than
trusting the exit status.

Attachment filenames in the export are UUIDs; the readable name is in
`manifest.json` under `suggestedHumanReadableName`.
