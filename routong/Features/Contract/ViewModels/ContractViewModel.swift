import Foundation
import SwiftUI
import Combine

@MainActor
class ContractViewModel: ObservableObject {
    @Published var contracts: [Contract] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadContracts() async {
        isLoading = true
        // TODO: 实际API调用
        try? await Task.sleep(nanoseconds: 500_000_000)

        contracts = [
            Contract(
                id: "1",
                userId: "user1",
                title: "每天晨跑5公里",
                description: "坚持30天晨跑，锻炼身体",
                pledgeAmount: 200,
                deadline: Date().addingTimeInterval(86400 * 30),
                verificationType: .exercise,
                status: .active,
                shameTarget: ShameTarget(name: "前任", phone: "138****8888", relationship: .ex),
                createdAt: Date()
            ),
            Contract(
                id: "2",
                userId: "user1",
                title: "背100个单词",
                description: "每天背单词打卡",
                pledgeAmount: 100,
                deadline: Date().addingTimeInterval(86400 * 7),
                verificationType: .photo,
                status: .active,
                shameTarget: ShameTarget(name: "死对头", phone: "139****9999", relationship: .rival),
                createdAt: Date()
            )
        ]
        isLoading = false
    }

    func createContract(_ contract: Contract) async -> Bool {
        isLoading = true
        // TODO: 实际API调用
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        contracts.insert(contract, at: 0)
        isLoading = false
        return true
    }
}
