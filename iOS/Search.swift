import SwiftUI

struct Search: View {
    @StateObject private var field = Field()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(field.results, id: \.self) {
                Text($0.title)
            }
            .listStyle(.insetGrouped)
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
