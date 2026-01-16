import Foundation
import SwiftUI
import Combine
import StoreKit

@MainActor
class PaymentViewModel: ObservableObject {
    @Published var wallet: Wallet = .empty
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var selectedOption: RechargeOption?
    @Published var showAppleWarning = false
    @Published var purchaseError: String?

    private let storeKit = StoreKitManager.shared

    func loadWallet() async {
        isLoading = true
        // 加载StoreKit产品
        await storeKit.loadProducts()

        // TODO: 实际API调用获取用户钱包
        try? await Task.sleep(nanoseconds: 500_000_000)

        // Mock数据
        wallet = Wallet(
            balance: 25.00,
            points: 150,
            reviveCards: 2,
            isPremium: false,
            avatarFrame: nil
        )

        transactions = [
            Transaction(id: "1", type: .recharge, amountChange: 30, pointChange: 0, description: "Apple内购充值", createdAt: Date().addingTimeInterval(-86400)),
            Transaction(id: "2", type: .bet, amountChange: -5, pointChange: 0, description: "押注：每天晨跑", createdAt: Date().addingTimeInterval(-43200)),
            Transaction(id: "3", type: .win, amountChange: 5, pointChange: 10, description: "挑战成功", createdAt: Date().addingTimeInterval(-3600)),
        ]

        isLoading = false
    }

    // 苹果内购充值
    func rechargeWithApplePay() async -> Bool {
        guard let option = selectedOption else { return false }

        // 找到对应的StoreKit产品
        guard let product = storeKit.products.first(where: { $0.id == option.productID.rawValue }) else {
            purchaseError = "产品未找到，请稍后重试"
            return false
        }

        isLoading = true
        let success = await storeKit.purchase(product)

        if success {
            // 充值成功，到账金额为扣除30%后的金额
            let actualAmount = option.actualAmount
            wallet.balance += actualAmount

            transactions.insert(
                Transaction(
                    id: UUID().uuidString,
                    type: .recharge,
                    amountChange: actualAmount,
                    pointChange: 0,
                    description: "Apple内购充值（实付¥\(Int(option.amount))）",
                    createdAt: Date()
                ),
                at: 0
            )

            selectedOption = nil
        } else if case .failed(let error) = storeKit.purchaseState {
            purchaseError = error
        }

        isLoading = false
        return success
    }

    // 押注
    func placeBet(amount: Double, taskTitle: String) async -> Bool {
        guard wallet.balance >= amount else { return false }

        wallet.balance -= amount
        transactions.insert(
            Transaction(
                id: UUID().uuidString,
                type: .bet,
                amountChange: -amount,
                pointChange: 0,
                description: "押注：\(taskTitle)",
                createdAt: Date()
            ),
            at: 0
        )
        return true
    }

    // 挑战成功 - 返还押金 + 奖励积分
    func challengeSuccess(amount: Double, taskTitle: String) {
        wallet.balance += amount
        wallet.points += 10  // 奖励10积分

        transactions.insert(
            Transaction(
                id: UUID().uuidString,
                type: .win,
                amountChange: amount,
                pointChange: 10,
                description: "挑战成功：\(taskTitle)",
                createdAt: Date()
            ),
            at: 0
        )
    }

    // 挑战失败 - 押金已扣除，可用复活卡
    func challengeFailed(amount: Double, taskTitle: String, useReviveCard: Bool) -> Bool {
        if useReviveCard && wallet.reviveCards > 0 {
            // 使用复活卡，返还押金
            wallet.reviveCards -= 1
            wallet.balance += amount
            return true // 复活成功
        }
        // 失败，押金已扣除
        transactions.insert(
            Transaction(
                id: UUID().uuidString,
                type: .lose,
                amountChange: 0, // 押金在押注时已扣
                pointChange: 0,
                description: "挑战失败：\(taskTitle)",
                createdAt: Date()
            ),
            at: 0
        )
        return false
    }

    // 商城购买
    func buyItem(_ item: ShopItem) async -> Bool {
        // 检查是否用积分购买
        if let pointsPrice = item.pointsPrice, pointsPrice > 0 {
            guard wallet.points >= pointsPrice else { return false }
            wallet.points -= pointsPrice
        } else {
            guard wallet.balance >= item.price else { return false }
            wallet.balance -= item.price
        }

        // 应用道具效果
        switch item.type {
        case .reviveCard:
            let count = item.id.contains("3") ? 3 : 1
            wallet.reviveCards += count
        case .premium:
            wallet.isPremium = true
        case .avatarFrame:
            wallet.avatarFrame = item.id
        }

        transactions.insert(
            Transaction(
                id: UUID().uuidString,
                type: .shopBuy,
                amountChange: item.pointsPrice != nil ? 0 : -item.price,
                pointChange: item.pointsPrice != nil ? -(item.pointsPrice!) : 0,
                description: "购买：\(item.name)",
                createdAt: Date()
            ),
            at: 0
        )

        return true
    }
}
