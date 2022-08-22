import AppKit
import Coffee
import Combine
import Offline

final class Premium: NSView {
    private var subs = Set<AnyCancellable>()
    
    required init?(coder: NSCoder) { nil }
    init(session: Session, header: Header) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let share = Control.Prominent(title: "Share")
        share.toolTip = "Share map"
        
        let offload = Control.Prominent(title: "Offload")
        offload.toolTip = "Offload map"
        
        [share, offload]
            .forEach {
                $0.color = .windowBackgroundColor
                $0.text.textColor = .labelColor
                addSubview($0)
                
                $0.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
                $0.widthAnchor.constraint(equalToConstant: 120).isActive = true
                $0.heightAnchor.constraint(equalToConstant: 34).isActive = true
            }
        
        widthAnchor.constraint(equalToConstant: 300).isActive = true
        bottomAnchor.constraint(equalTo: offload.bottomAnchor, constant: 20).isActive = true
        
        share.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        offload.topAnchor.constraint(equalTo: share.bottomAnchor, constant: 10).isActive = true
    }
    
    override var allowsVibrancy: Bool {
        true
    }
}

/*
struct Premium: View {
    let session: Session
    let header: Header
    @State private var size = Int()
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.4)) {
                session.flow = .share(header)
            }
        } label: {
            HStack {
                Text("Share")
                    .font(.callout.weight(.medium))
                Spacer()
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .regular))
                    .symbolRenderingMode(.hierarchical)
            }
            .frame(width: 130)
            .padding(.vertical, 4)
            .padding(.horizontal, 3)
            .contentShape(Rectangle())
        }
        .buttonStyle(.bordered)
        .foregroundColor(.primary)
        .padding(.bottom, 20)
        .task {
            size = await session.local.size(header: header) ?? 0
        }
        
        if size > 0 {
            Button {
                withAnimation(.easeOut(duration: 0.4)) {
                    session.flow = .offload(header)
                }
            } label: {
                HStack {
                    Text("Offload")
                        .font(.callout.weight(.medium))
                    Spacer()
                    Image(systemName: "icloud.and.arrow.up")
                        .font(.system(size: 16, weight: .regular))
                        .symbolRenderingMode(.hierarchical)
                }
                .frame(width: 130)
                .padding(.vertical, 4)
                .padding(.horizontal, 3)
                .contentShape(Rectangle())
            }
            .buttonStyle(.bordered)
            .foregroundColor(.primary)
        }
    }
}
*/
