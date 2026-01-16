import SwiftUI

// MARK: - 🎉 Success Celebration View
struct RTSuccessCelebration: View {
    @Binding var isShowing: Bool
    let amount: Int

    @State private var particles: [CoinParticle] = []
    @State private var showContent = false
    @State private var scale: CGFloat = 0.5

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Coin particles
            ForEach(particles) { particle in
                Text("🪙")
                    .font(.system(size: particle.size))
                    .position(particle.position)
                    .opacity(particle.opacity)
            }

            // Content
            if showContent {
                VStack(spacing: RTTheme.Spacing.lg) {
                    // Success icon
                    ZStack {
                        Circle()
                            .fill(RTTheme.Colors.success.opacity(0.2))
                            .frame(width: 120, height: 120)

                        Circle()
                            .fill(RTTheme.Colors.success.opacity(0.3))
                            .frame(width: 90, height: 90)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(RTTheme.Colors.success)
                    }
                    .scaleEffect(scale)

                    // Text
                    VStack(spacing: RTTheme.Spacing.sm) {
                        Text("挑战成功！")
                            .font(.system(size: 32, weight: .black))
                            .foregroundStyle(.white)

                        Text("你战胜了自己")
                            .font(.system(size: 18))
                            .foregroundStyle(RTTheme.Colors.textSecondary)
                    }

                    // Amount returned
                    VStack(spacing: RTTheme.Spacing.xs) {
                        Text("质押金已返还")
                            .font(.system(size: 14))
                            .foregroundStyle(RTTheme.Colors.textTertiary)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("+¥")
                                .font(.system(size: 24, weight: .bold))
                            Text("\(amount)")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                        }
                        .foregroundStyle(RTTheme.Colors.goldGradient)
                    }
                    .padding(.top, RTTheme.Spacing.md)

                    // Button
                    Button {
                        dismiss()
                    } label: {
                        Text("太棒了！")
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RTTheme.Spacing.md)
                            .background(RTTheme.Colors.success)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                    }
                    .padding(.horizontal, RTTheme.Spacing.xl)
                    .padding(.top, RTTheme.Spacing.lg)
                }
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // Generate coin particles
        for i in 0..<30 {
            let particle = CoinParticle(
                id: i,
                position: CGPoint(
                    x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                    y: -50
                ),
                size: CGFloat.random(in: 20...40),
                opacity: 1.0
            )
            particles.append(particle)
        }

        // Animate particles falling
        for i in 0..<particles.count {
            let delay = Double(i) * 0.05
            withAnimation(.easeIn(duration: 1.5).delay(delay)) {
                particles[i].position.y = UIScreen.main.bounds.height + 100
                particles[i].position.x += CGFloat.random(in: -50...50)
            }
            withAnimation(.easeIn(duration: 0.5).delay(delay + 1.0)) {
                particles[i].opacity = 0
            }
        }

        // Show content
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3)) {
            showContent = true
            scale = 1.0
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            isShowing = false
        }
    }
}

struct CoinParticle: Identifiable {
    let id: Int
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
}

// MARK: - 💔 Failure View
struct RTFailureCelebration: View {
    @Binding var isShowing: Bool
    let amount: Int
    let shameTarget: ShameTarget

    @State private var showContent = false
    @State private var crackOffset: CGFloat = 0
    @State private var shakeOffset: CGFloat = 0
    @State private var heartScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Background with crack effect
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .overlay(
                    CrackOverlay(offset: crackOffset)
                )

