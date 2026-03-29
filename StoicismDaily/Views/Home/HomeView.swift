import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingReflection = false
    @EnvironmentObject var viewModel: StoicQuoteViewModel
    @EnvironmentObject var reflectionViewModel: ReflectionViewModel
    @State private var showingAIExplanation = false

    var body: some View {
        NavigationStack { // 确保有 NavigationStack 才能显示 toolbar
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
                                
                                // --- 修改点 1: 分享和反思放在一排 ---
                                HStack(spacing: 40) {
                                    // Share Button
                                    ShareLink(item: "\(quote.quote)\n\n— \(quote.author)") {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.title2)
                                    }
                                    .buttonStyle(.plain)

                                    // Reflection Button
                                    Button(action: {
                                        showingReflection = true
                                    }) {
                                        Image(systemName: reflectionViewModel.currentReflection == nil ? "pencil.and.outline" : "pencil.line")
                                            .font(.title2)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.top, 24)
                                .sheet(isPresented: $showingReflection) {
                                    ReflectionEntryView(viewModel: reflectionViewModel, quote: quote)
                                }
                            }
                            .padding(.horizontal, AdaptiveLayout.horizontalPadding())
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

                // Hearts Layer
                ForEach(viewModel.hearts) { heart in
                    HeartBurstView(heart: heart) {
                        viewModel.removeHeart(id: heart.id)
                    }
                }

                ToastFavorite(isShown: $viewModel.showToast, message: viewModel.toastMessage)
            }
            // --- 修改点 2: AI 解释放在右侧 Toolbar ---
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let quote = viewModel.currentQuote {
                        Button(action: {
                            if quote.aiExplanation == nil {
                                Task { await viewModel.fetchAIExplanation() }
                            }
                            showingAIExplanation = true
                        }) {
                            HStack(spacing: 4) {
                                if viewModel.isExplaining {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "brain")
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .disabled(viewModel.isExplaining)
                    }
                }
            }
            .sheet(isPresented: $showingAIExplanation) {
                if let quote = viewModel.currentQuote {
                    AIExplanationView(quote: quote)
                }
            }
            // 手势与其他逻辑保持不变
            .contentShape(Rectangle())
            .simultaneousGesture(
                SpatialTapGesture(count: 2)
                    .onEnded { value in
                        let success = viewModel.addHeart(at: value.location)
                        if success {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {}
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
                if let quote = viewModel.currentQuote {
                    reflectionViewModel.fetchTodayReflection(quote: quote)
                }
            }
            .onChange(of: viewModel.currentQuote) { _, newQuote in
                if let quote = newQuote {
                    reflectionViewModel.fetchTodayReflection(quote: quote)
                }
            }
        }
    }
}