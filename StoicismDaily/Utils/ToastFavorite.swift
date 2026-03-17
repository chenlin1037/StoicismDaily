import SwiftUI

struct ToastFavorite: View {
    @Binding var isShown: Bool

    var message: String = ""
    var icon: Image = .init(systemName: "checkmark.circle.fill")
    var alignment: Alignment = .top

    var body: some View {
        VStack {
            if isShown {
                HStack(spacing: 8) {
                    icon
                        // .font(.system(size: 20, weight: .semibold))
                        // .foregroundStyle(.green)

                    Text(message)
                        // .font(.subheadline)
                        // .foregroundStyle(.secondary)
                }
                .font(.subheadline)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
        .animation(.easeInOut(duration: 0.2), value: isShown)
    }

    private func alignmentToEdge(_ alignment: Alignment) -> Edge {
        switch alignment {
        case .topLeading, .top, .topTrailing:
            return .top
        case .bottomLeading, .bottom, .bottomTrailing:
            return .bottom
        default:
            return .top
        }
    }
}
