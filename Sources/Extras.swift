extension AppReceipt {
    /// Retrieves the original transaction identifier for a product.
    ///
    /// Gets the original transaction ID of the first purchase for the specified product identifier.
    ///
    /// - Parameter productIdentifier: The product identifier to search for.
    /// - Returns: The original transaction identifier, or nil if no purchase exists for the product.
    public func originalTransactionIdentifier(ofProductIdentifier productIdentifier: String) -> String? {
        purchases(ofProductIdentifier: productIdentifier)
            .first?
            .originalTransactionIdentifier
    }

    /// Checks whether the receipt contains a purchase for a specific product.
    ///
    /// Determines if the receipt includes any purchase record for the specified product identifier.
    ///
    /// - Parameter productIdentifier: The product identifier to search for.
    /// - Returns: `true` if a purchase exists for the product, `false` otherwise.
    public func containsPurchase(ofProductIdentifier productIdentifier: String) -> Bool {
        for item in purchases {
            if item.productIdentifier == productIdentifier {
                return true
            }
        }

        return false
    }

    /// Retrieves all purchases for a specific product identifier.
    ///
    /// Finds all ``InAppPurchase`` records matching the specified product identifier.
    /// By default, results are sorted by purchase date in descending order (most recent first).
    ///
    /// - Parameters:
    ///   - productIdentifier: The product identifier to search for.
    ///   - sort: An optional custom sorting function. If not provided, purchases are sorted by date descending.
    /// - Returns: An array of ``InAppPurchase`` objects for the product, empty if none exist.
    public func purchases(
        ofProductIdentifier productIdentifier: String,
        sortedBy sort: ((InAppPurchase, InAppPurchase) -> Bool)? = nil
    ) -> [InAppPurchase] {
        let filtered: [InAppPurchase] = purchases.filter {
            $0.productIdentifier == productIdentifier
        }

        guard let sort = sort else {
            return filtered.sorted { $0.purchaseDate > $1.purchaseDate }
        }
        return filtered.sorted { sort($0, $1) }
    }

    /// Retrieves an active auto-renewable subscription purchase for a product at a specific date.
    ///
    /// Finds the first active ``InAppPurchase`` for the specified product identifier
    /// that is active on the given date.
    ///
    /// - Parameters:
    ///   - productIdentifier: The product identifier to search for.
    ///   - date: The date to check subscription activity against.
    /// - Returns: An active ``InAppPurchase`` if one exists, nil otherwise.
    public func activeAutoRenewableSubscriptionPurchases(
        ofProductIdentifier productIdentifier: String,
        forDate date: Date
    ) -> InAppPurchase? {
        let filtered = purchases(ofProductIdentifier: productIdentifier)

        for purchase in filtered {
            if purchase.isActiveAutoRenewableSubscription(forDate: date) {
                return purchase
            }
        }

        return nil
    }

    /// Retrieves the most recent auto-renewable subscription purchase for a product.
    ///
    /// Finds the ``InAppPurchase`` for the specified product identifier with the latest
    /// subscription expiration date.
    ///
    /// - Parameter productIdentifier: The product identifier to search for.
    /// - Returns: The most recent ``InAppPurchase`` if one exists, nil otherwise.
    public func lastAutoRenewableSubscriptionPurchase(
        ofProductIdentifier productIdentifier: String
    ) -> InAppPurchase? {
        var purchase: InAppPurchase? = nil
        let filtered = purchases(ofProductIdentifier: productIdentifier)

        var lastInterval: TimeInterval = 0
        for iap in filtered {
            if let thisInterval = iap.subscriptionExpirationDate?.timeIntervalSince1970 {
                if purchase == nil || thisInterval > lastInterval {
                    purchase = iap
                    lastInterval = thisInterval
                }
            }
        }

        return purchase
    }

    /// Checks whether there is an active subscription for a product at a specific date.
    ///
    /// Determines if the receipt contains an active ``InAppPurchase`` for the specified product identifier
    /// that is active on the given date.
    ///
    /// - Parameters:
    ///   - productIdentifier: The product identifier to search for.
    ///   - date: The date to check subscription activity against.
    /// - Returns: `true` if an active subscription exists, `false` otherwise.
    public func hasActiveAutoRenewableSubscription(
        ofProductIdentifier productIdentifier: String,
        forDate date: Date
    ) -> Bool {
        activeAutoRenewableSubscriptionPurchases(
            ofProductIdentifier: productIdentifier,
            forDate: date
        ) != nil
    }

    /// Returns whether the customer is eligible for an introductory offer
    /// within the provided subscription group.
    ///
    /// Returns `true` if the customer has never redeemed an introductory offer
    /// or free trial for any product in the subscription group.
    ///
    /// - Parameter group: A set of product identifiers in the subscription group.
    /// - Returns: `true` if the customer is eligible for an introductory offer
    ///   on any auto-renewable subscription within the subscription group; `false` otherwise.
    public func isEligibleForIntroOffer(for group: Set<String>) -> Bool {
        payload.isEligibleForIntroOffer(for: group)
    }

    /// Returns whether the customer is eligible for an introductory offer
    /// for the specified product.
    ///
    /// Returns `true` if the customer has never redeemed an introductory offer
    /// or free trial for this product.
    ///
    /// - Parameter productIdentifier: The product identifier to check eligibility for.
    /// - Returns: `true` if the customer is eligible for an introductory offer; `false` otherwise.
    public func isEligibleForIntroOffer(for productIdentifier: String) -> Bool {
        payload.isEligibleForIntroOffer(for: productIdentifier)
    }
}

