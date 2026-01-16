import Foundation

struct VerificationResult: Codable {
    let contractId: String
    let status: VerificationStatus
    let confidence: Double
    let reason: String?
    let verifiedAt: Date
}

enum VerificationStatus: String, Codable {
    case passed
    case failed
    case pending
}
