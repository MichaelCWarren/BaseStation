//
//  iOSMapView.swift
//  BaseStation-Remote
//
//  Created by Michael Warren on 12/4/22.
//

import SwiftUI
import UIKit
import MapKit

struct BaseMapView : UIViewRepresentable {
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let anno = annotation as? Annotation {
                let view = MKAnnotationView(annotation: anno, reuseIdentifier: anno.name)
                
                let uiImageView = UIImageView(image: UIImage(systemName: anno.imageName)?.withTintColor(UIColor(anno.color), renderingMode: .alwaysOriginal))
                view.image = uiImageView.asUIImage()
                    
                view.frame.size = CGSize(width: 40, height: 40)
                return view
            }
            return MKUserLocationView(annotation: annotation, reuseIdentifier: nil)
        }
        
        func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.red.withAlphaComponent(0.8)
            return renderer
        }
    }

    @Binding var coordinateRegion: MKCoordinateRegion
    @Binding var annotationItems: [Annotation]
    @Binding var path: [CLLocationCoordinate2D]
    @State private var pathOverlay: MKPolyline?
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let view = MKMapView()
        view.isRotateEnabled = false
        view.isPitchEnabled = false
        view.userTrackingMode = .followWithHeading
        view.preferredConfiguration = MKHybridMapConfiguration(elevationStyle: .realistic)
        view.delegate = context.coordinator
        view.region = coordinateRegion
        view.addAnnotations(annotationItems)
        return view
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        DispatchQueue.main.async {
            uiView.removeOverlays(uiView.overlays)
            uiView.addOverlay(MKPolyline(coordinates: path, count: path.count))
        }
    }
}

extension View {
// This function changes our View to UIView, then calls another function
// to convert the newly-made UIView to a UIImage.
    public func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        scene?.windows.first?.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
// here is the call to the function that converts UIView to UIImage: `.asUIImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}

extension UIView {
// This is the function to convert UIView to UIImage
    public func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
