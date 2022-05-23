import SwiftUI

extension Navigate {
    struct Points: View {
        let control: Control
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            Pop(title: "Points") {
                ScrollView {
                    ForEach(control.annotations, id: \.point) { item in
                        Button {
                            dismiss()
                            control.map.selectAnnotation(item.point, animated: true)
                            control.map.setCenter(item.point.coordinate, animated: true)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(item.point.title ?? "")
                                    .foregroundColor(.primary)

                                if let subtitle = item.point.subtitle,
                                   !subtitle.isEmpty,
                                   subtitle.localizedCompare(item.point.title ?? "") != .orderedSame {
                                    
                                    Text(subtitle)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .font(.callout)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                            .padding()
                            .contentShape(Rectangle())
                        }
                        
                        if let route = item.route {
                            Divider()
                                .padding(.horizontal)
                            
                            HStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundStyle(.secondary)
                                
                                Text(Date(timeIntervalSinceNow: -.init(route.duration)) ..< Date.now, format: .timeDuration)
                                    .font(.callout.monospacedDigit())
                                
                                Text(":")
                                    .foregroundStyle(.secondary)
                                
                                Text(Measurement(value: .init(route.distance), unit: UnitLength.meters),
                                     format: .measurement(width: .abbreviated))
                                    .font(.callout.monospacedDigit())
                            }
                            .padding(.vertical, 5)
                            
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
