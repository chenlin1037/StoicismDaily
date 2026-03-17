//
//  AboutStoicismView.swift
//  StoicismDaily
//
//  Created by luckly on 2026/3/11.
//
import SwiftUI

struct AboutStoicismView: View {
    let principles = [
        (icon: "brain.head.profile", title: "Focus on What You Control",
         body: "Distinguish between what is up to you and what is not. Direct your energy only toward your own thoughts, intentions, and actions."),
        (icon: "heart.circle", title: "Live According to Virtue",
         body: "Wisdom, courage, justice, and temperance are the only true goods. External things like wealth or fame cannot make you truly happy."),
        (icon: "arrow.clockwise", title: "Practice Negative Visualization",
         body: "Contemplate loss and hardship to appreciate what you have and build resilience for when difficulties inevitably arise."),
        (icon: "person.2", title: "Serve the Common Good",
         body: "We are all part of a larger whole. Act with kindness and work for the benefit of others, not just yourself."),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AdaptiveLayout.isIPad ? 40 : 24) {
                // ── 引言横幅 ──
                VStack(spacing: 8) {
                    Image(systemName: "scroll")
                        .font(.system(size: AdaptiveLayout.isIPad ? 64 : 44))
                        .foregroundColor(.white)
                    Text("What is Stoicism?")
                        .font(.system(size: AdaptiveLayout.isIPad ? 32 : 22, weight: .bold))
                        .foregroundColor(.white)
                    Text("A philosophy of resilience, virtue, and inner freedom.")
                        .font(.system(size: AdaptiveLayout.isIPad ? 20 : 15))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AdaptiveLayout.isIPad ? 48 : 32)
                .padding(.horizontal, 20)
                .background(
                    LinearGradient(
                        colors: [.stoicBannerTop, .stoicBannerBottom],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, AdaptiveLayout.horizontalPadding() / 2)
                .padding(.top, 8)

                // ── 简介 ──
                VStack(alignment: .leading, spacing: 12) {
                    Text("Overview")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, AdaptiveLayout.horizontalPadding() / 2)

                    Text("Stoicism is a school of Hellenistic philosophy founded in Athens by Zeno of Citium in the early 3rd century BC. It teaches that virtue is the only true good and that we should focus on what lies within our control while accepting what does not.")
                        .font(.system(size: AdaptiveLayout.isIPad ? 20 : 17))
                        .foregroundColor(.primary)
                        .padding(.horizontal, AdaptiveLayout.horizontalPadding() / 2)
                }

                // ── 核心原则 ──
                VStack(alignment: .leading, spacing: 12) {
                    Text("Key Principles")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, AdaptiveLayout.horizontalPadding() / 2)

                    VStack(spacing: 16) {
                        ForEach(principles, id: \.title) { item in
                            HStack(alignment: .top, spacing: 16) {
                                Image(systemName: item.icon)
                                    .font(.system(size: AdaptiveLayout.isIPad ? 28 : 22))
                                    .foregroundColor(.stoicAccent)
                                    .frame(width: AdaptiveLayout.isIPad ? 40 : 28)
                                    .padding(.top, 2)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(item.title)
                                        .font(.system(size: AdaptiveLayout.isIPad ? 20 : 17, weight: .semibold))
                                    Text(item.body)
                                        .font(.system(size: AdaptiveLayout.isIPad ? 16 : 14))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(AdaptiveLayout.isIPad ? 20 : 14)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, AdaptiveLayout.horizontalPadding() / 2)
                }

                // ── 三位哲学家 ──
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notable Stoics")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach([
                                ("M. Aurelius", "Emperor & philosopher", "crown"),
                                ("Epictetus", "Former slave & teacher", "person.fill"),
                                ("Seneca", "Statesman & writer", "pencil"),
                            ], id: \.0) { name, role, icon in
                                VStack(spacing: 8) {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 52, height: 52)
                                        .background(
                                            // ✅ Banner 渐变复用，保持视觉一致
                                            LinearGradient(
                                                colors: [.stoicBannerTop, .stoicBannerBottom],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .clipShape(Circle())
                                    Text(name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text(role)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(width: 110)
                                .padding(14)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                Spacer(minLength: 24)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}