// MARK: - InAppPurchase Refund Status

extension InAppPurchase {
    /// A Boolean value indicating whether the purchase has been canceled or refunded.
    ///
    /// Applies to auto-renewable subscriptions, non-consumable products, and non-renewing subscriptions.
    /// Returns `true` when Apple customer support has canceled the transaction or the customer received a refund.
    ///
    /// - Note: For auto-renewable subscriptions, this also returns `true` when the subscription
    ///   was upgraded to a different product. The local receipt does not include a cancellation reason
    ///   to distinguish refunds from upgrades.
    public var isRefunded: Bool {
        cancellationDate != nil
    }
}

// MARK: - InAppReceiptPayload Intro Offer Eligibility

extension InAppReceiptPayload {
    /// Returns whether the customer is eligible for an introductory offer
    /// within the provided subscription group.
    ///
    /// Returns `true` if the customer has never redeemed an introductory offer
    /// or free trial for any product in the subscription group.
    ///
    /// - Parameter group: A set of product identifiers in the subscription group.
    /// - Returns: `true` if the customer is eligible for an introductory offer
    ///   on any auto-renewable subscription within the subscription group; `false` otherwise.
    public func isEligibleForIntroOffer(for group: Set<String>) -> Bool {
        !purchases.contains {
            group.contains($0.productIdentifier)
                && ($0.subscriptionTrialPeriod || $0.subscriptionIntroductoryPricePeriod)
        }
    }

    /// Returns whether the customer is eligible for an introductory offer
    /// for the specified product.
    ///
    /// Returns `true` if the customer has never redeemed an introductory offer
    /// or free trial for this product.
    ///
    /// - Parameter productIdentifier: The product identifier to check eligibility for.
    /// - Returns: `true` if the customer is eligible for an introductory offer; `false` otherwise.
    public func isEligibleForIntroOffer(for productIdentifier: String) -> Bool {
        !purchases.contains {
            $0.productIdentifier == productIdentifier
                && ($0.subscriptionTrialPeriod || $0.subscriptionIntroductoryPricePeriod)
        }
    }
}

#if canImport(StoreKit)

import Foundation
@preconcurrency import StoreKit

extension AppReceipt {
    /// Requests a refresh of the app receipt from the App Store.
    ///
    /// Initiates an asynchronous receipt refresh request using StoreKit.
    /// This is useful when you need to update the local receipt with new purchase information.
    ///
    /// If a refresh is already in progress, subsequent calls will await the existing
    /// request rather than starting a new one.
    ///
    /// - Throws: An error if the receipt refresh request fails.
    public static func refresh() async throws {
        try await RefreshCoordinator.shared.refresh()
    }
}

private final class RefreshCoordinator: @unchecked Sendable {
    static let shared = RefreshCoordinator()

    private let lock = NSLock()
    private var ongoingTask: Task<Void, Error>?

    func refresh() async throws {
        let task: Task<Void, Error> = lock.withLock {
            if let existing = ongoingTask {
                return existing
            }
            let task = Task {
                defer {
                    self.lock.withLock { self.ongoingTask = nil }
                }
                try await Self.performRefresh()
            }
            ongoingTask = task
            return task
        }
        try await task.value
    }

    private static func performRefresh() async throws {
        let request = SKReceiptRefreshRequest()
        let delegate = RefreshDelegate()

        request.delegate = delegate

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            delegate.setContinuation(continuation)
            request.start()
        }
    }
}

private final class RefreshDelegate: NSObject, SKRequestDelegate, @unchecked Sendable {
    private let lock = NSLock()
    private var continuation: CheckedContinuation<Void, Error>?

    func setContinuation(_ continuation: CheckedContinuation<Void, Error>) {
        lock.withLock {
            self.continuation = continuation
        }
    }

    func requestDidFinish(_: SKRequest) {
        resume(with: .success(()))
    }

    func request(_: SKRequest, didFailWithError error: Error) {
        resume(with: .failure(error))
    }

    private func resume(with result: Result<Void, Error>) {
        let cont: CheckedContinuation<Void, Error>? = lock.withLock {
            let c = continuation
            continuation = nil
            return c
        }

        switch result {
        case .success:
            cont?.resume()
        case let .failure(error):
            cont?.resume(throwing: error)
        }
    }
}

#endif
