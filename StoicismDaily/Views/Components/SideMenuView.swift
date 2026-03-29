//
//  SideMenuView.swift
//  StoicismDaily
//
//  Created by luckly on 2026/3/9.
//

import SwiftUI

// MARK: - 动画常量

private extension Animation {
    static let menuAnimation = Animation.spring(response: 0.35, dampingFraction: 0.85)
}

// MARK: - MainView

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .leading) {
                // 1. 主内容层
                MainContentView()
                    .environmentObject(viewModel)
//                    .offset(x: viewModel.showMenu ? viewModel.menuWidth + viewModel.dragOffset : max(0, viewModel.dragOffset))

                // 2. 黑色遮罩层
                if viewModel.showMenu {
                    Color(.secondarySystemBackground)
                        .opacity(viewModel.showMenu ? 0.3 : Double(viewModel.dragOffset / viewModel.menuWidth) * 0.3)
                        .ignoresSafeArea()
                        .onTapGesture { viewModel.closeMenu() }
                        .transition(.opacity)
                }

                // 3. 侧边菜单层
                SideMenuView()
                    .environmentObject(viewModel)
                    .offset(x: viewModel.showMenu ? viewModel.dragOffset : -viewModel.menuWidth + viewModel.dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                viewModel.handleDragChanged(value: value)
                            }
                            .onEnded { value in
                                viewModel.handleDragEnded(value: value)
                            }
                    )
            }
            .animation(.menuAnimation, value: viewModel.showMenu)
            .animation(.menuAnimation, value: viewModel.dragOffset)
            // .navigationTitle(viewModel.showMenu ? "" : viewModel.selectedMenuItem)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - MainContentView

struct MainContentView: View {
    @EnvironmentObject var viewModel: MainViewModel

    var body: some View {
        VStack {
            contentView
                .disabled(viewModel.showMenu)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            withAnimation(.menuAnimation) {
                                viewModel.showMenu.toggle()
                            }
                        } label: {
                            Image(systemName: viewModel.showMenu ? "multiply" : "line.3.horizontal")
                                .font(.title3)
                                .foregroundStyle(.primary)
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .buttonStyle(.plain)
                    }
                }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.selectedMenuItem {
        case "Home": HomeView()
        case "Saved Quotes": FavoritesView()
        case "About Stoicism": AboutStoicismView()
        case "Rate The App": RateAppView()
        case "Settings": SettingsView()
        default:
            HomeView()
        }
    }
}

// MARK: - SideMenuView

struct SideMenuView: View {
    @EnvironmentObject var viewModel: MainViewModel

    let menuItems = [
        (title: "Home", icon: "house"),
        (title: "Saved Quotes", icon: "bookmark"),
        (title: "About Stoicism", icon: "info.circle"),
        (title: "Rate The App", icon: "star"),
        (title: "Settings", icon: "gear"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Menulist
            Spacer()
        }
        .frame(width: viewModel.menuWidth)
        .background(Color(.secondarySystemGroupedBackground))
    }

    private var Menulist: some View {
        ForEach(menuItems, id: \.title) { item in
            Button {
                viewModel.selectItem(item.title)
            } label: {
                HStack(spacing: 15) {
                    Image(systemName: item.icon)
                        .font(.title3)
                    Text(item.title)
                        .font(.title3)

                    Spacer()
                }
                // 1. 先添加内边距
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                // 2. 再定义点击区域的形状，这个形状会覆盖上面所有内边距构成的整个区域
                .contentShape(RoundedRectangle(cornerRadius: 10))
                // 3. 最后设置视觉上的圆角
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    MainView()
}
