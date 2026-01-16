import SwiftUI
import Combine

struct ContractListView: View {
    @StateObject private var viewModel = ContractViewModel()
    @State private var showCreateSheet = false
    @State private var tauntIndex = 0

    // 嘲讽文案
    private let taunts = [
        "你到底行不行？",
        "又来立Flag了？这次能坚持几天？",
        "上次的Flag呢？倒了吧？",
        "说到做到？我不信。",
        "嘴上说说谁不会呢",
        "这次又要打脸了吗？",
        "你的前任在等你的失败通知",
        "质押的钱准备好说再见了吗？",
        "三分钟热度选手你好",
        "Flag立得越高，摔得越惨"
    ]

    // 根据状态显示不同文案
    private var dynamicTaunt: String {
        if viewModel.contracts.isEmpty {
            return "连个Flag都不敢立？"
        } else if let urgent = urgentContract, urgent.deadline.timeIntervalSinceNow < 86400 {
            return "还有不到24小时，你慌不慌？"
        } else {
            return taunts[tauntIndex % taunts.count]
        }
    }

    // 最紧急的契约
    private var urgentContract: Contract? {
        viewModel.contracts
            .filter { $0.status == .active }
            .sorted { $0.deadline < $1.deadline }
            .first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // 阴阳怪气背景
                RTDecorativeBackground(style: .taunt)

                if viewModel.isLoading && viewModel.contracts.isEmpty {
                    ProgressView()
                        .tint(RTTheme.Colors.primary)
                } else if viewModel.contracts.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: RTTheme.Spacing.lg) {
                            // Taunt header
                            tauntHeader

                            // Urgent countdown header
                            if let urgent = urgentContract {
                                UrgentCountdownCard(contract: urgent)
                            }

                            // Contract list
                            LazyVStack(spacing: RTTheme.Spacing.md) {
                                ForEach(viewModel.contracts) { contract in
                                    NavigationLink(destination: ContractDetailView(contract: contract)) {
                                        ContractCard(contract: contract)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(RTTheme.Spacing.md)
                    }
                    .refreshable {
                        await viewModel.loadContracts()
                        tauntIndex += 1
                    }
                }
            }
            .navigationTitle("我的契约")
            .toolbarBackground(RTTheme.Colors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(RTTheme.Colors.primary)
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateContractView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadContracts()
            }
        }
    }

    // MARK: - Taunt Header
    private var tauntHeader: some View {
        VStack(spacing: RTTheme.Spacing.sm) {
            Text(dynamicTaunt)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(RTTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)

            // Stats bar
            HStack(spacing: RTTheme.Spacing.lg) {
                statItem(value: "\(viewModel.contracts.filter { $0.status == .completed }.count)", label: "完成", color: RTTheme.Colors.success)

                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1, height: 24)

                statItem(value: "\(viewModel.contracts.filter { $0.status == .failed || $0.status == .punished }.count)", label: "社死", color: RTTheme.Colors.danger)

                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1, height: 24)

                statItem(value: "\(viewModel.contracts.filter { $0.status == .active }.count)", label: "进行中", color: RTTheme.Colors.primary)
            }
            .padding(.vertical, RTTheme.Spacing.sm)
        }
        .padding(RTTheme.Spacing.md)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: RTTheme.Radius.lg)
                .fill(RTTheme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: RTTheme.Radius.lg)
                        .stroke(
                            LinearGradient(
                                colors: [RTTheme.Colors.primary.opacity(0.5), RTTheme.Colors.primary.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }

    private func statItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(RTTheme.Colors.textTertiary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: RTTheme.Spacing.lg) {
            // Animated emoji
            Text("🐔")
                .font(.system(size: 100))

            VStack(spacing: RTTheme.Spacing.sm) {
                Text("连个Flag都不敢立？")
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(RTTheme.Colors.textPrimary)

                Text("怕了？还是根本就不行？")
                    .font(.system(size: 16))
                    .foregroundStyle(RTTheme.Colors.textSecondary)
            }

            // Provocative messages
            VStack(spacing: RTTheme.Spacing.xs) {
                tauntBubble("\"我明天开始减肥\" —— 你，每天")
                tauntBubble("\"这次一定能坚持\" —— 著名遗言")
                tauntBubble("\"下周再说吧\" —— 永远的下周")
            }
            .padding(.vertical, RTTheme.Spacing.md)

            Button {
                showCreateSheet = true
            } label: {
                HStack {
                    Text("我就不信了")
                        .font(.system(size: 18, weight: .black))
                    Image(systemName: "flame.fill")
                }
                .padding(.horizontal, RTTheme.Spacing.xl)
                .padding(.vertical, RTTheme.Spacing.md)
                .background(RTTheme.Colors.primaryGradient)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .padding(.top, RTTheme.Spacing.md)

            Text("质押真金白银，失败通知前任")
                .font(.system(size: 13))
                .foregroundStyle(RTTheme.Colors.textTertiary)
        }
        .padding(RTTheme.Spacing.xl)
    }

    private func tauntBubble(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(RTTheme.Colors.textSecondary)
            .padding(.horizontal, RTTheme.Spacing.md)
            .padding(.vertical, RTTheme.Spacing.sm)
            .background(RTTheme.Colors.surface)
            .clipShape(Capsule())
    }
}

struct ContractCard: View {
    let contract: Contract

    var body: some View {
        VStack(alignment: .leading, spacing: RTTheme.Spacing.md) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: RTTheme.Spacing.xs) {
                    Text(contract.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(RTTheme.Colors.textPrimary)

                    HStack(spacing: RTTheme.Spacing.sm) {
                        Label(contract.verificationType.displayName, systemImage: contract.verificationType.icon)
                        Text("·")
                        Text("剩余\(remainingDays)天")
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(RTTheme.Colors.textSecondary)
                }

                Spacer()

                RTStatusBadge(status: contract.status)
            }

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)

            // Footer
            HStack {
                // Amount
                VStack(alignment: .leading, spacing: 2) {
                    Text("质押")
                        .font(.system(size: 11))
                        .foregroundStyle(RTTheme.Colors.textTertiary)
                    Text("¥\(Int(NSDecimalNumber(decimal: contract.pledgeAmount).doubleValue))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(RTTheme.Colors.gold)
                }

                Spacer()

                // Shame target
                VStack(alignment: .trailing, spacing: 2) {
                    Text("社死对象")
                        .font(.system(size: 11))
                        .foregroundStyle(RTTheme.Colors.textTertiary)
                    HStack(spacing: 4) {
                        Image(systemName: contract.shameTarget.relationship.icon)
                            .font(.system(size: 12))
                        Text(contract.shameTarget.relationship.title)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(RTTheme.Colors.primary)
                }
            }
        }
        .padding(RTTheme.Spacing.md)
        .background(RTTheme.Colors.cardGradient)
        .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: RTTheme.Radius.lg)
                .stroke(
                    contract.status == .active
                        ? RTTheme.Colors.primary.opacity(0.3)
                        : Color.white.opacity(0.05),
                    lineWidth: 1
                )
        )
    }

    private var remainingDays: Int {
        max(0, Int(contract.deadline.timeIntervalSinceNow / 86400))
    }
}

