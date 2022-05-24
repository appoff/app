import MapKit

final class Liner: MKMultiPolylineRenderer {
    override func applyStrokeProperties(to: CGContext, atZoomScale: MKZoomScale) {
        super.applyStrokeProperties(to: to, atZoomScale: atZoomScale)
        to.setLineWidth(MKRoadWidthAtZoomScale(atZoomScale) * 0.5)
    }
}
