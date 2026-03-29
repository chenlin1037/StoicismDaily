import SwiftUI

struct ReflectionEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: ReflectionViewModel
    let quote: StoicQuote
    @Environment(\.dismiss) private var dismiss

    @FocusState private var isReflectionFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    // Quote Section
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("“\(quote.quote)”")
                                .font(.system(size: AdaptiveLayout.isIPad ? 20 : 17, weight: .regular, design: .serif))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)

                            Text("— \(quote.author)")
                                .font(.system(size: AdaptiveLayout.isIPad ? 16 : 14, weight: .regular, design: .serif))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color(.secondarySystemGroupedBackground))

                    // Reflection Input Section
                    Section(header: Text("Your Reflection").font(.headline).textCase(nil)) {
                        TextEditor(text: $viewModel.reflectionText)
                            .font(.system(.body, design: .default))
                            .foregroundColor(.primary)
                            .frame(minHeight: 150)
                            .focused($isReflectionFocused)
                            .padding(4)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
                .listStyle(.insetGrouped)
                .listRowSpacing(8)
                .padding(.top, -25)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))

                // Bottom Action Area - 模拟键盘上方悬浮按钮
                // if !viewModel.reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                //     Button(action: {
                //         saveAction()
                //     }) {
                //         HStack {
                //             Spacer()
                //             Text("Done") // 使用 Done 替代 Save，更符合键盘交互习惯
                //                 .fontWeight(.semibold)
                //             Spacer()
                //         }
                //     }
                //     .stoicButtonStyle()
                //     // 关键修改：
                //     // 1. 增加水平内边距，使其看起来像悬浮卡片
                //     .padding(.horizontal, AdaptiveLayout.horizontalPadding())
                //     // 2. 调整底部边距，留出一点空隙，模拟“悬浮在键盘之上”的视觉层次
                //     .padding(.bottom, 12)
                //     // 3. 顶部边距稍微加大，与上面的列表内容区分开
                //     .padding(.top, 16)
                // }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Daily Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveAction()
                    }
                    .foregroundColor(.primary)
                }

            }
            .task {
                viewModel.setContext(modelContext)
                viewModel.fetchTodayReflection(quote: quote)
            }
            // 自动弹出键盘
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isReflectionFocused = true
                }
            }
        }
    }

     private func saveAction() {
         isReflectionFocused = false
         viewModel.saveReflection(quote: quote)
         dismiss()
     }
}
