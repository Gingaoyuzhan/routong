import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var phone = ""
    @State private var code = ""
    @State private var countdown = 0
    @State private var countdownTimer: Timer?
    @State private var showLogo = false
    @State private var showForm = false

    var body: some View {
        ZStack {
            // Background
            RTTheme.Colors.background
                .ignoresSafeArea()

            // Animated background pattern
            GeometryReader { geo in
                ZStack {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(RTTheme.Colors.primary.opacity(0.1))
                            .frame(width: 300, height: 300)
                            .blur(radius: 60)
                            .offset(
                                x: CGFloat.random(in: -100...100),
                                y: CGFloat(i) * 200 - 100
                            )
                    }
                }
            }

            VStack(spacing: 0) {
                Spacer()

                // Logo Section
                VStack(spacing: RTTheme.Spacing.md) {
                    Text("🥩")
                        .font(.system(size: 100))
                        .scaleEffect(showLogo ? 1 : 0.5)
                        .opacity(showLogo ? 1 : 0)

                    VStack(spacing: RTTheme.Spacing.xs) {
                        Text("肉痛")
                            .font(.system(size: 48, weight: .black))
                            .foregroundStyle(RTTheme.Colors.textPrimary)

                        Text("ROUTONG")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundStyle(RTTheme.Colors.textTertiary)
                            .tracking(8)
                    }
                    .opacity(showLogo ? 1 : 0)
                    .offset(y: showLogo ? 0 : 20)

                    Text("自律的本质是恐惧失去")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(RTTheme.Colors.primary)
                        .opacity(showLogo ? 1 : 0)
                }
                .padding(.bottom, RTTheme.Spacing.xxl)

                // Form Section
                VStack(spacing: RTTheme.Spacing.md) {
                    // Phone Input
                    HStack(spacing: RTTheme.Spacing.sm) {
                        Image(systemName: "phone.fill")
                            .foregroundStyle(RTTheme.Colors.textTertiary)
                            .frame(width: 24)

                        TextField("", text: $phone, prompt: Text("手机号").foregroundStyle(RTTheme.Colors.textTertiary))
                            .keyboardType(.phonePad)
                            .foregroundStyle(RTTheme.Colors.textPrimary)
                    }
                    .padding(RTTheme.Spacing.md)
                    .background(RTTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: RTTheme.Radius.md)
                            .stroke(phone.isEmpty ? Color.white.opacity(0.1) : RTTheme.Colors.primary.opacity(0.5), lineWidth: 1)
                    )

                    // Code Input
                    HStack(spacing: RTTheme.Spacing.sm) {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(RTTheme.Colors.textTertiary)
                            .frame(width: 24)

                        TextField("", text: $code, prompt: Text("验证码").foregroundStyle(RTTheme.Colors.textTertiary))
                            .keyboardType(.numberPad)
                            .foregroundStyle(RTTheme.Colors.textPrimary)

                        Button(action: sendCode) {
                            Text(countdown > 0 ? "\(countdown)s" : "获取")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(canSendCode ? RTTheme.Colors.primary : RTTheme.Colors.textTertiary)
                        }
                        .disabled(!canSendCode)
                    }
                    .padding(RTTheme.Spacing.md)
                    .background(RTTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: RTTheme.Radius.md)
                            .stroke(code.isEmpty ? Color.white.opacity(0.1) : RTTheme.Colors.primary.opacity(0.5), lineWidth: 1)
                    )

                    // Login Button
                    Button(action: login) {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("开始自律")
                                    .font(.system(size: 18, weight: .bold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, RTTheme.Spacing.md)
                        .background(
                            canLogin
                                ? AnyShapeStyle(RTTheme.Colors.primaryGradient)
                                : AnyShapeStyle(RTTheme.Colors.surfaceElevated)
                        )
                        .foregroundStyle(canLogin ? .white : RTTheme.Colors.textTertiary)
                        .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                    }
                    .disabled(!canLogin || authViewModel.isLoading)
                    .padding(.top, RTTheme.Spacing.sm)

                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundStyle(RTTheme.Colors.danger)
                    }
                }
                .padding(.horizontal, RTTheme.Spacing.lg)
                .opacity(showForm ? 1 : 0)
                .offset(y: showForm ? 0 : 30)

                Spacer()

                // Footer
                VStack(spacing: RTTheme.Spacing.sm) {
                    Text("登录即表示同意")
                        .foregroundStyle(RTTheme.Colors.textTertiary)
                    +
                    Text("《用户协议》")
                        .foregroundStyle(RTTheme.Colors.primary)
                    +
                    Text("和")
                        .foregroundStyle(RTTheme.Colors.textTertiary)
                    +
                    Text("《隐私政策》")
                        .foregroundStyle(RTTheme.Colors.primary)
                }
                .font(.system(size: 12))
                .multilineTextAlignment(.center)
                .padding(.bottom, RTTheme.Spacing.xl)
                .opacity(showForm ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showLogo = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4)) {
                showForm = true
            }
        }
    }

    private var canSendCode: Bool {
        isValidPhoneNumber(phone) && countdown == 0
    }

    private var canLogin: Bool {
        isValidPhoneNumber(phone) && code.count >= 4
    }

    private func isValidPhoneNumber(_ phone: String) -> Bool {
        let pattern = "^1[3-9]\\d{9}$"
        return phone.range(of: pattern, options: .regularExpression) != nil
    }

    private func sendCode() {
        countdown = 60
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
                countdownTimer = nil
            }
        }
    }

    private func login() {
        Task {
            await authViewModel.login(phone: phone, code: code)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
