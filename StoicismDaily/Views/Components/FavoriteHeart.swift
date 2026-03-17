//
//  FavoriteHeart.swift
//  StoicismDaily
//
//  Created by luckly on 2026/3/13.
//

import SwiftUI

struct FavoriteHeart: Identifiable {
    let id = UUID()
    let location: CGPoint
}

// 单个红心视图，封装完整动画
struct HeartBurstView: View {
    let heart: FavoriteHeart
    let onRemove: () -> Void

    // 各层动画状态
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 1
    @State private var offsetY: CGFloat = 0
    @State private var ringScale: CGFloat = 0.3
    @State private var ringOpacity: Double = 0.8

    var body: some View {
        ZStack {
            // 3. 主红心
            Text("♥")
                .font(.system(size: 89))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 1, green: 0.18, blue: 0.33),
                                 Color(red: 0.9, green: 0.0, blue: 0.29)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .scaleEffect(scale)
                .opacity(opacity)
                .offset(y: offsetY)
                // 轻微随机旋转，增加自然感
                .rotationEffect(.degrees(Double.random(in: -12 ... 12)))

            // 2个小红心：左右各一个，通过 offset 偏离中心
            Group {
                Text("♥")
                    .font(.system(size: 30))
                    .offset(x: -45, y: 10)
                    .rotationEffect(.degrees(-15))

                Text("♥")
                    .font(.system(size: 35))
                    .offset(x: 40, y: -15)
                    .rotationEffect(.degrees(20))
            }
            .foregroundStyle(.red.gradient)
            .scaleEffect(scale * 0.8) // 比主红心稍微小一点
            .opacity(opacity)
            .offset(y: offsetY * 1.1) // 向上漂移的速度稍微快一点点，产生层次感
        }
        .position(heart.location)
        .onAppear { startAnimation() }
    }

    private func startAnimation() {
        withAnimation(.easeOut(duration: 0.5)) {
            ringScale = 2.2
            ringOpacity = 0
        }

        // 红心弹入
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            scale = 1.15
        }
        // 稍微回弹稳定
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                scale = 1.0
            }
        }

        // 漂浮上升 + 淡出
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.55)) {
                offsetY = -90
                opacity = 0
                scale = 0.7
            }
        }

        // 动画结束后移除
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            onRemove()
        }
    }
}
