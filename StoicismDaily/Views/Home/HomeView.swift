import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: StoicQuoteViewModel

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    if viewModel.isLoading && viewModel.currentQuote == nil {
                        ProgressView()
                    } else if viewModel.errorMessage != nil && viewModel.currentQuote == nil {
                        LoadErrorView()
                    } else if let quote = viewModel.currentQuote {
                        VStack(spacing: AdaptiveLayout.isIPad ? 48 : 32) {
                            Text(quote.quote)
                                .font(.system(size: AdaptiveLayout.quoteFontSize(), weight: .medium, design: .serif))
                                .lineSpacing(AdaptiveLayout.isIPad ? 12 : 8)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)

                            Text("— \(quote.author)")
                                .font(.system(size: AdaptiveLayout.authorFontSize(), weight: .regular, design: .serif))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal, AdaptiveLayout.horizontalPadding())

                        // Share Button
                        ShareLink(item: "\(quote.quote)\n\n— \(quote.author)") {
                            Label("Share Wisdom", systemImage: "square.and.arrow.up")
                                .font(.subheadline)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(20)
                        }
                        .padding(.top, 16)
                        .buttonStyle(.plain)
                        .offset(x: viewModel.dragOffset)
                        .animation(.interactiveSpring(), value: viewModel.dragOffset)
                    } else {
                        Text("Swipe left for next quote")
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
                    .frame(minHeight: 0, maxHeight: UIScreen.main.bounds.height * 0.182)
            }

            ForEach(viewModel.hearts) { heart in
                HeartBurstView(heart: heart) {
                    viewModel.removeHeart(id: heart.id)
                }
            }

            ToastFavorite(isShown: $viewModel.showToast, message: viewModel.toastMessage)
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            SpatialTapGesture(count: 2)
                .onEnded { value in
                    let success = viewModel.addHeart(at: value.location)

                    if success {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        }
                    }
                }
        )
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    viewModel.dragOffset = 0
                    viewModel.handleSwipe(h: value.translation.width, v: value.translation.height)
                }
        )
        .task {
            FavoriteQuoteManager.shared.setup(context: modelContext)
            if viewModel.currentQuote == nil {
                await viewModel.fetchQuote()
            }
        }
    }
}

#Preview {
    HomeView()
}