import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var contractVM = ContractViewModel()
    @State private var showSettings = false
    @State private var showAbout = false
    @State private var showFeedback = false
    @State private var showEditProfile = false

    var body: some View {
        NavigationStack {
            ZStack {
                // 动态背景
                RTAnimatedBackground()

                ScrollView {
                    VStack(spacing: RTTheme.Spacing.lg) {
                        // Profile Header
                        profileHeader

                        // Stats
                        statsSection

                        // Menu Items
                        menuSection

                        // Logout Button
                        Button {
                            authViewModel.logout()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("退出登录")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RTTheme.Spacing.md)
                            .background(RTTheme.Colors.danger.opacity(0.1))
                            .foregroundStyle(RTTheme.Colors.danger)
                            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                        }
                    }
                    .padding(RTTheme.Spacing.md)
                }
            }
            .navigationTitle("我的")
            .toolbarBackground(RTTheme.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .sheet(isPresented: $showFeedback) {
                FeedbackView()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(authViewModel: authViewModel)
            }
            .task {
                await contractVM.loadContracts()
            }
        }
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        Button {
            showEditProfile = true
        } label: {
            RTCard {
                HStack(spacing: RTTheme.Spacing.md) {
                    // Avatar
                    Circle()
                        .fill(RTTheme.Colors.primaryGradient)
                        .frame(width: 64, height: 64)
                        .overlay {
                            Text("🥩")
                                .font(.system(size: 32))
                        }

                    // Info
                    VStack(alignment: .leading, spacing: RTTheme.Spacing.xs) {
                        Text(authViewModel.currentUser?.nickname ?? "用户")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(RTTheme.Colors.textPrimary)

                        Text(authViewModel.currentUser?.phone ?? "")
                            .font(.system(size: 14))
                            .foregroundStyle(RTTheme.Colors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(RTTheme.Colors.textTertiary)
                }
            }
        }
    }

    // MARK: - Stats Section
    private var statsSection: some View {
        let completed = contractVM.contracts.filter { $0.status == .completed }.count
        let failed = contractVM.contracts.filter { $0.status == .failed || $0.status == .punished }.count
        let active = contractVM.contracts.filter { $0.status == .active }.count

        return HStack(spacing: RTTheme.Spacing.md) {
            statCard(title: "完成契约", value: "\(completed)", icon: "checkmark.circle.fill", color: RTTheme.Colors.success)
            statCard(title: "社死次数", value: "\(failed)", icon: "face.dashed", color: RTTheme.Colors.danger)
            statCard(title: "进行中", value: "\(active)", icon: "clock.fill", color: RTTheme.Colors.primary)
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        RTCard {
            VStack(spacing: RTTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(color)

                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(RTTheme.Colors.textPrimary)

                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(RTTheme.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Menu Section
    private var menuSection: some View {
        VStack(spacing: RTTheme.Spacing.sm) {
            menuItem(icon: "bell.fill", title: "消息通知", color: RTTheme.Colors.warning) {
                // TODO: Notifications
            }
            menuItem(icon: "gearshape.fill", title: "设置", color: RTTheme.Colors.textSecondary) {
                showSettings = true
            }
            menuItem(icon: "questionmark.circle.fill", title: "帮助与反馈", color: RTTheme.Colors.primary) {
                showFeedback = true
            }
            menuItem(icon: "info.circle.fill", title: "关于肉痛", color: RTTheme.Colors.textSecondary) {
                showAbout = true
            }
        }
    }

    private func menuItem(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: RTTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
                    .frame(width: 32)

                Text(title)
                    .font(.system(size: 16))
                    .foregroundStyle(RTTheme.Colors.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(RTTheme.Colors.textTertiary)
            }
            .padding(RTTheme.Spacing.md)
            .background(RTTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pushNotificationEnabled = true

    var body: some View {
        NavigationStack {
            ZStack {
                RTTheme.Colors.background.ignoresSafeArea()

                List {
                    Section {
                        settingRow(icon: "bell.badge", title: "推送通知", toggle: $pushNotificationEnabled)
                        settingRow(icon: "moon.fill", title: "深色模式", subtitle: "跟随系统")
                    }

                    Section {
                        settingRow(icon: "lock.fill", title: "隐私设置")
                        settingRow(icon: "trash", title: "清除缓存", subtitle: "12.3 MB")
                    }

                    Section {
                        settingRow(icon: "doc.text", title: "用户协议")
                        settingRow(icon: "hand.raised.fill", title: "隐私政策")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(RTTheme.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                        .foregroundStyle(RTTheme.Colors.textSecondary)
                }
            }
        }
    }

    private func settingRow(icon: String, title: String, subtitle: String? = nil, toggle: Binding<Bool>? = nil) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(RTTheme.Colors.primary)
                .frame(width: 24)

            Text(title)
                .foregroundStyle(RTTheme.Colors.textPrimary)

            Spacer()

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(RTTheme.Colors.textTertiary)
            }

            if let toggle = toggle {
                Toggle("", isOn: toggle)
                    .tint(RTTheme.Colors.primary)
            }
        }
        .listRowBackground(RTTheme.Colors.surface)
    }
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                RTTheme.Colors.background.ignoresSafeArea()

                VStack(spacing: RTTheme.Spacing.xl) {
                    Spacer()

                    // Logo
                    VStack(spacing: RTTheme.Spacing.md) {
                        Text("🥩")
                            .font(.system(size: 80))

                        Text("肉痛")
                            .font(.system(size: 32, weight: .black))
                            .foregroundStyle(RTTheme.Colors.textPrimary)

                        Text("让失败更痛")
                            .font(.system(size: 16))
                            .foregroundStyle(RTTheme.Colors.textSecondary)
                    }

                    // Version
                    Text("版本 1.0.0")
                        .font(.system(size: 14))
                        .foregroundStyle(RTTheme.Colors.textTertiary)

                    Spacer()

                    // Slogan
                    VStack(spacing: RTTheme.Spacing.sm) {
                        Text("\"不是我们太弱，是代价不够痛\"")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(RTTheme.Colors.textSecondary)

                        Text("基于厌恶损失心理学的反向激励App")
                            .font(.system(size: 13))
                            .foregroundStyle(RTTheme.Colors.textTertiary)
                    }
                    .padding(.bottom, RTTheme.Spacing.xxl)
                }
                .padding(RTTheme.Spacing.lg)
            }
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(RTTheme.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                        .foregroundStyle(RTTheme.Colors.textSecondary)
                }
            }
        }
    }
}

// MARK: - Feedback View
struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                RTTheme.Colors.background.ignoresSafeArea()

                VStack(spacing: RTTheme.Spacing.lg) {
                    Text("有什么想吐槽的？")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(RTTheme.Colors.textPrimary)

                    TextEditor(text: $feedbackText)
                        .scrollContentBackground(.hidden)
                        .background(RTTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                        .frame(height: 200)
                        .overlay(
                            Group {
                                if feedbackText.isEmpty {
                                    Text("说点什么吧，骂我们也行...")
                                        .foregroundStyle(RTTheme.Colors.textTertiary)
                                        .padding(RTTheme.Spacing.md)
                                }
                            },
                            alignment: .topLeading
                        )

                    Button {
                        dismiss()
                    } label: {
                        Text("提交反馈")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RTTheme.Spacing.md)
                            .background(
                                feedbackText.isEmpty
                                    ? AnyShapeStyle(RTTheme.Colors.surface)
                                    : AnyShapeStyle(RTTheme.Colors.primaryGradient)
                            )
                            .foregroundStyle(feedbackText.isEmpty ? RTTheme.Colors.textTertiary : .white)
                            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                    }
                    .disabled(feedbackText.isEmpty)

                    Spacer()
                }
                .padding(RTTheme.Spacing.lg)
            }
            .navigationTitle("帮助与反馈")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(RTTheme.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                        .foregroundStyle(RTTheme.Colors.textSecondary)
                }
            }
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var nickname: String = ""
    @State private var selectedEmoji: String = "🥩"

    private let avatarEmojis = ["🥩", "🔥", "💪", "🎯", "⚡️", "🦁", "🐯", "🦊", "🐻", "🐼", "🐨", "🐸"]

    var body: some View {
        NavigationStack {
            ZStack {
                RTTheme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: RTTheme.Spacing.xl) {
                        // Avatar selection
                        VStack(spacing: RTTheme.Spacing.md) {
                            Text("选择头像")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(RTTheme.Colors.textTertiary)

                            // Current avatar
                            Circle()
                                .fill(RTTheme.Colors.primaryGradient)
                                .frame(width: 100, height: 100)
                                .overlay {
                                    Text(selectedEmoji)
                                        .font(.system(size: 50))
                                }

                            // Emoji grid
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: RTTheme.Spacing.sm) {
                                ForEach(avatarEmojis, id: \.self) { emoji in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedEmoji = emoji
                                        }
                                    } label: {
                                        Text(emoji)
                                            .font(.system(size: 32))
                                            .frame(width: 50, height: 50)
                                            .background(
                                                selectedEmoji == emoji
                                                    ? RTTheme.Colors.primary.opacity(0.3)
                                                    : RTTheme.Colors.surface
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.sm))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: RTTheme.Radius.sm)
                                                    .stroke(
                                                        selectedEmoji == emoji
                                                            ? RTTheme.Colors.primary
                                                            : Color.clear,
                                                        lineWidth: 2
                                                    )
                                            )
                                    }
                                }
                            }
                        }

                        // Nickname input
                        VStack(alignment: .leading, spacing: RTTheme.Spacing.sm) {
                            Text("昵称")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(RTTheme.Colors.textTertiary)

                            TextField("", text: $nickname, prompt: Text("给自己起个霸气的名字").foregroundStyle(RTTheme.Colors.textTertiary))
                                .font(.system(size: 17))
                                .foregroundStyle(RTTheme.Colors.textPrimary)
                                .padding(RTTheme.Spacing.md)
                                .background(RTTheme.Colors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                        }

                        // Phone (read-only)
                        VStack(alignment: .leading, spacing: RTTheme.Spacing.sm) {
                            Text("手机号")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(RTTheme.Colors.textTertiary)

                            HStack {
                                Text(authViewModel.currentUser?.phone ?? "未绑定")
                                    .font(.system(size: 17))
                                    .foregroundStyle(RTTheme.Colors.textSecondary)
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(RTTheme.Colors.textTertiary)
                            }
                            .padding(RTTheme.Spacing.md)
                            .background(RTTheme.Colors.surface.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                        }

                        Spacer(minLength: RTTheme.Spacing.xl)

                        // Save button
                        Button {
                            // TODO: Save profile
                            dismiss()
                        } label: {
                            Text("保存")
                                .font(.system(size: 18, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, RTTheme.Spacing.md)
                                .background(RTTheme.Colors.primaryGradient)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                        }
                    }
                    .padding(RTTheme.Spacing.lg)
                }
            }
            .navigationTitle("编辑资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(RTTheme.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundStyle(RTTheme.Colors.textSecondary)
                }
            }
            .onAppear {
                nickname = authViewModel.currentUser?.nickname ?? ""
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
