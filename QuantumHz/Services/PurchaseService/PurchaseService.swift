import Foundation
import StoreKit

@MainActor
final class PurchaseService: ObservableObject {
    static let shared = PurchaseService()

    // NOTE: This identifier must match a real subscription configured in App Store
    // Connect before release. For local testing without App Store Connect, it also
    // matches the product defined in QuantumHz/Configuration.storekit — enable that
    // file under Product > Scheme > Edit Scheme > Run > Options > StoreKit Configuration.
    static let premiumMonthlyProductID = "TOEFLynx.QuantumHz.premium.monthly"

    @Published private(set) var products: [Product] = []
    @Published private(set) var isPurchasing = false
    @Published var errorMessage: String?

    private var updatesTask: Task<Void, Never>?

    private init() {
        updatesTask = listenForTransactionUpdates()
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [Self.premiumMonthlyProductID])
        } catch {
            errorMessage = "Could not load products: \(error.localizedDescription)"
        }
    }

    func purchasePremium() async {
        guard let product = products.first(where: { $0.id == Self.premiumMonthlyProductID }) else {
            errorMessage = "Premium product is not available yet."
            return
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                UserService.shared.updatePremiumStatus(true)
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Purchase is pending approval."
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
    }

    func refreshEntitlements() async {
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            if transaction.productID == Self.premiumMonthlyProductID && transaction.revocationDate == nil {
                UserService.shared.updatePremiumStatus(true)
            }
        }
    }

    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self, let transaction = try? await self.checkVerified(result) else { continue }
                if transaction.productID == Self.premiumMonthlyProductID {
                    let isActive = transaction.revocationDate == nil
                    await MainActor.run {
                        UserService.shared.updatePremiumStatus(isActive)
                    }
                }
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    enum PurchaseError: Error {
        case failedVerification
    }
}