            // Content
            if showContent {
                VStack(spacing: RTTheme.Spacing.lg) {
                    // Broken heart
                    ZStack {
                        Circle()
                            .fill(RTTheme.Colors.danger.opacity(0.2))
                            .frame(width: 120, height: 120)

                        Image(systemName: "heart.slash.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(RTTheme.Colors.danger)
                            .scaleEffect(heartScale)
                    }
                    .offset(x: shakeOffset)

                    // Text
                    VStack(spacing: RTTheme.Spacing.sm) {
                        Text("挑战失败")
                            .font(.system(size: 32, weight: .black))
                            .foregroundStyle(RTTheme.Colors.danger)

                        Text("社死倒计时开始...")
                            .font(.system(size: 18))
                            .foregroundStyle(RTTheme.Colors.textSecondary)
                    }

                    // Amount lost
                    VStack(spacing: RTTheme.Spacing.xs) {
                        Text("质押金已扣除")
                            .font(.system(size: 14))
                            .foregroundStyle(RTTheme.Colors.textTertiary)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("-¥")
                                .font(.system(size: 24, weight: .bold))
                            Text("\(amount)")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                        }
                        .foregroundStyle(RTTheme.Colors.danger)
                    }

                    // SMS notification
                    VStack(spacing: RTTheme.Spacing.sm) {
                        HStack(spacing: RTTheme.Spacing.xs) {
                            Image(systemName: "envelope.fill")
                            Text("短信已发送至")
                        }
                        .font(.system(size: 14))
                        .foregroundStyle(RTTheme.Colors.textTertiary)

                        HStack(spacing: RTTheme.Spacing.sm) {
                            Image(systemName: shameTarget.relationship.icon)
                                .font(.system(size: 20))
                            Text(shameTarget.relationship.title)
                                .font(.system(size: 18, weight: .bold))
                            Text(shameTarget.phone)
                                .font(.system(size: 14, design: .monospaced))
                        }
                        .foregroundStyle(RTTheme.Colors.warning)
                    }
                    .padding(RTTheme.Spacing.md)
                    .background(RTTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))

                    // Button
                    Button {
                        dismiss()
                    } label: {
                        Text("我知道了")
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, RTTheme.Spacing.md)
                            .background(RTTheme.Colors.surface)
                            .foregroundStyle(RTTheme.Colors.textPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
                    }
                    .padding(.horizontal, RTTheme.Spacing.xl)
                    .padding(.top, RTTheme.Spacing.md)
                }
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // Crack animation
        withAnimation(.easeOut(duration: 0.3)) {
            crackOffset = 1.0
        }

        // Shake animation
        withAnimation(.easeInOut(duration: 0.1).repeatCount(5, autoreverses: true).delay(0.3)) {
            shakeOffset = 10
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            shakeOffset = 0
        }

        // Heart pulse
        withAnimation(.easeInOut(duration: 0.3).repeatCount(3, autoreverses: true).delay(0.5)) {
            heartScale = 1.2
        }

        // Show content
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3)) {
            showContent = true
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            isShowing = false
        }
    }
}

struct CrackOverlay: View {
    let offset: CGFloat

    var body: some View {
        GeometryReader { geo in
            Path { path in
                let width = geo.size.width
                let height = geo.size.height

                // Draw crack lines
                path.move(to: CGPoint(x: width * 0.5, y: 0))
                path.addLine(to: CGPoint(x: width * 0.48, y: height * 0.2 * offset))
                path.addLine(to: CGPoint(x: width * 0.52, y: height * 0.35 * offset))
                path.addLine(to: CGPoint(x: width * 0.45, y: height * 0.5 * offset))
                path.addLine(to: CGPoint(x: width * 0.55, y: height * 0.7 * offset))
                path.addLine(to: CGPoint(x: width * 0.5, y: height * offset))
            }
            .stroke(RTTheme.Colors.danger.opacity(0.6), lineWidth: 3)

            // Branch cracks
            Path { path in
                let width = geo.size.width
                let height = geo.size.height

                path.move(to: CGPoint(x: width * 0.48, y: height * 0.2 * offset))
                path.addLine(to: CGPoint(x: width * 0.35, y: height * 0.3 * offset))

                path.move(to: CGPoint(x: width * 0.52, y: height * 0.35 * offset))
                path.addLine(to: CGPoint(x: width * 0.65, y: height * 0.45 * offset))

                path.move(to: CGPoint(x: width * 0.45, y: height * 0.5 * offset))
                path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.55 * offset))
            }
            .stroke(RTTheme.Colors.danger.opacity(0.4), lineWidth: 2)
        }
    }
}

// MARK: - Preview
#Preview("Success") {
    RTSuccessCelebration(isShowing: .constant(true), amount: 200)
}

#Preview("Failure") {
    RTFailureCelebration(
        isShowing: .constant(true),
        amount: 200,
        shameTarget: ShameTarget(name: "前任", phone: "138****8888", relationship: .ex)
    )
}
