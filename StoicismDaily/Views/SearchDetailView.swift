import SwiftUI

struct SearchDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var favoritesVM: FavoritesViewModel
    @Environment(\.dismiss) private var dismiss

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if favoritesVM.favorites.isEmpty {
                emptyStateView
            } else {
                if !favoritesVM.searchText.isEmpty {
                    searchResultHeader
                }
                authorFilterBar
                favoritesList
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("Search")
        .background(Color(.systemGroupedBackground))
        .searchable(text: $favoritesVM.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search quotes or authors")
    }

    private var searchResultHeader: some View {
        HStack {
            Text("\(favoritesVM.filteredFavorites.count) results found")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }

    private var authorFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                authorButton(title: "All", isSelected: favoritesVM.selectedAuthor == nil) {
                    UISelectionFeedbackGenerator().selectionChanged()
                    favoritesVM.selectedAuthor = nil
                }

                ForEach(favoritesVM.allAuthors, id: \.self) { author in
                    authorButton(title: author, isSelected: favoritesVM.selectedAuthor == author) {
                        UISelectionFeedbackGenerator().selectionChanged()
                        favoritesVM.selectedAuthor = author
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func authorButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.primary : Color(.secondarySystemGroupedBackground))
                .foregroundColor(isSelected ? Color(.systemBackground) : .primary)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.primary.opacity(isSelected ? 0 : 0.1), lineWidth: 1)
                )
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
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
        .contentShape(Rectangle())
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("Search quotes")
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