Status: Open

# Protection

Keeping Auburn from being used in full without being paid for, above all the copies given to creators for review.

## Settled

Nothing yet.

## Open questions

- **The mechanism.** Which of the options below protects the reviewers' copies, and the public's.
- **Whether a reviewer's copy expires.** A creator who keeps using Auburn keeps talking about it; a copy that ends after a month ends that too.
- **What an ended copy does.** Whether it locks with its records kept, or keeps them readable.

## Findings

- **Any check in an app on someone else's phone can be beaten** by someone determined: the clock rolled back, the code patched. Flutter compiles Dart to native code, harder to read than Java and not protected. A check can make casual sharing fail, no more.
- **An app cannot uninstall itself.** Android only lets it ask the user to. Wiping the records when a trial ends removes the user's training history; Play's view of it was not checked. A copy that locks and keeps the records ends the trial as surely.
- **A key unique to each account needs accounts.** Auburn has none, and no server. Issuing and tracking keys means building both; a store account already identifies the buyer.
- **Three mechanisms:**

  | | How | Holds against | Fails against |
  |---|---|---|---|
  | **Expiring build** | An end date built in through `--dart-define`, read as a compile-time constant; one build per reviewer | Casual use | A rolled-back clock; the file forwarded |
  | **Signed offline key** | The developer's private key signs a name and an end date; the app checks it with its public key, offline | Forged keys | A shared key; a rolled-back clock |
  | **Store promo code** | The reviewer installs the public build from the store and redeems a code for the unlock | A leaked file: there is none | The piracy every paid app meets |

- **The store promo code needs no code beyond the billing a paid app needs**, and gives a reviewer the build their viewers buy.
- **Play promo codes:** up to 500 per quarter across an app's one-time products and paid app; unused codes lapse at the quarter's end. Subscriptions have their own 10,000 per product. The App Store's equivalent is not yet looked up.
- **Play sells time-limited access to one-time products** through a rent option with a period the developer sets. Whether a promo code redeems a rental is not known.
- **A TestFlight build stops after 90 days.** A reviewer given a v0 build through TestFlight holds a copy that ends on its own. Whether Play's closed test can end one is not known.
- **Two apps, one full and one trial, move the problem rather than solve it.** The trial still stops after its month by the check the single app would run. The two are separate on the phone, so records do not pass from one to the other without an export and import. Each needs its own listing, reviews and declarations. Play's Repetitive Content policy targets apps with highly similar functionality; whether a lite and full pair falls under it is not stated. A full paid app does take promo codes, so the reviewers' copies would be solved; the public trial would not.
- **A build-time value read through `--dart-define` as a constant removes the code it switches off.** It is the means for a separate build, if one is ever made.

## Sources

- [Play Billing — promo codes](https://developer.android.com/google/play/billing/promo)
- [Play Console Help — create promotions](https://support.google.com/googleplay/android-developer/answer/6321495)
- [Play Billing — purchase options for one-time products](https://developer.android.com/google/play/billing/one-time-product-multi-purchase-options-offers)
- [Play policy — spam and repetitive content](https://support.google.com/googleplay/android-developer/answer/9899034)
- [A developer's lite and pro experience (anecdotal)](https://www.phonearena.com/news/Google-Play-Stores-spam-policies-are-heavily-undefined-and-here-is-the-perfect-example_id145418)
- [App Store Connect Help — TestFlight overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/overview-of-testflight/)

## Dependencies

- **Requires:** Pricing — whether there is an unlock to give. Distribution — promo codes are the stores'.
- **Required by:** Outreach — what a creator is sent.
