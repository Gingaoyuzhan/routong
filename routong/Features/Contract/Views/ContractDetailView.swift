import SwiftUI

struct ContractDetailView: View {
    let contract: Contract
    @State private var showVerificationSheet = false
    @State private var showSMSPreview = false

    var body: some View {
        ZStack {
            // 危险风格背景
            RTDecorativeBackground(style: .danger)

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: RTTheme.Spacing.lg) {
                    // Header Card
                    headerCard

                    // Info Cards
                    HStack(spacing: RTTheme.Spacing.md) {
                        infoCard(title: "质押金额", icon: "yensign.circle.fill", iconColor: RTTheme.Colors.gold) {
                            Text("¥\(Int(NSDecimalNumber(decimal: contract.pledgeAmount).doubleValue))")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(RTTheme.Colors.gold)
                        }

                        infoCard(title: "剩余时间", icon: "clock.fill", iconColor: isUrgent ? RTTheme.Colors.danger : RTTheme.Colors.primary) {
                            Text(remainingTime)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(isUrgent ? RTTheme.Colors.danger : RTTheme.Colors.textPrimary)
                        }
                    }

                    // Shame Target Card
                    shameTargetCard

                    // Verification Card
                    verificationCard

                    // SMS Preview Card
                    smsPreviewCard

                    // Action Button
                    if contract.status == .active {
                        Button {
                            showVerificationSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("提交验证")
                            }
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RTTheme.Spacing.md)
                            .background(RTTheme.Colors.primaryGradient)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                        }
                    }
                }
                .padding(RTTheme.Spacing.md)
                .padding(.bottom, RTTheme.Spacing.xl)
            }
        }
        .navigationTitle("契约详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(RTTheme.Colors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showVerificationSheet) {
            VerificationView(contract: contract)
        }
    }

    // MARK: - Header Card
    private var headerCard: some View {
        RTCard {
            VStack(alignment: .leading, spacing: RTTheme.Spacing.md) {
                HStack {
                    Text(contract.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(RTTheme.Colors.textPrimary)
                    Spacer()
                    RTStatusBadge(status: contract.status)
                }

                if !contract.description.isEmpty {
                    Text(contract.description)
                        .font(.system(size: 15))
                        .foregroundStyle(RTTheme.Colors.textSecondary)
                }

                HStack(spacing: RTTheme.Spacing.md) {
                    Label(contract.verificationType.displayName, systemImage: contract.verificationType.icon)
                    Text("·")
                    Text("截止 \(contract.deadline, style: .date)")
                }
                .font(.system(size: 13))
                .foregroundStyle(RTTheme.Colors.textTertiary)
            }
        }
    }

    // MARK: - Info Card
    private func infoCard<Content: View>(
        title: String,
        icon: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        RTCard {
            VStack(alignment: .leading, spacing: RTTheme.Spacing.sm) {
                HStack(spacing: RTTheme.Spacing.xs) {
                    Image(systemName: icon)
                        .foregroundStyle(iconColor)
                    Text(title)
                        .foregroundStyle(RTTheme.Colors.textTertiary)
                }
                .font(.system(size: 13))

                content()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Shame Target Card
    private var shameTargetCard: some View {
        RTCard {
            VStack(alignment: .leading, spacing: RTTheme.Spacing.md) {
                HStack(spacing: RTTheme.Spacing.xs) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(RTTheme.Colors.warning)
                    Text("社死对象")
                        .foregroundStyle(RTTheme.Colors.textTertiary)
                }
                .font(.system(size: 13))

                HStack {
                    VStack(alignment: .leading, spacing: RTTheme.Spacing.xs) {
                        HStack(spacing: RTTheme.Spacing.sm) {
                            Image(systemName: contract.shameTarget.relationship.icon)
                                .font(.system(size: 20))
                            Text(contract.shameTarget.relationship.title)
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundStyle(RTTheme.Colors.primary)

                        Text(contract.shameTarget.phone)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundStyle(RTTheme.Colors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "message.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(RTTheme.Colors.primary.opacity(0.3))
                }

                Text("失败后，Ta会收到一条短信通知你的失败 📱")
                    .font(.system(size: 13))
                    .foregroundStyle(RTTheme.Colors.textTertiary)
            }
        }
    }

    // MARK: - Verification Card
    private var verificationCard: some View {
        RTCard {
            VStack(alignment: .leading, spacing: RTTheme.Spacing.md) {
                HStack(spacing: RTTheme.Spacing.xs) {
                    Image(systemName: contract.verificationType.icon)
                        .foregroundStyle(RTTheme.Colors.primary)
                    Text("验证方式")
                        .foregroundStyle(RTTheme.Colors.textTertiary)
                }
                .font(.system(size: 13))

                Text(contract.verificationType.displayName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(RTTheme.Colors.textPrimary)

                Text(verificationDescription)
                    .font(.system(size: 14))
                    .foregroundStyle(RTTheme.Colors.textSecondary)
            }
        }
    }

    // MARK: - SMS Preview Card
    private var smsPreviewCard: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showSMSPreview.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: "envelope.badge.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(RTTheme.Colors.danger)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("预览社死短信")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(RTTheme.Colors.textPrimary)
                        Text("失败后Ta会收到这条短信")
                            .font(.system(size: 12))
                            .foregroundStyle(RTTheme.Colors.textTertiary)
                    }

                    Spacer()

                    Image(systemName: showSMSPreview ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(RTTheme.Colors.textTertiary)
                }
                .padding(RTTheme.Spacing.md)
                .background(RTTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: showSMSPreview ? 0 : RTTheme.Radius.md, style: .continuous))
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: RTTheme.Radius.md, bottomLeadingRadius: showSMSPreview ? 0 : RTTheme.Radius.md, bottomTrailingRadius: showSMSPreview ? 0 : RTTheme.Radius.md, topTrailingRadius: RTTheme.Radius.md))
            }

            if showSMSPreview {
                // SMS Preview Content
                VStack(alignment: .leading, spacing: RTTheme.Spacing.md) {
                    // Phone mockup header
                    HStack {
                        Circle()
                            .fill(RTTheme.Colors.danger)
                            .frame(width: 8, height: 8)
                        Text("短信预览")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(RTTheme.Colors.textTertiary)
                        Spacer()
                        Text("发送至: \(contract.shameTarget.phone)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(RTTheme.Colors.textTertiary)
                    }

                    // SMS bubble
                    VStack(alignment: .leading, spacing: RTTheme.Spacing.sm) {
                        Text("【肉痛App】")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(RTTheme.Colors.primary)

                        Text(smsContent)
                            .font(.system(size: 15))
                            .foregroundStyle(RTTheme.Colors.textPrimary)
                            .lineSpacing(4)
                    }
                    .padding(RTTheme.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RTTheme.Colors.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))

                    // Warning
                    HStack(spacing: RTTheme.Spacing.xs) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                        Text("失败后此短信将自动发送，无法撤回")
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(RTTheme.Colors.warning)
                }
                .padding(RTTheme.Spacing.md)
                .background(RTTheme.Colors.surface.opacity(0.5))
                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: RTTheme.Radius.md, bottomTrailingRadius: RTTheme.Radius.md, topTrailingRadius: 0))
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: RTTheme.Radius.md)
                .stroke(RTTheme.Colors.danger.opacity(0.3), lineWidth: 1)
        )
    }

    private var smsContent: String {
        """
        您好，\(contract.shameTarget.relationship.title)！

        特此通知：有人在「\(contract.title)」的挑战中失败了 🎉

        Ta质押了 ¥\(Int(NSDecimalNumber(decimal: contract.pledgeAmount).doubleValue)) 却没能坚持到底。

        作为Ta的\(contract.shameTarget.relationship.title)，您是第一个知道这个消息的人。

        —— 来自肉痛App，让失败更痛
        """
    }

    // MARK: - Helpers
    private var remainingTime: String {
        let interval = contract.deadline.timeIntervalSinceNow
        if interval <= 0 {
            return "已截止"
        }
        let days = Int(interval / 86400)
        let hours = Int((interval.truncatingRemainder(dividingBy: 86400)) / 3600)
        if days > 0 {
            return "\(days)天\(hours)小时"
        }
        return "\(hours)小时"
    }

    private var isUrgent: Bool {
        contract.deadline.timeIntervalSinceNow < 86400
    }

    private var verificationDescription: String {
        switch contract.verificationType {
        case .photo:
            return "上传现场照片，AI会自动分析图片真实性"
        case .location:
            return "到达指定地点后自动打卡验证"
        case .exercise:
            return "记录运动轨迹，完成指定运动目标"
        }
    }
}

#Preview {
    NavigationStack {
        ContractDetailView(contract: Contract(
            id: "1",
            userId: "user1",
            title: "每天晨跑5公里",
            description: "坚持30天晨跑，锻炼身体，成为更好的自己",
            pledgeAmount: 200,
            deadline: Date().addingTimeInterval(86400 * 7),
            verificationType: .exercise,
            status: .active,
            shameTarget: ShameTarget(name: "前任", phone: "138****8888", relationship: .ex),
            createdAt: Date()
        ))
    }
}
