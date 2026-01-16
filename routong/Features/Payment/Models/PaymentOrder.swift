import Foundation

// MARK: - 钱包数据
struct Wallet: Codable {
    var balance: Double     // 余额（元）
    var points: Int         // 积分（成功奖励，用来换皮肤）
    var reviveCards: Int    // 复活卡数量
    var isPremium: Bool     // 是否解锁高级功能
    var avatarFrame: String? // 当前头像框

    static let empty = Wallet(balance: 0, points: 0, reviveCards: 0, isPremium: false, avatarFrame: nil)
}

// MARK: - 充值金额选项（苹果内购）
struct RechargeOption: Identifiable {
    let id: String
    let productID: IAPProductID
    let isPopular: Bool
    let isRecommended: Bool  // 推荐小额尝试

    var amount: Double { productID.amount }
    var actualAmount: Double { productID.actualAmount }

    static let options: [RechargeOption] = [
        RechargeOption(id: "1", productID: .recharge6, isPopular: false, isRecommended: true),
        RechargeOption(id: "2", productID: .recharge18, isPopular: true, isRecommended: true),
        RechargeOption(id: "3", productID: .recharge30, isPopular: false, isRecommended: false),
        RechargeOption(id: "4", productID: .recharge68, isPopular: false, isRecommended: false),
    ]
}

// MARK: - 支付方式
enum PaymentMethod: String, CaseIterable {
    case applePay = "Apple 内购"

    var icon: String {
        return "apple.logo"
    }
}

// MARK: - 商城道具
struct ShopItem: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let type: ItemType
    let price: Double       // 价格（元）
    let pointsPrice: Int?   // 积分价格（可选）

    enum ItemType: String {
        case reviveCard     // 复活卡
        case premium        // 高级功能
        case avatarFrame    // 头像框
    }

    static let items: [ShopItem] = [
        // 复活卡
        ShopItem(id: "revive_1", name: "复活卡 x1", description: "任务失败时抵消一次", icon: "heart.fill", type: .reviveCard, price: 3, pointsPrice: nil),
        ShopItem(id: "revive_3", name: "复活卡 x3", description: "任务失败时抵消一次", icon: "heart.fill", type: .reviveCard, price: 8, pointsPrice: nil),

        // 高级功能
        ShopItem(id: "premium", name: "高级版", description: "解锁数据分析报表", icon: "chart.bar.fill", type: .premium, price: 30, pointsPrice: nil),

        // 头像框（用积分换）
        ShopItem(id: "frame_fire", name: "烈焰框", description: "燃烧的决心", icon: "flame.fill", type: .avatarFrame, price: 0, pointsPrice: 100),
        ShopItem(id: "frame_gold", name: "黄金框", description: "成功者的荣耀", icon: "crown.fill", type: .avatarFrame, price: 0, pointsPrice: 200),
        ShopItem(id: "frame_diamond", name: "钻石框", description: "传说中的坚持者", icon: "diamond.fill", type: .avatarFrame, price: 0, pointsPrice: 500),
    ]
}

// MARK: - 交易记录
struct Transaction: Codable, Identifiable {
    let id: String
    let type: TransactionType
    let amountChange: Double // 余额变化（正数增加，负数减少）
    let pointChange: Int     // 积分变化
    let description: String
    let createdAt: Date
}

enum TransactionType: String, Codable {
    case recharge       // 充值
    case bet            // 押注
    case win            // 成功返还
    case lose           // 失败扣除
    case shopBuy        // 商城购买
    case reward         // 奖励

    var displayName: String {
        switch self {
        case .recharge: return "充值"
        case .bet: return "押注"
        case .win: return "挑战成功"
        case .lose: return "挑战失败"
        case .shopBuy: return "商城购买"
        case .reward: return "奖励"
        }
    }

    var icon: String {
        switch self {
        case .recharge: return "plus.circle.fill"
        case .bet: return "lock.fill"
        case .win: return "checkmark.circle.fill"
        case .lose: return "xmark.circle.fill"
        case .shopBuy: return "bag.fill"
        case .reward: return "gift.fill"
        }
    }
}
