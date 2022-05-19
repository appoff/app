import SwiftUI

extension Navigate {
    struct Points: View {
        let control: Control
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            Pop(title: "Points") {
                ScrollView {
                    ForEach(Array(control.annotations.enumerated()), id: \.0) { item in
                        Button {
                            dismiss()
                            control.map.selectAnnotation(item.element, animated: true)
                            control.map.setCenter(item.element.coordinate, animated: true)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(item.element.title ?? "")
                                    .foregroundColor(.primary)
                                    .font(.callout)

                                if let subtitle = item.element.subtitle, !subtitle.isEmpty {
                                    Text(subtitle)
                                        .foregroundColor(.secondary)
                                        .font(.footnote)
                                }
                            }
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                            .padding()
                            .contentShape(Rectangle())
                        }
                        
                        if control.route.count > item.offset {
                            Divider()
                                .padding(.horizontal)
                            
                            HStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundStyle(.secondary)
                                
                                Text(Date(timeIntervalSinceNow: -.init(control.route[item.offset].duration)) ..< Date.now, format: .timeDuration)
                                    .font(.callout.monospacedDigit())
                                
                                Text(":")
                                    .foregroundStyle(.secondary)
                                
                                Text(Measurement(value: .init(control.route[item.offset].distance), unit: UnitLength.meters),
                                     format: .measurement(width: .abbreviated))
                                    .font(.callout.monospacedDigit())
                            }
                            
                            Divider()
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.top)
            }
            .symbolRenderingMode(.hierarchical)
            .toggleStyle(SwitchToggleStyle(tint: .secondary))
        }
    }
}
