import SwiftUI
import MapKit

struct Search: View {
    let select: (MKLocalSearchCompletion) -> Void
    @StateObject private var field = Field()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List() {
                if field.results.isEmpty {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 24, weight: .light))
                        Text("Search for an address\nor place of interest.")
                        Spacer()
                    }
                    .foregroundStyle(.secondary)
                    .font(.callout)
                    .listSectionSeparator(.hidden)
                    .padding(.top)
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
            .animation(.easeInOut(duration: 0.25), value: field.results)
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
                        Text("Cancel")
                            .font(.callout)
                            .frame(minWidth: 60, minHeight: 38)
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
