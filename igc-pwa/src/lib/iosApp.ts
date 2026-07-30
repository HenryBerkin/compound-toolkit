/**
 * Pointer to the native iOS edition of IGC.
 *
 * The App Store record exists but the listing is not publicly available yet, so
 * `IOS_APP_IS_LIVE` stays false and no link is rendered. Linking earlier would
 * publish a dead destination: an unreleased `id` shows "App Not Available" to
 * everyone except the developer account.
 *
 * To publish the link, flip `IOS_APP_IS_LIVE` to true after confirming the
 * listing loads in a signed-out browser. That is the only change required.
 */

/** App Store Connect Apple ID for Investment Growth Calculator. */
export const IOS_APP_ID = '6796327865';

/** Territory-neutral App Store URL; Apple redirects to the visitor's storefront. */
export const IOS_APP_URL = `https://apps.apple.com/app/id${IOS_APP_ID}`;

/** Set to true only once the public App Store listing is live. */
export const IOS_APP_IS_LIVE = false;
