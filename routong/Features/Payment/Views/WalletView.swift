import SwiftUI

struct WalletView: View {
    @StateObject private var viewModel = PaymentViewModel()
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                RTDecorativeBackground(style: .money)

                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: RTTheme.Spacing.lg) {
                        // 资产卡片
                        assetsCard

                        // Tab切换
                        Picker("", selection: $selectedTab) {
                            Text("充值").tag(0)
                            Text("商城").tag(1)
                            Text("记录").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, RTTheme.Spacing.md)

                        // 内容区域
                        switch selectedTab {
                        case 0:
                            rechargeSection
                        case 1:
                            shopSection
                        default:
                            transactionHistory
                        }
                    }
                    .padding(RTTheme.Spacing.md)
                    .padding(.bottom, RTTheme.Spacing.xl)
                }
                .refreshable {
                    await viewModel.loadWallet()
                }
            }
            .navigationTitle("钱包")
            .toolbarBackground(RTTheme.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await viewModel.loadWallet()
            }
        }
    }

    // MARK: - 资产卡片
    private var assetsCard: some View {
        RTCard(padding: RTTheme.Spacing.lg) {
            VStack(spacing: RTTheme.Spacing.lg) {
                // 余额
                HStack {
                    VStack(alignment: .leading, spacing: RTTheme.Spacing.xs) {
                        HStack(spacing: 4) {
                            Image(systemName: "yensign.circle.fill")
                                .foregroundStyle(RTTheme.Colors.gold)
                            Text("余额")
                                .foregroundStyle(RTTheme.Colors.textSecondary)
                        }
                        .font(.system(size: 14))

                        Text(String(format: "%.2f", NSDecimalNumber(decimal: viewModel.wallet.balance).doubleValue))
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundStyle(RTTheme.Colors.goldGradient)
                    }

                    Spacer()

                    // 复活卡
                    VStack(alignment: .trailing, spacing: RTTheme.Spacing.xs) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(RTTheme.Colors.danger)
                            Text("复活卡")
                                .foregroundStyle(RTTheme.Colors.textSecondary)
                        }
                        .font(.system(size: 14))

                        Text("×\(viewModel.wallet.reviveCards)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(RTTheme.Colors.danger)
                    }
                }

                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)

                // 积分
                HStack {
                    VStack(alignment: .leading, spacing: RTTheme.Spacing.xs) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(RTTheme.Colors.primary)
                            Text("积分")
                                .foregroundStyle(RTTheme.Colors.textSecondary)
                        }
                        .font(.system(size: 14))

                        Text("\(viewModel.wallet.points)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(RTTheme.Colors.primary)
                    }

                    Spacer()

                    // 高级版标识
                    if viewModel.wallet.isPremium {
                        HStack(spacing: 4) {
                            Image(systemName: "crown.fill")
                            Text("高级版")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(RTTheme.Colors.gold)
                        .padding(.horizontal, RTTheme.Spacing.md)
                        .padding(.vertical, RTTheme.Spacing.sm)
                        .background(RTTheme.Colors.gold.opacity(0.2))
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    // MARK: - 充值
    private var rechargeSection: some View {
        VStack(alignment: .leading, spacing: RTTheme.Spacing.md) {
            // 苹果税提示
            appleWarningBanner

            Text("选择金额")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(RTTheme.Colors.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: RTTheme.Spacing.md) {
                ForEach(RechargeOption.options) { option in
                    RechargeOptionCard(
                        option: option,
                        isSelected: viewModel.selectedOption?.id == option.id
                    ) {
                        viewModel.selectedOption = option
                    }
                }
            }

            // 小额推荐提示
            HStack(spacing: RTTheme.Spacing.sm) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(RTTheme.Colors.warning)
                Text("建议先充值小额（¥6或¥18）体验，满意后再充值更多")
                    .font(.system(size: 13))
                    .foregroundStyle(RTTheme.Colors.textSecondary)
            }
            .padding(RTTheme.Spacing.md)
            .background(RTTheme.Colors.warning.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))

            // 充值按钮
            Button {
                viewModel.showAppleWarning = true
            } label: {
                HStack {
                    Image(systemName: "apple.logo")
                    Text("Apple 内购")
                    if let option = viewModel.selectedOption {
                        Text("¥\(Int(option.amount))")
                    }
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, RTTheme.Spacing.md)
                .background(
                    viewModel.selectedOption != nil
                        ? RTTheme.Colors.primary
                        : RTTheme.Colors.surface
                )
                .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.lg))
            }
            .disabled(viewModel.selectedOption == nil)
            .padding(.top, RTTheme.Spacing.md)
        }
        .alert("重要提示", isPresented: $viewModel.showAppleWarning) {
            Button("取消", role: .cancel) { }
            Button("我已了解，继续支付") {
                Task { await viewModel.rechargeWithApplePay() }
            }
        } message: {
            if let option = viewModel.selectedOption {
                Text("Apple Store 将收取 30% 的服务费。\n\n您支付：¥\(Int(option.amount))\n实际到账：¥\(String(format: "%.1f", option.actualAmount))\n\n如申请退款，最多只能退还 70%（¥\(String(format: "%.1f", option.actualAmount))）。\n\n请确认后继续。")
            }
        }
        .alert("支付失败", isPresented: .init(
            get: { viewModel.purchaseError != nil },
            set: { if !$0 { viewModel.purchaseError = nil } }
        )) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(viewModel.purchaseError ?? "")
        }
    }

    // MARK: - 苹果税提示横幅
    private var appleWarningBanner: some View {
        VStack(alignment: .leading, spacing: RTTheme.Spacing.sm) {
            HStack(spacing: RTTheme.Spacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(RTTheme.Colors.warning)
                Text("关于 Apple 内购")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(RTTheme.Colors.textPrimary)
            }

            Text("• Apple 收取 30% 服务费，实际到账为支付金额的 70%\n• 退款时最多只能退还 70%\n• 建议先小额充值体验")
                .font(.system(size: 13))
                .foregroundStyle(RTTheme.Colors.textSecondary)
                .lineSpacing(4)
        }
        .padding(RTTheme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RTTheme.Colors.warning.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: RTTheme.Radius.md)
                .stroke(RTTheme.Colors.warning.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - 商城
    private var shopSection: some View {
        VStack(alignment: .leading, spacing: RTTheme.Spacing.md) {
            // 复活卡区
            Text("复活卡")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(RTTheme.Colors.textPrimary)

            ForEach(ShopItem.items.filter { $0.type == .reviveCard }) { item in
                ShopItemRow(item: item, wallet: viewModel.wallet) {
                    Task { await viewModel.buyItem(item) }
                }
            }

            // 高级功能
            Text("高级功能")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(RTTheme.Colors.textPrimary)
                .padding(.top, RTTheme.Spacing.md)

            ForEach(ShopItem.items.filter { $0.type == .premium }) { item in
                ShopItemRow(item: item, wallet: viewModel.wallet) {
                    Task { await viewModel.buyItem(item) }
                }
            }

            // 头像框（积分兑换）
            Text("头像框（积分兑换）")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(RTTheme.Colors.textPrimary)
                .padding(.top, RTTheme.Spacing.md)

            ForEach(ShopItem.items.filter { $0.type == .avatarFrame }) { item in
                ShopItemRow(item: item, wallet: viewModel.wallet) {
                    Task { await viewModel.buyItem(item) }
                }
            }
        }
    }

    // MARK: - 交易记录
    private var transactionHistory: some View {
        VStack(alignment: .leading, spacing: RTTheme.Spacing.md) {
            Text("交易记录")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(RTTheme.Colors.textPrimary)

            if viewModel.transactions.isEmpty {
                VStack(spacing: RTTheme.Spacing.md) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 40))
                        .foregroundStyle(RTTheme.Colors.textTertiary)
                    Text("暂无交易记录")
                        .font(.system(size: 15))
                        .foregroundStyle(RTTheme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, RTTheme.Spacing.xxl)
            } else {
                VStack(spacing: RTTheme.Spacing.sm) {
                    ForEach(viewModel.transactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
            }
        }
    }
}

// MARK: - 充值金额卡片
struct RechargeOptionCard: View {
    let option: RechargeOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: RTTheme.Spacing.xs) {
                // 标签
                HStack(spacing: 4) {
                    if option.isPopular {
                        Text("热门")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(RTTheme.Colors.danger)
                            .clipShape(Capsule())
                    }
                    if option.isRecommended {
                        Text("推荐")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(RTTheme.Colors.success)
                            .clipShape(Capsule())
                    }
                    if !option.isPopular && !option.isRecommended {
                        Spacer().frame(height: 18)
                    }
                }
                .frame(height: 18)

                Text("¥\(Int(option.amount))")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(isSelected ? RTTheme.Colors.primary : RTTheme.Colors.textPrimary)

                // 实际到账
                Text("到账 ¥\(String(format: "%.1f", option.actualAmount))")
                    .font(.system(size: 12))
                    .foregroundStyle(RTTheme.Colors.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(RTTheme.Spacing.md)
            .background(isSelected ? RTTheme.Colors.primary.opacity(0.15) : RTTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: RTTheme.Radius.lg)
                    .stroke(isSelected ? RTTheme.Colors.primary : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - 商城道具行
struct ShopItemRow: View {
    let item: ShopItem
    let wallet: Wallet
    let action: () -> Void

    private var canAfford: Bool {
        if let pointsPrice = item.pointsPrice, pointsPrice > 0 {
            return wallet.points >= pointsPrice
        }
        return wallet.balance >= item.price
    }

    var body: some View {
        HStack(spacing: RTTheme.Spacing.md) {
            // 图标
            Circle()
                .fill(iconColor.opacity(0.2))
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: item.icon)
                        .font(.system(size: 22))
                        .foregroundStyle(iconColor)
                }

            // 信息
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(RTTheme.Colors.textPrimary)
                Text(item.description)
                    .font(.system(size: 13))
                    .foregroundStyle(RTTheme.Colors.textTertiary)
            }

            Spacer()

            // 价格按钮
            Button(action: action) {
                HStack(spacing: 4) {
                    if let pointsPrice = item.pointsPrice, pointsPrice > 0 {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                        Text("\(pointsPrice)")
                    } else {
                        Text("¥\(Int(item.price))")
                    }
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(canAfford ? .white : RTTheme.Colors.textTertiary)
                .padding(.horizontal, RTTheme.Spacing.md)
                .padding(.vertical, RTTheme.Spacing.sm)
                .background(canAfford ? RTTheme.Colors.primary : RTTheme.Colors.surface)
                .clipShape(Capsule())
            }
            .disabled(!canAfford)
        }
        .padding(RTTheme.Spacing.md)
        .background(RTTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
    }

    private var iconColor: Color {
        switch item.type {
        case .reviveCard: return RTTheme.Colors.danger
        case .premium: return RTTheme.Colors.gold
        case .avatarFrame: return RTTheme.Colors.primary
        }
    }
}

// MARK: - 交易记录行
struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            // 图标
            Circle()
                .fill(iconColor.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: transaction.type.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(iconColor)
                }

            // 信息
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(RTTheme.Colors.textPrimary)
                Text(transaction.createdAt, style: .relative)
                    .font(.system(size: 12))
                    .foregroundStyle(RTTheme.Colors.textTertiary)
            }

            Spacer()

            // 变化
            VStack(alignment: .trailing, spacing: 2) {
                if transaction.amountChange != 0 {
                    let amount = NSDecimalNumber(decimal: transaction.amountChange).doubleValue
                    Text(amount > 0 ? "+¥\(String(format: "%.2f", amount))" : "-¥\(String(format: "%.2f", abs(amount)))")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(amount > 0 ? RTTheme.Colors.success : RTTheme.Colors.danger)
                }

                if transaction.pointChange != 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("+\(transaction.pointChange)")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(RTTheme.Colors.primary)
                }
            }
        }
        .padding(RTTheme.Spacing.md)
        .background(RTTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
    }

    private var iconColor: Color {
        switch transaction.type {
        case .recharge: return RTTheme.Colors.success
        case .bet: return RTTheme.Colors.warning
        case .win: return RTTheme.Colors.success
        case .lose: return RTTheme.Colors.danger
        case .shopBuy: return RTTheme.Colors.primary
        case .reward: return RTTheme.Colors.gold
        }
    }
}

#Preview {
    WalletView()
}
