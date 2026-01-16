import Foundation
import StoreKit

/// 内购产品ID
enum IAPProductID: String, CaseIterable {
    case recharge6 = "routong.routong.recharge.6"
    case recharge18 = "routong.routong.recharge.18"
    case recharge30 = "routong.routong.recharge.30"
    case recharge68 = "routong.routong.recharge.68"

    var amount: Double {
        switch self {
        case .recharge6: return 6
        case .recharge18: return 18
        case .recharge30: return 30
        case .recharge68: return 68
        }
    }

    /// 用户实际到账金额（扣除30%苹果税后）
    var actualAmount: Double {
        return amount * 0.7
    }
}

@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    @Published var products: [Product] = []
    @Published var purchaseState: PurchaseState = .idle
    @Published var errorMessage: String?

    enum PurchaseState {
        case idle
        case loading
        case purchasing
        case success(Product)
        case failed(String)
    }

    private var updateListenerTask: Task<Void, Error>?

    private init() {
        updateListenerTask = listenForTransactions()
    }

    deinit {
        updateListenerTask?.cancel()
    }

    /// 加载产品
    func loadProducts() async {
        purchaseState = .loading
        do {
            let productIDs = IAPProductID.allCases.map { $0.rawValue }
            products = try await Product.products(for: productIDs)
            products.sort { $0.price < $1.price }
            purchaseState = .idle
        } catch {
            purchaseState = .failed("加载产品失败: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }

    /// 购买产品
    func purchase(_ product: Product) async -> Bool {
        purchaseState = .purchasing

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)

                // 完成交易
                await transaction.finish()

                purchaseState = .success(product)
                return true

            case .userCancelled:
                purchaseState = .idle
                return false

            case .pending:
                purchaseState = .idle
                errorMessage = "购买待处理，请稍后查看"
                return false

            @unknown default:
                purchaseState = .failed("未知错误")
                return false
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
            errorMessage = error.localizedDescription
            return false
        }
    }

    /// 恢复购买（对于消耗型产品一般不需要，但保留接口）
    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            errorMessage = "恢复购买失败: \(error.localizedDescription)"
        }
    }

    /// 监听交易更新
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            for await result in Transaction.updates {
                do {
                    guard let self = self else { return }
                    let transaction = try self.checkVerifiedSync(result)
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }

    /// 同步验证交易（用于detached task）
    private nonisolated func checkVerifiedSync<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    /// 验证交易
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error, LocalizedError {
    case failedVerification
    case productNotFound

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "交易验证失败"
        case .productNotFound:
            return "产品未找到"
        }
    }
}
