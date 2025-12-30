# Receipt Fields

ASN.1 field types present in an App Store receipt.

> Based on [Apple's Receipt Fields Reference](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html). Fields not documented by Apple are marked as reserved/unknown.

## App Receipt Fields

### Bundle Identifier

The app's bundle identifier. Corresponds to the value of `CFBundleIdentifier` in the `Info.plist` file. Use this value to validate if the receipt was indeed generated for your app.

- ASN.1 Field Type: 2
- ASN.1 Field Value: UTF8STRING

### App Version

The app's version number. Corresponds to the value of `CFBundleVersion` (in iOS) or `CFBundleShortVersionString` (in macOS) in the `Info.plist` file.

- ASN.1 Field Type: 3
- ASN.1 Field Value: UTF8STRING

### Opaque Value

An opaque value used, with other data, to compute the SHA-1 hash during validation.

- ASN.1 Field Type: 4
- ASN.1 Field Value: A series of bytes

### SHA-1 Hash

A SHA-1 hash, used to validate the receipt.

- ASN.1 Field Type: 5
- ASN.1 Field Value: 20-byte SHA-1 digest

### Environment

The receipt's environment.

- ASN.1 Field Type: 0
- ASN.1 Field Value: UTF8STRING
- Values: `Production`, `ProductionSandbox`, `Sandbox`, `Xcode`

> Not documented by Apple in the original reference. Present in receipts from all environments.

### App Store ID

The App Store ID.

- ASN.1 Field Type: 1
- ASN.1 Field Value: INTEGER

> Not documented by Apple. Only assigned in production.

### Transaction Date

The transaction date.

- ASN.1 Field Type: 8
- ASN.1 Field Value: IA5STRING, interpreted as an RFC 3339 date

> Not documented by Apple.

### Fulfillment Tool Version

The fulfillment tool version.

- ASN.1 Field Type: 9
- ASN.1 Field Value: INTEGER

> Not documented by Apple.

### Age Rating

The age rating of the app.

- ASN.1 Field Type: 10
- ASN.1 Field Value: UTF8STRING

> Not documented by Apple.

### Developer ID

The developer ID.

- ASN.1 Field Type: 11
- ASN.1 Field Value: INTEGER

> Not documented by Apple.

### Receipt Creation Date

The date when the app receipt was created. When validating the receipt, use this date to validate the receipt's signature.

- ASN.1 Field Type: 12
- ASN.1 Field Value: IA5STRING, interpreted as an RFC 3339 date

### Download ID

The download ID.

- ASN.1 Field Type: 15
- ASN.1 Field Value: INTEGER

> Not documented by Apple.

### Installer Version ID

The installer version ID.

- ASN.1 Field Type: 16
- ASN.1 Field Value: INTEGER

> Not documented by Apple.

### In-App Purchase Receipt

The receipt for an in-app purchase. In the ASN.1 file, there are multiple fields that all have type 17, each of which contains a single in-app purchase receipt.

- ASN.1 Field Type: 17
- ASN.1 Field Value: SET of in-app purchase receipt attributes

An empty array is a valid receipt.

### Original Purchase Date

The date when the app was originally purchased.

- ASN.1 Field Type: 18
- ASN.1 Field Value: IA5STRING, interpreted as an RFC 3339 date

### Original Application Version

The version of the app that was originally purchased. Corresponds to the value of `CFBundleVersion` (in iOS) or `CFBundleShortVersionString` (in macOS). In the sandbox environment, the value is always `"1.0"`.

- ASN.1 Field Type: 19
- ASN.1 Field Value: UTF8STRING

### Receipt Expiration Date

The date that the app receipt expires. Only present for apps purchased through the Volume Purchase Program. If this key is not present, the receipt does not expire.

- ASN.1 Field Type: 21
- ASN.1 Field Value: IA5STRING, interpreted as an RFC 3339 date

### Reserved Fields

The following field type IDs are present in receipts but not documented by Apple:

| ASN.1 Field Type | Status |
|-------------------|--------|
| 6 | Reserved |
| 7 | Reserved |
| 13 | Reserved |
| 14 | Reserved |
| 20 | Reserved |
| 25 | Reserved |

---

## In-App Purchase Receipt Fields

### Quantity

The number of items purchased. Corresponds to the `quantity` property of the `SKPayment` object stored in the transaction's `payment` property.

- ASN.1 Field Type: 1701
- ASN.1 Field Value: INTEGER

### Product Identifier

The product identifier of the item that was purchased. Corresponds to the `productIdentifier` property of the `SKPayment` object stored in the transaction's `payment` property.

- ASN.1 Field Type: 1702
- ASN.1 Field Value: UTF8STRING

### Transaction Identifier

The transaction identifier of the item that was purchased. Corresponds to the transaction's `transactionIdentifier` property.

- ASN.1 Field Type: 1703
- ASN.1 Field Value: UTF8STRING

### Purchase Date

The date and time that the item was purchased. Corresponds to the transaction's `transactionDate` property. For auto-renewable subscriptions, this is either the purchase date or the renewal date.

- ASN.1 Field Type: 1704
- ASN.1 Field Value: IA5STRING, interpreted as an RFC 3339 date

### Original Transaction Identifier

For a transaction that restores a previous transaction, the transaction identifier of the original transaction. Otherwise, identical to the transaction identifier. All receipts in a chain of renewals for an auto-renewable subscription have the same value.

- ASN.1 Field Type: 1705
- ASN.1 Field Value: UTF8STRING

### Original Purchase Date

For a transaction that restores a previous transaction, the date of the original transaction. For auto-renewable subscriptions, this indicates the beginning of the subscription period, even if the subscription has been renewed.

- ASN.1 Field Type: 1706
- ASN.1 Field Value: IA5STRING, interpreted as an RFC 3339 date

### Product Type

The type of in-app product.

- ASN.1 Field Type: 1707
- ASN.1 Field Value: INTEGER
- Values: 0 (non-consumable), 1 (consumable), 2 (non-renewing subscription), 3 (auto-renewable subscription)

### Subscription Expiration Date

The expiration date for the subscription. Only present for auto-renewable subscription receipts.

- ASN.1 Field Type: 1708
- ASN.1 Field Value: IA5STRING, interpreted as an RFC 3339 date

### Web Order Line Item ID

The primary key for identifying subscription purchases. This value is a unique ID that identifies purchase events across devices, including subscription renewal purchase events.

- ASN.1 Field Type: 1711
- ASN.1 Field Value: INTEGER

### Cancellation Date

For a transaction that was canceled, the time and date of the cancellation. For an auto-renewable subscription plan that was upgraded, the time and date of the upgrade transaction.

- ASN.1 Field Type: 1712
- ASN.1 Field Value: IA5STRING, interpreted as an RFC 3339 date

Treat a canceled receipt the same as if no purchase had ever been made.

### Subscription Trial Period

Whether the subscription is in the free trial period.

- ASN.1 Field Type: 1713
- ASN.1 Field Value: INTEGER
- Values: 1 (true), 0 (false)

### Subscription Introductory Price Period

Whether an auto-renewable subscription is in the introductory price period.

- ASN.1 Field Type: 1719
- ASN.1 Field Value: INTEGER
- Values: 1 (true), 0 (false)

If a previous subscription period in the receipt has a value of `true` for either the trial period or introductory price period, the user is not eligible for a free trial or introductory price within that subscription group.

### Promotional Offer Identifier

The identifier of the subscription offer redeemed by the user.

- ASN.1 Field Type: 1721
- ASN.1 Field Value: UTF8STRING
