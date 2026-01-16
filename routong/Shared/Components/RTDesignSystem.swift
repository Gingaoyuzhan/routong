import SwiftUI

// MARK: - 🎨 RouTong Design System

enum RTTheme {
    // MARK: Colors
    enum Colors {
        // Primary - 肉红色系
        static let primary = Color(hex: "E53935")
        static let primaryLight = Color(hex: "FF6F60")
        static let primaryDark = Color(hex: "AB000D")

        // Background - 深色系
        static let background = Color(hex: "0D0D0D")
        static let surface = Color(hex: "1A1A1A")
        static let surfaceElevated = Color(hex: "252525")

        // Accent - 金色用于金额
        static let gold = Color(hex: "FFD700")
        static let goldLight = Color(hex: "FFEA00")

        // Status
        static let success = Color(hex: "4CAF50")
        static let warning = Color(hex: "FF9800")
        static let danger = Color(hex: "F44336")

        // Text
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.7)
        static let textTertiary = Color.white.opacity(0.5)

        // Gradient
        static let primaryGradient = LinearGradient(
            colors: [primaryLight, primary, primaryDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let goldGradient = LinearGradient(
            colors: [goldLight, gold],
            startPoint: .top,
            endPoint: .bottom
        )

        static let cardGradient = LinearGradient(
            colors: [surfaceElevated, surface],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: Corner Radius
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 9999
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - 🧩 Custom Components

struct RTCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = RTTheme.Spacing.md

    init(padding: CGFloat = RTTheme.Spacing.md, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(RTTheme.Colors.cardGradient)
            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: RTTheme.Radius.lg)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
    }
}

struct RTButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void

    enum ButtonStyle {
        case primary, secondary, danger, ghost
    }

    init(_ title: String, icon: String? = nil, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: RTTheme.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, RTTheme.Spacing.md)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: RTTheme.Radius.md)
                    .stroke(borderColor, lineWidth: style == .ghost ? 1 : 0)
            )
        }
    }

    private var backgroundColor: some ShapeStyle {
        switch style {
        case .primary: return AnyShapeStyle(RTTheme.Colors.primaryGradient)
        case .secondary: return AnyShapeStyle(RTTheme.Colors.surfaceElevated)
        case .danger: return AnyShapeStyle(RTTheme.Colors.danger)
        case .ghost: return AnyShapeStyle(Color.clear)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .danger: return .white
        case .secondary: return RTTheme.Colors.textPrimary
        case .ghost: return RTTheme.Colors.primary
        }
    }

    private var borderColor: Color {
        style == .ghost ? RTTheme.Colors.primary : .clear
    }
}

struct RTTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: RTTheme.Spacing.sm) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundStyle(RTTheme.Colors.textTertiary)
                    .frame(width: 24)
            }
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .foregroundStyle(RTTheme.Colors.textPrimary)
        }
        .padding(RTTheme.Spacing.md)
        .background(RTTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: RTTheme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: RTTheme.Radius.md)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct RTAmountDisplay: View {
    let amount: Int
    var prefix: String = "¥"
    var size: Size = .large

    enum Size {
        case small, medium, large

        var fontSize: CGFloat {
            switch self {
            case .small: return 24
            case .medium: return 36
            case .large: return 56
            }
        }
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text(prefix)
                .font(.system(size: size.fontSize * 0.5, weight: .bold))
            Text("\(amount)")
                .font(.system(size: size.fontSize, weight: .black, design: .rounded))
        }
        .foregroundStyle(RTTheme.Colors.goldGradient)
    }
}

// MARK: - 🎭 View Modifiers

struct RTBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(RTTheme.Colors.background)
    }
}

extension View {
    func rtBackground() -> some View {
        modifier(RTBackgroundModifier())
    }
}

// MARK: - 🌈 Decorative Background
struct RTDecorativeBackground: View {
    var style: Style = .taunt

    enum Style {
        case taunt      // 嘲讽风格
        case money      // 金钱风格
        case danger     // 危险风格
    }

    // 阴阳怪气的文字
    private let tauntTexts = [
        "又来了？", "能行吗", "我不信", "打脸预定",
        "Flag", "倒了吧", "三分钟", "热度",
        "明天再说", "下次一定", "这次不一样", "真的吗",
        "🤡", "😏", "🙄", "💀"
    ]

    private let moneyTexts = [
        "¥", "💰", "钱", "没了", "拜拜",
        "质押", "充值", "余额", "冻结",
        "💸", "🪙", "💵", "📉"
    ]

    private let dangerTexts = [
        "社死", "💀", "完蛋", "GG", "凉凉",
        "短信", "通知", "前任", "尴尬",
        "😱", "💔", "🔔", "📱"
    ]

    private var texts: [String] {
        switch style {
        case .taunt: return tauntTexts
        case .money: return moneyTexts
        case .danger: return dangerTexts
        }
    }

    // 固定位置数据
    private let positions: [(x: CGFloat, y: CGFloat, rotation: Double, size: CGFloat)] = [
        (0.1, 0.15, -15, 18), (0.85, 0.1, 20, 22), (0.3, 0.25, -8, 16),
        (0.7, 0.2, 12, 20), (0.15, 0.4, -20, 24), (0.9, 0.35, 15, 18),
        (0.5, 0.45, -5, 22), (0.25, 0.55, 18, 16), (0.75, 0.5, -12, 20),
        (0.1, 0.65, 8, 18), (0.6, 0.7, -18, 24), (0.4, 0.8, 10, 16),
        (0.85, 0.75, -8, 20), (0.2, 0.85, 15, 22), (0.95, 0.9, -15, 18)
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RTTheme.Colors.background

                // 装饰文字 - 固定位置
                ForEach(0..<positions.count, id: \.self) { index in
                    let pos = positions[index]
                    Text(texts[index % texts.count])
                        .font(.system(size: pos.size, weight: .black))
                        .foregroundStyle(decorColor.opacity(0.15))
                        .rotationEffect(.degrees(pos.rotation))
                        .position(
                            x: geo.size.width * pos.x,
                            y: geo.size.height * pos.y
                        )
                }
            }
        }
        .ignoresSafeArea()
    }

    private var decorColor: Color {
        switch style {
        case .taunt: return RTTheme.Colors.primary
        case .money: return RTTheme.Colors.gold
        case .danger: return RTTheme.Colors.danger
        }
    }
}

// MARK: - 🔥 Animated Background
struct RTAnimatedBackground: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RTTheme.Colors.background

                // 浮动的圆形装饰
                Circle()
                    .fill(RTTheme.Colors.primary.opacity(0.05))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(
                        x: animate ? 50 : -50,
                        y: animate ? -30 : 30
                    )
                    .position(x: geo.size.width * 0.2, y: geo.size.height * 0.3)

                Circle()
                    .fill(RTTheme.Colors.gold.opacity(0.03))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                    .offset(
                        x: animate ? -30 : 30,
                        y: animate ? 20 : -20
                    )
                    .position(x: geo.size.width * 0.8, y: geo.size.height * 0.7)

                // 顶部渐变
                LinearGradient(
                    colors: [
                        RTTheme.Colors.primary.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .center
                )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}
