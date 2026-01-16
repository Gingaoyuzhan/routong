import Foundation

struct User: Codable, Identifiable {
    let id: String
    let phone: String
    let nickname: String
    var balance: Decimal
    var frozenAmount: Decimal
    let createdAt: Date

    var availableBalance: Decimal {
        balance - frozenAmount
    }
}
