import SwiftUI

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var favoritesVM: FavoritesViewModel

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if favoritesVM.favorites.isEmpty {
                emptyStateView
            } else {
                favoritesList
            }
        }
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    NavigationLink(destination: SearchDetailView()) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .task {
            FavoriteQuoteManager.shared.setup(context: modelContext)
        }
    }

    // MARK: - List Section

    private var favoritesList: some View {
        VStack(spacing: 0) {
            if !favoritesVM.searchText.isEmpty && favoritesVM.filteredFavorites.isEmpty {
                searchEmptyStateView
            } else {
                List {
                    ForEach(favoritesVM.filteredFavorites, id: \.self) { quote in
                        quoteRow(quote)
                            .listRowBackground(Color(.systemGroupedBackground))
                    }
                    .onDelete { indexSet in
                        favoritesVM.removeFavorites(at: indexSet)
                    }
                }
                .listStyle(.insetGrouped)
                .listRowSpacing(0)
                .padding(.top, -25)
                .padding(.bottom, 8)
                .background(Color(.systemGroupedBackground))
                .scrollContentBackground(.hidden)
            }

            // Bottom clear all button
            if !favoritesVM.filteredFavorites.isEmpty && favoritesVM.searchText.isEmpty {
                Button(action: {
                    favoritesVM.removeAllFavorites()
                }) {
                    Text("Clear All Favorites")
                }
                .stoicButtonStyle()
                .padding(.horizontal, AdaptiveLayout.horizontalPadding())
                .padding(.bottom, 12)
            }
        }
    }

    @ViewBuilder
    private func quoteRow(_ quote: StoicQuote) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("“\(quote.quote)”")
                .font(.system(size: AdaptiveLayout.isIPad ? 20 : 17, weight: .regular, design: .serif))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)

            Text("— \(quote.author)")
                .font(.system(size: AdaptiveLayout.isIPad ? 16 : 14, weight: .regular, design: .serif))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
    }

    // MARK: - Empty States

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bookmark.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No favorites yet")
                .font(.body)
                .foregroundColor(.gray)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var searchEmptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No quotes found")
                .font(.body)
                .foregroundColor(.gray)
            Button("Clear Search") {
                favoritesVM.searchText = ""
            }
            .foregroundColor(.accentColor)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FavoritesView()
}