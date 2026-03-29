import SwiftUI

struct AIExplanationView: View {
    let quote: StoicQuote
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(quote.quote)
                            .font(.system(.title3, design: .serif))
                            .italic()
                            .foregroundColor(.primary)

                        Text("— \(quote.author)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)

                    if let explanation = quote.aiExplanation {
                        VStack(alignment: .leading, spacing: 16) {
                            Image(systemName: "brain")
                                .font(.system(size: 16))
                                .foregroundColor(.primary)

                            Text((try? AttributedString(markdown: explanation)) ?? AttributedString(explanation))
                                .font(.body)
                                .lineSpacing(6)
                        }
                        .padding()
                    } else {
                        VStack(spacing: 20) {
                            ProgressView()
                            Text("AI is pondering...")
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
}
