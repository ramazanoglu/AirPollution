//
//  MapViewController+MapKit.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 18.01.18.
//  Copyright © 2018 zigzag. All rights reserved.
//

import Foundation
import MapKit

extension MapViewController:  MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {  //Handle user location annotation..
            
            let userLocationView = mapView.view(for: annotation);
            userLocationView?.canShowCallout = false;
            
            return userLocationView
        }
        
        if annotation.isKind(of: StationAnnotation.self) {  //Handle StationAnnotations..
            var pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "DefaultPinView")
            if pinAnnotationView == nil {
                pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DefaultPinView")
            }
            
            pinAnnotationView?.canShowCallout = true
            pinAnnotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pinAnnotationView?.rightCalloutAccessoryView?.alpha = 0
            
            return pinAnnotationView
        }
        
        var view: AirDataAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation") as? AirDataAnnotationView
        if view == nil {
            view = AirDataAnnotationView(annotation: annotation, reuseIdentifier: "imageAnnotation")
        }
        
        let annotation = annotation as! AirDataAnnotation
        view?.color = annotation.color
        view?.annotation = annotation
        
        view?.canShowCallout = true
        view?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        view?.rightCalloutAccessoryView?.alpha = 0
        view?.rightCalloutAccessoryView = UIButton(type: .infoLight)
        
        return view
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        guard let annotation = view.annotation else {
            return
        }
        
        if annotation .isKind(of: StationAnnotation.self) {
            
            let stationAnnotation = annotation as! StationAnnotation
            
            self.selectedStation = stationAnnotation.station
            
            performSegue(withIdentifier: "departures_segue", sender: self)
            
        } else if annotation .isKind(of: AirDataAnnotation.self) {
            
            let airDataAnnotation = annotation as! AirDataAnnotation
            
            self.selectedAirData = airDataAnnotation.airData
            
            performSegue(withIdentifier: "pollution_detail_segue", sender: self)
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        for annotation in mapView.annotations {
            
            if annotation .isKind(of: AirDataAnnotation.self) {
                
                let view = mapView.view(for: annotation)
                
                if view != nil && (view? .isKind(of: AirDataAnnotationView.self))! {
                    
                    let airDataAnnotaionView = view as! AirDataAnnotationView
                    
                    let scaleFactor = CGFloat(0.01 / mapView.region.span.latitudeDelta)
                    
                    airDataAnnotaionView.frame = CGRect(x: 0, y: 0, width: 100 * scaleFactor, height: 100 * scaleFactor)
                    airDataAnnotaionView.imageView.frame = CGRect(x: 0, y: 0, width: 100 * scaleFactor, height: 100 * scaleFactor)
                    
                }
                
            }
            
        }
        
    }
    
}
