//
//  RateAppView.swift
//  StoicismDaily
//
//  Created by luckly on 2026/3/11.
//
import SwiftUI

struct RateAppView: View {
    @State private var rating = 0
    @State private var submitted = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // ── 顶部横幅 ──
                VStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 52))
                        .foregroundColor(.yellow)
                    Text("Enjoying Stoic Quote?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Your feedback helps us grow.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
                .background(
                    LinearGradient(
                        colors: [.stoicBannerTop, .stoicBannerBottom],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
                .padding(.top, 8)

                if submitted {
                    // ── 提交后感谢卡片 ──
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: AdaptiveLayout.isIPad ? 64 : 44))
                            .foregroundColor(.stoicAccent)
                        Text("Thank you!")
                            .font(.system(size: AdaptiveLayout.isIPad ? 28 : 20, weight: .semibold))
                        Text("We appreciate your \(rating)-star review.")
                            .font(.system(size: AdaptiveLayout.isIPad ? 20 : 17))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(AdaptiveLayout.isIPad ? 40 : 24)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, AdaptiveLayout.horizontalPadding())
                    .padding(.top, 20)

                } else {
                    // ── 评分区域 ──
                    VStack(spacing: AdaptiveLayout.isIPad ? 32 : 20) {
                        Text("Tap to rate")
                            .font(.system(size: AdaptiveLayout.isIPad ? 20 : 15))
                            .foregroundColor(.secondary)

                        HStack(spacing: AdaptiveLayout.isIPad ? 24 : 16) {
                            ForEach(1 ... 5, id: \.self) { index in
                                Image(systemName: index <= rating ? "star.fill" : "star")
                                    .font(.system(size: AdaptiveLayout.isIPad ? 52 : 36))
                                    .foregroundColor(.yellow)
                                    .scaleEffect(index <= rating ? 1.15 : 1.0)
                                    .animation(.spring(response: 0.3), value: rating)
                                    .onTapGesture { rating = index }
                            }
                        }

                        if rating > 0 {
                            Button(action: { submitted = true }) {
                                Text("Submit Rating")
                            }
                            .stoicButtonStyle()
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(AdaptiveLayout.isIPad ? 32 : 20)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, AdaptiveLayout.horizontalPadding())
                    .padding(.top, 20)
                    .animation(.spring(response: 0.4), value: rating)
                }

                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}
