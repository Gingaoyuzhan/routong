import SwiftUI

struct CreateContractView: View {
    @ObservedObject var viewModel: ContractViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var pledgeAmount: Double = 100  // 押注金额
    @State private var deadline = Date().addingTimeInterval(86400 * 7)
    @State private var verificationType: VerificationType = .photo

    // 社死对象
    @State private var shameRelationship: ShameRelationship = .ex
    @State private var shamePhone = ""
    @State private var currentStep = 0

    // 钱包状态
    @StateObject private var paymentVM = PaymentViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                RTTheme.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: RTTheme.Spacing.lg) {
                        // Progress indicator
                        ProgressIndicator(current: currentStep, total: 3)
                            .padding(.top, RTTheme.Spacing.md)

                        // Step content
                        switch currentStep {
                        case 0:
                            taskInfoStep
                        case 1:
                            pledgeStep
                        case 2:
                            shameTargetStep
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal, RTTheme.Spacing.lg)
                    .padding(.bottom, 100)
                }

                // Bottom buttons
                VStack {
                    Spacer()
                    bottomButtons
                }
            }
            .navigationTitle(stepTitle)
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
        }
    }

    // MARK: - Step 1: Task Info
    private var taskInfoStep: some View {
        VStack(alignment: .leading, spacing: RTTheme.Spacing.lg) {
            // Header
            VStack(alignment: .leading, spacing: RTTheme.Spacing.xs) {
                Text("你要挑战什么？")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(RTTheme.Colors.textPrimary)
                Text("设定一个明确的目标")
                    .font(.system(size: 15))
                    .foregroundStyle(RTTheme.Colors.textSecondary)
            }

            // Title input
            VStack(alignment: .leading, spacing: RTTheme.Spacing.sm) {
                Text("任务标题")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(RTTheme.Colors.textTertiary)

                TextField("", text: $title, prompt: Text("例如：每天晨跑5公里").foregroundStyle(RTTheme.Colors.textTertiary))
                    .font(.system(size: 17))
                    .foregroundStyle(RTTheme.Colors.textPrimary)
                    .padding(RTTheme.Spacing.md)
                    .background(RTTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
            }

            // Description input
            VStack(alignment: .leading, spacing: RTTheme.Spacing.sm) {
                Text("任务描述（可选）")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(RTTheme.Colors.textTertiary)

                TextField("", text: $description, prompt: Text("详细描述你的目标...").foregroundStyle(RTTheme.Colors.textTertiary), axis: .vertical)
                    .font(.system(size: 17))
                    .foregroundStyle(RTTheme.Colors.textPrimary)
                    .lineLimit(3...6)
                    .padding(RTTheme.Spacing.md)
                    .background(RTTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
            }

            // Verification type
            VStack(alignment: .leading, spacing: RTTheme.Spacing.sm) {
                Text("验证方式")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(RTTheme.Colors.textTertiary)

                HStack(spacing: RTTheme.Spacing.sm) {
                    ForEach(VerificationType.allCases, id: \.self) { type in
                        VerificationTypeButton(
                            type: type,
                            isSelected: verificationType == type
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                verificationType = type
                            }
                        }
                    }
                }
            }

            // Deadline
            VStack(alignment: .leading, spacing: RTTheme.Spacing.sm) {
                Text("截止时间")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(RTTheme.Colors.textTertiary)

                DatePicker("", selection: $deadline, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(RTTheme.Colors.primary)
                    .colorScheme(.dark)
            }
        }
    }

    // MARK: - Step 2: Pledge
    private var pledgeStep: some View {
        VStack(spacing: RTTheme.Spacing.xl) {
            // Header
            VStack(spacing: RTTheme.Spacing.xs) {
                Text("你敢押多少？")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(RTTheme.Colors.textPrimary)
                Text("金额越大，动力越足")
                    .font(.system(size: 15))
                    .foregroundStyle(RTTheme.Colors.textSecondary)
            }

            // Amount display
            VStack(spacing: RTTheme.Spacing.sm) {
                RTAmountDisplay(amount: Int(pledgeAmount))

                Text("失败就没了")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(RTTheme.Colors.danger)
            }
            .padding(.vertical, RTTheme.Spacing.xl)

            // Preset amounts
            HStack(spacing: RTTheme.Spacing.sm) {
                ForEach([50, 100, 200, 500], id: \.self) { amount in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            pledgeAmount = Double(amount)
                        }
                    } label: {
                        Text("¥\(amount)")
                            .font(.system(size: 15, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RTTheme.Spacing.md)
                            .background(
                                Int(pledgeAmount) == amount
                                    ? RTTheme.Colors.primary.opacity(0.2)
                                    : RTTheme.Colors.surface
                            )
                            .foregroundStyle(
                                Int(pledgeAmount) == amount
                                    ? RTTheme.Colors.primary
                                    : RTTheme.Colors.textSecondary
                            )
                            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: RTTheme.Radius.md)
                                    .stroke(
                                        Int(pledgeAmount) == amount
                                            ? RTTheme.Colors.primary
                                            : Color.clear,
                                        lineWidth: 1
                                    )
                            )
                    }
                }
            }

            // Slider
            VStack(spacing: RTTheme.Spacing.sm) {
                Slider(value: $pledgeAmount, in: 50...500, step: 10)
                    .tint(RTTheme.Colors.primary)

                HStack {
                    Text("¥50")
                    Spacer()
                    Text("¥500")
                }
                .font(.system(size: 12))
                .foregroundStyle(RTTheme.Colors.textTertiary)
            }
        }
    }

    // MARK: - Step 3: Shame Target
    private var shameTargetStep: some View {
        VStack(alignment: .leading, spacing: RTTheme.Spacing.lg) {
            // Header
            VStack(alignment: .leading, spacing: RTTheme.Spacing.xs) {
                Text("谁来见证你的失败？")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(RTTheme.Colors.textPrimary)
                Text("失败后，Ta会收到一条短信通知 📱")
                    .font(.system(size: 15))
                    .foregroundStyle(RTTheme.Colors.textSecondary)
            }

            // Relationship selection
            VStack(alignment: .leading, spacing: RTTheme.Spacing.sm) {
                Text("选择社死对象")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(RTTheme.Colors.textTertiary)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: RTTheme.Spacing.sm) {
                    ForEach(ShameRelationship.allCases, id: \.self) { relationship in
                        ShameRelationshipCard(
                            relationship: relationship,
                            isSelected: shameRelationship == relationship
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                shameRelationship = relationship
                            }
                        }
                    }
                }
            }

            // Phone input
            VStack(alignment: .leading, spacing: RTTheme.Spacing.sm) {
                Text("\(shameRelationship.title)的手机号")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(RTTheme.Colors.textTertiary)

                HStack(spacing: RTTheme.Spacing.sm) {
                    Image(systemName: "phone.fill")
                        .foregroundStyle(RTTheme.Colors.textTertiary)
                        .frame(width: 24)

                    TextField("", text: $shamePhone, prompt: Text("输入手机号").foregroundStyle(RTTheme.Colors.textTertiary))
                        .keyboardType(.phonePad)
                        .font(.system(size: 17))
                        .foregroundStyle(RTTheme.Colors.textPrimary)
                }
                .padding(RTTheme.Spacing.md)
                .background(RTTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: RTTheme.Radius.md)
                        .stroke(shamePhone.isEmpty ? Color.white.opacity(0.1) : RTTheme.Colors.primary.opacity(0.5), lineWidth: 1)
                )
            }

            // Warning card
            RTCard {
                HStack(spacing: RTTheme.Spacing.md) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(RTTheme.Colors.warning)

                    VStack(alignment: .leading, spacing: RTTheme.Spacing.xs) {
                        Text("社死预警")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(RTTheme.Colors.textPrimary)
                        Text(shameRelationship.description)
                            .font(.system(size: 13))
                            .foregroundStyle(RTTheme.Colors.textSecondary)
                    }
                }
            }
        }
    }

    // MARK: - Bottom Buttons
    private var bottomButtons: some View {
        HStack(spacing: RTTheme.Spacing.md) {
            if currentStep > 0 {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        currentStep -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 56, height: 56)
                        .background(RTTheme.Colors.surface)
                        .foregroundStyle(RTTheme.Colors.textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                }
            }

            Button {
                if currentStep < 2 {
                    withAnimation(.spring(response: 0.3)) {
                        currentStep += 1
                    }
                } else {
                    createContract()
                }
            } label: {
                HStack {
                    Text(currentStep < 2 ? "下一步" : "立下契约")
                        .font(.system(size: 18, weight: .bold))
                    if currentStep == 2 {
                        Image(systemName: "flame.fill")
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AnyShapeStyle(canProceed ? RTTheme.Colors.primaryGradient : LinearGradient(colors: [RTTheme.Colors.surfaceElevated], startPoint: .top, endPoint: .bottom)))
                .foregroundStyle(canProceed ? .white : RTTheme.Colors.textTertiary)
                .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
            }
            .disabled(!canProceed)
        }
        .padding(RTTheme.Spacing.lg)
        .background(
            RTTheme.Colors.background
                .shadow(color: .black.opacity(0.3), radius: 20, y: -10)
        )
    }

    // MARK: - Helpers
    private var stepTitle: String {
        switch currentStep {
        case 0: return "创建契约"
        case 1: return "设定赌注"
        case 2: return "社死对象"
        default: return ""
        }
    }

    private var canProceed: Bool {
        switch currentStep {
        case 0: return !title.isEmpty
        case 1: return pledgeAmount >= 50
        case 2: return isValidPhoneNumber(shamePhone)
        default: return false
        }
    }

    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let pattern = "^1[3-9]\\d{9}$"
        return phone.range(of: pattern, options: .regularExpression) != nil
    }

    private func createContract() {
        let contract = Contract(
            id: UUID().uuidString,
            userId: "",
            title: title,
            description: description,
            pledgeAmount: Decimal(pledgeAmount),
            deadline: deadline,
            verificationType: verificationType,
            status: .pending,
            shameTarget: ShameTarget(
                name: shameRelationship.title,
                phone: shamePhone,
                relationship: shameRelationship
            ),
            createdAt: Date()
        )

        Task {
            if await viewModel.createContract(contract) {
                dismiss()
            }
        }
    }
}

