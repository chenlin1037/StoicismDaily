import SwiftUI
import UIKit // 需要导入 UIKit 以使用 UIDevice

extension Color {
    static let stoicAccent = Color(.label).opacity(0.75)
    static let stoicBannerTop = Color(red: 0.2, green: 0.3, blue: 0.5)
    static let stoicBannerBottom = Color(red: 0.1, green: 0.15, blue: 0.3)
}

enum AdaptiveLayout {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    static func quoteFontSize() -> CGFloat {
        isIPad ? 40 : 28
    }

    static func authorFontSize() -> CGFloat {
        isIPad ? 24 : 18
    }

    // 修正了下面的函数
    static func horizontalPadding() -> CGFloat {
        isIPad ? 80 : 32
    }

    static func menuWidth() -> CGFloat {
        isIPad ? 350 : 280
    }
}

struct StoicButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

extension View {
    func stoicButtonStyle() -> some View {
        modifier(StoicButtonModifier())
    }
}