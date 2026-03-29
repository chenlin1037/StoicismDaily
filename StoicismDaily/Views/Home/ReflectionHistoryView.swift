import SwiftData
import SwiftUI

struct ReflectionHistoryView: View {
    @Query(sort: \DailyReflection.date, order: .reverse) private var reflections: [DailyReflection]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            if reflections.isEmpty {
                ContentUnavailableView("No Reflections Yet",
                                       systemImage: "book.closed",
                                       description: Text("Your daily reflections will appear here."))
            } else {
                ForEach(reflections) { reflection in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(reflection.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(reflection.quoteContent)
                                .font(.system(.subheadline, design: .serif))
                                .italic()
                                .lineLimit(2)

                            Text("— \(reflection.quoteAuthor)")
                                .font(.system(.caption2, design: .serif))
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 8)
                        .border(width: 2, edges: [.leading], color: Color.accentColor.opacity(0.3))

                        Text(reflection.reflectionText)
                            .font(.body)
                            .lineLimit(3)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteReflections)
            }
        }
        .navigationTitle("Reflection History")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                    }
                    .foregroundColor(.primary) // 自定义颜色，可以改为你想要的颜色
                }
            }
        }
    }

    private func deleteReflections(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(reflections[index])
        }
    }
}

private extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(
            EdgeBorder(width: width, edges: edges)
                .foregroundColor(color)
        )
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return width
                case .leading, .trailing: return rect.height
                }
            }
            path.addRect(CGRect(x: x, y: y, width: w, height: h))
        }
        return path
    }
}
