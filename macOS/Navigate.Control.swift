import MapKit
import Combine
import Offline

extension Navigate {
    final class Control: Map {
        let directions = CurrentValueSubject<_, Never>(true)
        
        required init?(coder: NSCoder) { nil }
        init(session: Session, schema: Schema, bufferer: Bufferer) {
            
            
            /*
             annotations = schema.annotations
             polyline = schema.polyline
             
             super.init(editable: false)
             scheme = schema.settings.scheme
             type = schema.settings.map
             interest = schema.settings.interest
             
             map.addOverlay(Tiler(bufferer: bufferer), level: .aboveLabels)
             map.addAnnotations(annotations.map(\.point))
             */
            
            
            
            
            super.init(session: session, editable: false)
            let annotations = schema.annotations
            let polyline = schema.polyline
            
            type.value = schema.settings.map
            interest.value = schema.settings.interest
            scheme.value = schema.settings.scheme
            
            addOverlay(Tiler(bufferer: bufferer), level: .aboveLabels)
            addAnnotations(annotations.map(\.point))
            
            directions
                .sink { [weak self] in
                    if $0 {
                        self?.addOverlay(polyline, level: .aboveLabels)
                    } else {
                        self?.removeOverlay(polyline)
                    }
                }
                .store(in: &subs)
        }
    }
}


/*
 import MapKit
 import Offline

 extension Navigate {
     final class Control: Mapper {
         @Published var config = false
         @Published var points = false
         let annotations: [(point: MKPointAnnotation, route: Route?)]
         private let polyline: MKMultiPolyline
         
         @Published var directions = true {
             didSet {
                 guard oldValue != directions else { return }
                 overlays()
             }
         }
         
         init(schema: Schema, bufferer: Bufferer) {
             annotations = schema.annotations
             polyline = schema.polyline
             
             super.init(editable: false)
             scheme = schema.settings.scheme
             type = schema.settings.map
             interest = schema.settings.interest
             
             map.addOverlay(Tiler(bufferer: bufferer), level: .aboveLabels)
             map.addAnnotations(annotations.map(\.point))
             overlays()
         }
         
         private func overlays() {
             if directions {
                 map.addOverlay(polyline, level: .aboveLabels)
             } else {
                 map.removeOverlay(polyline)
             }
         }
     }
 }

 
 
 */
