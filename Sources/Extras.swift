public extension AppReceipt {
    /// Retrieves the original transaction identifier for a product.
    ///
    /// Gets the original transaction ID of the first purchase for the specified product identifier.
    ///
    /// - Parameter productIdentifier: The product identifier to search for.
    /// - Returns: The original transaction identifier, or nil if no purchase exists for the product.
    func originalTransactionIdentifier(ofProductIdentifier productIdentifier: String) -> String? {
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
    func containsPurchase(ofProductIdentifier productIdentifier: String) -> Bool {
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
    func purchases(
        ofProductIdentifier productIdentifier: String,
        sortedBy sort: ((InAppPurchase, InAppPurchase) -> Bool)? = nil
    ) -> [InAppPurchase] {
        let filtered: [InAppPurchase] = purchases.filter {
            return $0.productIdentifier == productIdentifier
        }

        if let sort = sort {
            return filtered.sorted { sort($0, $1) }
        } else {
            return filtered.sorted { $0.purchaseDate > $1.purchaseDate }
        }
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
    func activeAutoRenewableSubscriptionPurchases(
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
    func lastAutoRenewableSubscriptionPurchase(
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
    func hasActiveAutoRenewableSubscription(
        ofProductIdentifier productIdentifier: String,
        forDate date: Date
    ) -> Bool {
        activeAutoRenewableSubscriptionPurchases(
            ofProductIdentifier: productIdentifier,
            forDate: date
        ) != nil
    }

    /// Checks whether the user is eligible for an introductory offer in a subscription group.
    ///
    /// Determines if the user has never purchased any product in the specified subscription group,
    /// making them eligible for an introductory offer.
    ///
    /// - Parameter group: A set of product identifiers in the subscription group.
    /// - Returns: `true` if the user is eligible for any product in the group, `false` otherwise.
    func isEligibleForIntroductoryOffer(for group: Set<String>) -> Bool {
        for product in group {
            if isEligibleForIntroductoryOffer(for: product) {
                return true
            }
        }

        return false
    }

    /// Checks whether the user is eligible for an introductory offer for a specific product.
    ///
    /// Determines if the user has never purchased or trialed the specified product,
    /// making them eligible for an introductory offer.
    ///
    /// - Parameter productIdentifier: The product identifier to check eligibility for.
    /// - Returns: `true` if the user is eligible for an introductory offer, `false` otherwise.
    func isEligibleForIntroductoryOffer(for productIdentifier: String) -> Bool {
        let array = purchases
            .filter { $0.subscriptionTrialPeriod || $0.subscriptionIntroductoryPricePeriod }
            .filter { $0.productIdentifier == productIdentifier }

        return array.isEmpty
    }
}

#if canImport(StoreKit)

import Foundation
@preconcurrency import StoreKit

public extension AppReceipt {
    /// Requests a refresh of the app receipt from the App Store.
    ///
    /// Initiates an asynchronous receipt refresh request using StoreKit.
    /// This is useful when you need to update the local receipt with new purchase information.
    ///
    /// - Throws: An error if the receipt refresh request fails.
    static func refresh() async throws {
        let request = SKReceiptRefreshRequest()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                let delegate = RefreshDelegate(continuation: continuation)
                request.delegate = delegate

                objc_setAssociatedObject(request, &RefreshDelegate.associatedKey, delegate, .OBJC_ASSOCIATION_RETAIN)

                request.start()
            }
        } onCancel: {
            request.cancel()
        }
    }
}

private final class RefreshDelegate: NSObject, SKRequestDelegate, @unchecked Sendable {
    nonisolated(unsafe) static var associatedKey: UInt8 = 0

    private let lock = NSLock()
    private var continuation: CheckedContinuation<Void, Error>?

    init(continuation: CheckedContinuation<Void, Error>) {
        self.continuation = continuation
        super.init()
    }

    func requestDidFinish(_ request: SKRequest) {
        cleanupAndResume(request: request, result: .success(()))
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        cleanupAndResume(request: request, result: .failure(error))
    }

    private func cleanupAndResume(request: SKRequest, result: Result<Void, Error>) {
        objc_setAssociatedObject(request, &Self.associatedKey, nil, .OBJC_ASSOCIATION_RETAIN)

        let cont: CheckedContinuation<Void, Error>? = lock.withLock {
            let c = continuation
            continuation = nil
            return c
        }

        switch result {
        case .success:
            cont?.resume()
        case .failure(let error):
            cont?.resume(throwing: error)
        }
    }
}

#endif

public extension Bundle {
}
