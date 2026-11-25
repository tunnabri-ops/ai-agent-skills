---
name: app-store-compliance
description: Use when preparing an app for App Store or Google Play review, fixing a store rejection, writing a privacy policy or privacy manifest, choosing in-app purchase or payment flows, or auditing metadata, screenshots, and permissions before submitting a build.
---

# App Store Compliance

Get an app through App Store and Google Play review on the first try, and fix a rejection with the smallest change that addresses the exact reason the reviewer cited. This skill covers the rejection patterns that cause most first-time failures: payments, privacy, misleading metadata, crashes, and incomplete apps. It does not cover marketing, ASO keyword strategy, or pricing strategy.

## Rules That Decide Most Reviews

- Apple requires in-app purchase for digital goods consumed in the app: premium features, subscriptions, virtual currency, and unlocked content. A link or button that sends users to an external website to pay for digital goods is a rejection (App Store Review Guideline 3.1.1), unless the app qualifies for a specific exception such as a reader app.
- Google Play requires Google Play Billing for digital goods sold in the app. Physical goods, services consumed outside the app, and donations use other payment methods; check the current Play payments policy before choosing.
- Never collect data the app does not use. Every permission, SDK, and data field in the privacy label must match what the code actually does. Reviewers test permissions and read the privacy answers.
- Metadata must match the app. Screenshots, description, title, and category must show the real app, not a mockup, a competitor, or a feature that is not in the build.
- The app must work on the reviewer's device: no crash on launch, no blank screen, no login wall with no working demo account, no placeholder text, and no dead button.

## Workflow

1. Identify the target stores. List Apple App Store, Google Play, or both, plus the minimum OS versions the build supports.
2. Audit payments. List every thing the user can pay for, and map each one to in-app purchase / Play Billing, or to an allowed external payment. Remove or rework any external payment link for digital goods.
3. Audit data collection. List every permission (camera, location, contacts, microphone, tracking), every third-party SDK (analytics, ads, crash reporting), and every data type sent off the device. Delete anything unused, then write the privacy answers from that list.
4. Audit metadata. Read the app name, subtitle, description, keywords, screenshots, and preview video. Flag any claim the build cannot prove: "free" when a paywall appears at launch, "offline" when the app needs a network, or a screenshot showing a feature that is not shipped.
5. Test the exact submitted build. Install the release build (not a debug build) on a clean device, on the lowest supported OS version, with no developer account signed in. Launch it, complete onboarding, exercise the main flow, and test every purchase and restore path.
6. Provide reviewer access. Add a demo account with real content in the App Store Connect "Demo Account" field and in the Play Console "App access" section. If the app needs a QR code, a hardware device, or a specific location to work, explain that in the review notes.
7. Submit, then read the rejection exactly. Copy the guideline number and the reviewer's sentence into the fix plan. Fix only what was cited, retest the cited flow, and reply in Resolution Center / Play Console with what changed and where to find it.

## Pre-Submit Checklist

- Release build installs and launches on a clean device, on the lowest supported OS, with no crash in the first 60 seconds.
- No placeholder text, lorem ipsum, dead buttons, or empty screens.
- Every purchase completes, restores after reinstall, and shows a working restore-purchases control where the store requires one.
- Subscriptions show price, duration, renewal terms, and a link to manage or cancel, before the user pays.
- No external payment link, web-view checkout, or "pay on our website" prompt for digital goods.
- Privacy policy URL loads, names the developer, lists collected data, and matches the privacy label answers.
- Apple Privacy Manifest (`PrivacyInfo.xcprivacy`) lists every required reason API (UserDefaults, file timestamps, system boot time, disk space) and every collected data type used by the app and its SDKs.
- Google Play Data safety form lists the same data types the app sends, including data collected by SDKs, and states whether data is encrypted in transit and whether users can request deletion.
- App Tracking Transparency prompt appears only when tracking actually happens, and the app still works when the user declines tracking.
- Permissions are requested in context, with a plain-language reason, and the app still works when the user denies a non-essential one.
- Screenshots are taken from the submitted build, show the real UI, and contain no other app's branding or misleading claims.
- Age rating questionnaire answers match the actual content: user content, chat, ads, and web views included.
- Support URL and contact email work, and the app has a visible way to report abuse or block another user when it has user-generated content.
- Version number and build number are bumped from the previous submission, and release notes describe what changed.

## Privacy Manifest and Labels

