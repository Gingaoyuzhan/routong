import Foundation

enum Configuration {
    enum Environment {
        case development
        case production
    }

    static let current: Environment = .development

    static var baseURL: String {
        switch current {
        case .development:
            return "https://dev-api.routong.app"
        case .production:
            return "https://api.routong.app"
        }
    }
}
