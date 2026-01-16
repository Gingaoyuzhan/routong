import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    @AppStorage("isLoggedIn") var isLoggedIn = false

    func login(phone: String, code: String) async {
        isLoading = true
        errorMessage = nil

        // TODO: 实际API调用
        // 模拟登录
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        currentUser = User(
            id: UUID().uuidString,
            phone: phone,
            nickname: "用户\(phone.suffix(4))",
            balance: 0,
            frozenAmount: 0,
            createdAt: Date()
        )
        isLoggedIn = true
        isLoading = false
    }

    func logout() {
        currentUser = nil
        isLoggedIn = false
    }
}
