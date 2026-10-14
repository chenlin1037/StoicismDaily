import SwiftUI

struct LoadErrorView: View {
    @EnvironmentObject var viewModel: StoicQuoteViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "infinity")
                .font(.system(size: 40, weight: .ultraLight))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text("Connection Interrupted")
                    .font(.system(.headline, design: .serif))

                Text(viewModel.errorMessage ?? "Perhaps a moment for reflection, or try again later.")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundColor(.secondary)
                    .italic()
            }

            Button(action: {
                Task {
                    await viewModel.fetchQuote()
                }
            }) {
                Text("Reload")
                    .font(.subheadline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(20)
            }
        }
        .padding(.horizontal, 32)
        .buttonStyle(.plain)
    }
}

#Preview {
    LoadErrorView()
}
