import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ContractListView()
                .tabItem {
                    Label("契约", systemImage: selectedTab == 0 ? "flag.fill" : "flag")
                }
                .tag(0)

            WalletView()
                .tabItem {
                    Label("钱包", systemImage: selectedTab == 1 ? "wallet.pass.fill" : "wallet.pass")
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    Label("我的", systemImage: selectedTab == 2 ? "person.fill" : "person")
                }
                .tag(2)
        }
        .tint(RTTheme.Colors.primary)
    }
}

#Preview {
    ContentView()
}