struct RTStatusBadge: View {
    let status: ContractStatus

    var body: some View {
        Text(status.displayName)
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, RTTheme.Spacing.sm)
            .padding(.vertical, RTTheme.Spacing.xs)
            .background(backgroundColor.opacity(0.2))
            .foregroundStyle(backgroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch status {
        case .pending: return .gray
        case .active: return RTTheme.Colors.primary
        case .completed: return RTTheme.Colors.success
        case .failed, .punished: return RTTheme.Colors.danger
        }
    }
}

#Preview {
    ContractListView()
}

// MARK: - Urgent Countdown Card
struct UrgentCountdownCard: View {
    let contract: Contract
    @State private var timeRemaining: TimeInterval = 0
    @State private var isFlashing = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var isUrgent: Bool { timeRemaining < 86400 } // 24小时内
    private var isCritical: Bool { timeRemaining < 3600 } // 1小时内

    var body: some View {
        VStack(spacing: RTTheme.Spacing.md) {
            // Header
            HStack {
                Image(systemName: isCritical ? "flame.fill" : "clock.badge.exclamationmark.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(urgentColor)
                    .symbolEffect(.pulse, isActive: isCritical)

                Text(isCritical ? "紧急！即将社死" : isUrgent ? "距离社死不足24小时" : "最近截止")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(urgentColor)

                Spacer()

                Text(contract.title)
                    .font(.system(size: 13))
                    .foregroundStyle(RTTheme.Colors.textSecondary)
                    .lineLimit(1)
            }

            // Countdown
            HStack(spacing: RTTheme.Spacing.sm) {
                CountdownUnit(value: days, label: "天", color: urgentColor)
                Text(":")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundStyle(urgentColor.opacity(0.5))
                CountdownUnit(value: hours, label: "时", color: urgentColor)
                Text(":")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundStyle(urgentColor.opacity(0.5))
                CountdownUnit(value: minutes, label: "分", color: urgentColor)
                Text(":")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundStyle(urgentColor.opacity(0.5))
                CountdownUnit(value: seconds, label: "秒", color: urgentColor)
            }

            // Warning message
            if isUrgent {
                HStack(spacing: RTTheme.Spacing.xs) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                    Text("失败后 \(contract.shameTarget.relationship.title) 将收到短信通知")
                        .font(.system(size: 12))
                }
                .foregroundStyle(RTTheme.Colors.warning)
                .padding(.horizontal, RTTheme.Spacing.sm)
                .padding(.vertical, RTTheme.Spacing.xs)
                .background(RTTheme.Colors.warning.opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .padding(RTTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: RTTheme.Radius.lg)
                .fill(RTTheme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: RTTheme.Radius.lg)
                        .stroke(urgentColor.opacity(isFlashing ? 0.8 : 0.3), lineWidth: 2)
                )
        )
        .onReceive(timer) { _ in
            timeRemaining = max(0, contract.deadline.timeIntervalSinceNow)
            if isCritical {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isFlashing.toggle()
                }
            }
        }
        .onAppear {
            timeRemaining = max(0, contract.deadline.timeIntervalSinceNow)
        }
    }

    private var urgentColor: Color {
        if isCritical { return RTTheme.Colors.danger }
        if isUrgent { return RTTheme.Colors.warning }
        return RTTheme.Colors.primary
    }

    private var days: Int { Int(timeRemaining / 86400) }
    private var hours: Int { Int((timeRemaining.truncatingRemainder(dividingBy: 86400)) / 3600) }
    private var minutes: Int { Int((timeRemaining.truncatingRemainder(dividingBy: 3600)) / 60) }
    private var seconds: Int { Int(timeRemaining.truncatingRemainder(dividingBy: 60)) }
}

struct CountdownUnit: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%02d", value))
                .font(.system(size: 36, weight: .black, design: .monospaced))
                .foregroundStyle(color)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(RTTheme.Colors.textTertiary)
        }
    }
}
