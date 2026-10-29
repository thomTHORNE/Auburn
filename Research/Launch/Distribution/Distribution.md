Status: Open

# Distribution

Getting Auburn to v0's testers and v1's public through Google Play and the App Store, and what each store requires first.

## Settled

- **v0's Android testers join a Play closed test, and the test counts toward production access.** At least 12, opted in for 14 days in a row. About three weeks separate the end of the test from v1 being public on Play: the 14 days, then an application Google reviews.
- **v0's iPhone testers join through TestFlight.**
- **iOS is built and signed on the MacBook Air M1.** Xcode runs only on macOS.
- **v1 is published on Google Play and the App Store.**

## Open questions

- **The developer account.** Personal or organisation. Third-party guides say an organisation account avoids the closed-test rule; Google's own text was not found to say so. An organisation account needs a registered business.
- **TestFlight testers.** Internal testers must be members of the App Store Connect team and need no review; external testers do not, and the first build of each version passes Beta App Review.
- **A privacy policy.** Whether one is required for an app that collects nothing.

## Findings

- **The closed-test rule.** Personal developer accounts created after 13 November 2023 must run a closed test with at least 12 testers, opted in for the last 14 days continuously, before applying for production. Completing the test does not unlock production: the application is reviewed. Third-party reports, not confirmed by Google, say a tester going inactive restarts the count.
- **The 12 are Android testers.** TestFlight testers are Apple's, and do not count toward Google's rule.
- **TestFlight:** up to 100 internal and 10,000 external testers per app. A build is available to testers for 90 days after upload; a newer build starts its own 90 days.
- **The Apple Developer Program costs 99 USD a year**, the same for individuals and organisations, with TestFlight included. Reported by third parties; Apple's own page was not read.
- **Every Play app files a Health apps declaration**, closed tests included. An app that records workouts declares Activity and Fitness. An app that misses its deadline cannot send changes for review until it files.
- **Every Play app files a Data safety form.** Auburn sends nothing to its developer; it reads the user's own intervals.icu data with the user's own key.
- **The faces, sounds and art are cleared for sale.** Gelasio, Saira and Courier Prime are under the SIL Open Font License. Two recordings are CC0; the third is CC BY 4.0, credited in Settings as its licence requires. The muscle figure is traced from Albinus's plates of 1747, in the public domain.

## Sources

- [Play Console Help — testing requirements for new personal accounts](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en-GB)
- [Play Console Help — Health apps declaration](https://support.google.com/googleplay/android-developer/answer/14738291)
- [The 12-tester rule in practice (third-party)](https://dev.to/theionproject/the-12-tester-rule-that-quietly-adds-two-weeks-to-your-first-google-play-launch-4bp3)
- [App Store Connect Help — TestFlight overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/overview-of-testflight/)
- [Apple Developer Program cost (third-party)](https://studio.adalo.com/blog/apple-developer-program-guide)

## Dependencies

- **Requires:** Name — the store listings carry it.
- **Required by:** Protection — promo codes are the stores'. Website — it links to the listings.
