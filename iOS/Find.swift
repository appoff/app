import SwiftUI
import MapKit

struct Find: View {
    let select: (MKLocalSearchCompletion) -> Void
    @StateObject private var field = Field()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                if field.results.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 34, weight: .light))
                        Text("Search for an address\nor place of interest.")
                            .multilineTextAlignment(.center)
                            .font(.callout)
                    }
                    .foregroundStyle(.secondary)
                    .listSectionSeparator(.hidden)
                    .padding(.top, 20)
                    .frame(maxWidth: .greatestFiniteMagnitude)
                }
                
                ForEach(field.results, id: \.self) { item in
                    Item(item: item) {
                        field.field.text = item.title
                    } action: {
                        select(item)
                        dismiss()
                    }
                }
            }
            .listStyle(.plain)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                field
                    .equatable()
                    .frame(height: 1)
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20, weight: .light))
                            .frame(width: 28, height: 36)
                            .foregroundStyle(.secondary)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .onAppear {
                field.becomeFirstResponder()
            }
        }
        .navigationViewStyle(.stack)
    }
}