// MARK: - Supporting Views

struct ProgressIndicator: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: RTTheme.Spacing.sm) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? RTTheme.Colors.primary : RTTheme.Colors.surface)
                    .frame(height: 4)
            }
        }
    }
}

struct VerificationTypeButton: View {
    let type: VerificationType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: RTTheme.Spacing.sm) {
                Image(systemName: type.icon)
                    .font(.system(size: 24))
                Text(type.displayName)
                    .font(.system(size: 13, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, RTTheme.Spacing.md)
            .background(isSelected ? RTTheme.Colors.primary.opacity(0.2) : RTTheme.Colors.surface)
            .foregroundStyle(isSelected ? RTTheme.Colors.primary : RTTheme.Colors.textSecondary)
            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: RTTheme.Radius.md)
                    .stroke(isSelected ? RTTheme.Colors.primary : Color.clear, lineWidth: 1)
            )
        }
    }
}

struct ShameRelationshipCard: View {
    let relationship: ShameRelationship
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: RTTheme.Spacing.sm) {
                Image(systemName: relationship.icon)
                    .font(.system(size: 28))
                Text(relationship.title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, RTTheme.Spacing.lg)
            .background(isSelected ? RTTheme.Colors.primary.opacity(0.2) : RTTheme.Colors.surface)
            .foregroundStyle(isSelected ? RTTheme.Colors.primary : RTTheme.Colors.textSecondary)
            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: RTTheme.Radius.md)
                    .stroke(isSelected ? RTTheme.Colors.primary : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    CreateContractView(viewModel: ContractViewModel())
}
