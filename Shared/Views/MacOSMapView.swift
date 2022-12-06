//
//  MacOSMapView.swift
//  BaseStation
//
//  Created by Michael Warren on 12/4/22.
//

import SwiftUI
import MapKit

struct BaseMapView : NSViewRepresentable {
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let anno = annotation as? Annotation {
                let view = MKAnnotationView(annotation: anno, reuseIdentifier: anno.name)
                view.image = NSImage(systemSymbolName: anno.imageName, accessibilityDescription: nil)?.tint(color: NSColor(anno.color))
                view.frame.size = CGSize(width: 40, height: 40)
                return view
            }
            
            return MKUserLocationView(annotation: annotation, reuseIdentifier: nil)
        }
        
        func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.fillColor = NSColor.red.withAlphaComponent(0.5)
            renderer.strokeColor = NSColor.red.withAlphaComponent(0.8)
            return renderer
        }
    }

    @Binding var coordinateRegion: MKCoordinateRegion
    @Binding var annotationItems: [Annotation]
    @Binding var path: [CLLocationCoordinate2D]
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeNSView(context: Context) -> MKMapView {
        let view = MKMapView(frame: .zero)
        view.isRotateEnabled = false
        view.isPitchEnabled = false
        view.preferredConfiguration = MKHybridMapConfiguration(elevationStyle: .realistic)
        view.delegate = context.coordinator
        view.region = coordinateRegion
        view.addAnnotations(annotationItems)
        return view
    }
    
    func updateNSView(_ nsView: MKMapView, context: Context) {
        DispatchQueue.main.async {
            nsView.removeOverlays(nsView.overlays)
            nsView.addOverlay(MKPolyline(coordinates: path, count: path.count))
        }
    }
}

extension NSImage {
    func tint(color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()

        color.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)

        image.unlockFocus()

        return image
    }
}
