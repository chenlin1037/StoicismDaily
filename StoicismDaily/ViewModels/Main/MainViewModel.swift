import Combine
import SwiftUI

@MainActor
final class MainViewModel: ObservableObject {
    @Published var showMenu = false
    @Published var selectedMenuItem = "Home"
    @Published var dragOffset: CGFloat = 0

    var menuWidth: CGFloat {
        AdaptiveLayout.menuWidth()
    }

    func openMenu() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            showMenu = true
            dragOffset = 0
        }
    }

    func closeMenu() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            showMenu = false
            dragOffset = 0
        }
    }

    func handleDragChanged(value: DragGesture.Value) {
        if showMenu {
            dragOffset = min(0, value.translation.width)
        }
    }

    func handleDragEnded(value: DragGesture.Value) {
        let velocity = value.translation.width
        if showMenu {
            if velocity < -80 {
                closeMenu()
            } else {
                openMenu()
            }
        }
    }

    func selectItem(_ title: String) {
        UISelectionFeedbackGenerator().selectionChanged()
        selectedMenuItem = title
        showMenu = false
    }
}