Apple requires a privacy manifest for the app and for third-party SDKs that collect data. The manifest is a file, not a form: it lives in the app bundle as `PrivacyInfo.xcprivacy` and lists `NSPrivacyCollectedDataTypes`, `NSPrivacyAccessedAPITypes`, and `NSPrivacyTrackingDomains`.

Example manifest entries for an app that stores a user ID for sign-in and uses UserDefaults for settings:

```xml
<key>NSPrivacyCollectedDataTypes</key>
<array>
  <dict>
    <key>NSPrivacyCollectedDataType</key>
    <string>NSPrivacyCollectedDataTypeUserID</string>
    <key>NSPrivacyCollectedDataTypeLinked</key>
    <true/>
    <key>NSPrivacyCollectedDataTypeTracking</key>
    <false/>
    <key>NSPrivacyCollectedDataTypePurposes</key>
    <array>
      <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
    </array>
  </dict>
</array>
<key>NSPrivacyAccessedAPITypes</key>
<array>
  <dict>
    <key>NSPrivacyAccessedAPIType</key>
    <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
    <key>NSPrivacyAccessedAPITypeReasons</key>
    <array>
      <string>CA92.1</string>
    </array>
  </dict>
</array>
```

Google Play has no manifest file: the same facts go in the Data safety form in Play Console. Keep one source of truth — a short data inventory table in the repo — and generate both the manifest and the form answers from it, so the two stores never disagree:

| Data | Collected | Linked to user | Purpose | Shared with |
|------|-----------|----------------|---------|-------------|
| Email | Yes | Yes | Sign-in | No |
| Crash logs | Yes | No | Diagnostics | Crash SDK vendor |
| Location | No | — | — | — |

## Examples

### Example 1: Rejection to fix — external payment link

Input: Apple rejection citing Guideline 3.1.1. The app sells a monthly premium subscription. The paywall has a "Subscribe on our website — 20% cheaper" button that opens Safari to a Stripe checkout page.

Output: the fix, in order:

1. Remove the "Subscribe on our website" button and every mention of web pricing from the app, including the settings screen and FAQ.
2. Add a StoreKit subscription product, for example a monthly auto-renewable subscription at the same price, with the price, duration, and renewal terms shown before purchase.
3. Add a restore-purchases button that calls the StoreKit restore flow and unlocks premium for users who already paid.
4. Test on a sandbox account: purchase, cancel, restore after deleting and reinstalling the app, and confirm premium unlocks each time.
5. Reply in Resolution Center: "Removed the external payment link. Premium is now sold only through in-app purchase (product ID `premium_monthly`). Restore purchases is on the Settings screen."
6. Resubmit with a bumped build number.

### Example 2: Rejection to fix — missing demo account

Input: Apple rejection citing Guideline 2.1, "We were unable to review your app because it requires a login and no demo account was provided." The app is a chat app; sign-up needs an SMS code.

Output: create a demo account that skips SMS verification, seed it with three conversations and ten contacts, put the username and password in the App Store Connect demo-account field, and add a note in the review notes: "Demo account test@example.com / Demo1234 — SMS step is skipped for this account." Do the same in Play Console under App access.

### Example 3: Rejection to fix — privacy label mismatch

Input: Google Play rejection: the Data safety form says "No data collected", but the app includes an analytics SDK that sends the advertising ID and device model.

Output: remove the SDK if analytics is not needed, or update the Data safety form to declare device IDs and app activity, mark data as encrypted in transit, and add a data-deletion link in the store listing. Then rebuild, because the form and the binary are reviewed together.

## Pitfalls

- Do not appeal a rejection by arguing with the guideline. Fix the cited issue, or remove the feature that caused it, then resubmit.
- Do not hide a payment link behind a settings screen, a help article, or a web view. Reviewers find it, and a second rejection for the same issue takes longer.
- Do not copy another app's privacy label or manifest. If the SDK list differs, the label is wrong and the app can be removed after approval.
- Do not submit a build that needs a server, a test device, or a specific account the reviewer cannot reach. If the backend is down during review, the app is rejected for incompleteness.
- Do not use screenshots from a design tool. Reviewers compare them with the running app and reject on mismatch.
- Do not leave a beta, staging, or debug flag in the release build: test banners, mock data switches, and console logging that prints tokens all count against the submission.
- Do not assume approval on one store means approval on the other. Apple and Google have different payment, privacy, and content rules; run the checklist separately for each store.
