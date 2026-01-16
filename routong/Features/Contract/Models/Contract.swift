import Foundation

struct Contract: Codable, Identifiable {
    let id: String
    let userId: String
    let title: String
    let description: String
    let pledgeAmount: Decimal
    let deadline: Date
    let verificationType: VerificationType
    var status: ContractStatus
    let shameTarget: ShameTarget  // 社死对象
    let createdAt: Date
}

enum VerificationType: String, Codable, CaseIterable {
    case photo
    case location
    case exercise

    var displayName: String {
        switch self {
        case .photo: return "拍照验证"
        case .location: return "位置打卡"
        case .exercise: return "运动轨迹"
        }
    }

    var icon: String {
        switch self {
        case .photo: return "camera.fill"
        case .location: return "location.fill"
        case .exercise: return "figure.run"
        }
    }
}

enum ContractStatus: String, Codable {
    case pending
    case active
    case completed
    case failed
    case punished

    var displayName: String {
        switch self {
        case .pending: return "待生效"
        case .active: return "进行中"
        case .completed: return "已完成"
        case .failed: return "已失败"
        case .punished: return "已社死"
        }
    }
}

// 社死对象 - 失败后会收到短信通知
struct ShameTarget: Codable {
    let name: String           // 称呼（如：前男友、前女友、死对头）
    let phone: String          // 手机号
    let relationship: ShameRelationship  // 关系类型

    var shameMessage: String {
        "【肉痛App】您的\(relationship.reverseTitle) 刚刚在自律挑战中失败了！Ta曾信誓旦旦要完成目标，结果...啪啪打脸 🤡"
    }
}

enum ShameRelationship: String, Codable, CaseIterable {
    case ex           // 前任
    case rival        // 死对头
    case crush        // 暗恋对象
    case boss         // 老板
    case parent       // 父母
    case friend       // 损友

    var title: String {
        switch self {
        case .ex: return "前任"
        case .rival: return "死对头"
        case .crush: return "暗恋对象"
        case .boss: return "老板"
        case .parent: return "爸妈"
        case .friend: return "损友"
        }
    }

    var reverseTitle: String {
        switch self {
        case .ex: return "前任"
        case .rival: return "死对头"
        case .crush: return "暗恋者"
        case .boss: return "下属"
        case .parent: return "孩子"
        case .friend: return "损友"
        }
    }

    var icon: String {
        switch self {
        case .ex: return "heart.slash.fill"
        case .rival: return "figure.boxing"
        case .crush: return "heart.fill"
        case .boss: return "briefcase.fill"
        case .parent: return "house.fill"
        case .friend: return "person.2.fill"
        }
    }

    var description: String {
        switch self {
        case .ex: return "让前任知道你有多废物"
        case .rival: return "给死对头送去快乐"
        case .crush: return "在暗恋对象面前社死"
        case .boss: return "让老板看看你的执行力"
        case .parent: return "让爸妈知道你又摆烂了"
        case .friend: return "给损友提供嘲笑素材"
        }
    }
}
