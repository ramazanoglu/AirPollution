//
//  ViewController.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 08.12.17.
//  Copyright © 2017 zigzag. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapSwitchButton: UIButton!
    @IBOutlet weak var legendButton: UIButton!
    
    var locationUpdated: Bool = false
    
    var locationManager = CLLocationManager()
    
    var legendView:UIPickerView!
    
    var airDataArray: [AirData]!
    
    var stationArray: [Station]!
    
    var isPollutionMapActive: Bool = true
    
    var selectedStation: Station!
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        
        if(!locationUpdated) {
            locationUpdated = true
            
            let userLocation:CLLocation = locations[0]
            
            print("Location found \(userLocation.coordinate)")
            
            let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            
            AirDataClient.sharedInstance.getAirData(userLatitude: userLocation.coordinate.latitude, userLongitude: userLocation.coordinate.longitude) {
                (result, error ) in
                
                self.airDataArray = result
                
                print("Match found \(result.count)")
                
                for airData in result {
                    
                    let annotation = AirDataAnnotation(airData: airData, valueTypeIndex: 0)
                    
                    
                    self.mapView.addAnnotation(annotation)
                    
                }
                
            }
            
            self.mapView.setRegion(region, animated: true)
        }
    }
    @IBAction func switchMap(_ sender: Any) {

        for annotation in mapView.annotations {
            
            mapView.removeAnnotation(annotation)
            
        }
        
        if isPollutionMapActive {
            
            isPollutionMapActive = false
            mapSwitchButton.setTitle("Pollution", for: .normal)
            
            
            UIView.animate(withDuration: 0.5, animations: {
                self.legendButton.alpha = 0
            })

            for station in stationArray {
                
                let stationAnnotation = StationAnnotation()
                stationAnnotation.title = station.fullName
                stationAnnotation.subtitle = "Station"
                stationAnnotation.coordinate = CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude)
                stationAnnotation.station = station
                self.mapView.addAnnotation(stationAnnotation)
            }
        } else {
            isPollutionMapActive = true
            UIView.animate(withDuration: 0.5, animations: {
                self.legendButton.alpha = 1
            })

            mapSwitchButton.setTitle("Stations", for: .normal)

            
            for airData in self.airDataArray {
                let annotation = AirDataAnnotation(airData: airData, valueTypeIndex: self.legendView.selectedRow(inComponent: 0))
                
                
                self.mapView.addAnnotation(annotation)
            }
        }
        
    }
    
    @IBAction func showLegend(_ sender: Any) {
        
        UIView.animate(withDuration: 0.5, animations: ({
            
            self.legendView.backgroundColor = UIColor.white;
            
            let height = 200.0;
            
            self.legendView.frame = CGRect(x: 0.0, y: self.view.frame.size.height - CGFloat(height), width: self.view.frame.size.width, height:200.0)
            
        })
            
        )
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        legendView = UIPickerView(frame: CGRect(x: 0.0, y: self.view.frame.size.height,width: self.view.frame.size.width, height:150.0))
        legendView.backgroundColor = UIColor.clear;
        
        legendView.delegate = self
        legendView.dataSource = self
        
        
        self.view.addSubview(legendView)
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        VVSClient.sharedInstance.readStationLocationFile()
        
        VVSClient.sharedInstance.getStations() {(result, error) in
            
            self.stationArray = result
            
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "departures_segue" {
            if let vc = segue.destination as? DeparturesViewController {
               vc.station = self.selectedStation
            }
        }
    }

    
    
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AirDataAnnotation.airDataTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return AirDataAnnotation.airDataTypes[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        print("Selected Item \(AirDataAnnotation.airDataTypes[row])")
        
        for annotation in mapView.annotations {
            
            mapView.removeAnnotation(annotation)
            
        }
        
        for airData in self.airDataArray {
            let annotation = AirDataAnnotation(airData: airData, valueTypeIndex: row)
            
            
            self.mapView.addAnnotation(annotation)
        }
        
        
        
        UIView.animate(withDuration: 0.5, animations: ({
            
            self.legendView.backgroundColor = UIColor.white;
            
            
            self.legendView.frame = CGRect(x: 0.0, y: self.view.frame.size.height, width: self.view.frame.size.width, height:200.0)
            
        })
            
            
        )
        
        
    }
}

extension ViewController:  MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {  //Handle user location annotation..
            
            let userLocationView = mapView.view(for: annotation);
            userLocationView?.canShowCallout = false;
            
            return userLocationView  //Default is to let the system handle it.
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
        view?.rightCalloutAccessoryView = UIButton(type: .infoLight)
        
        return view
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        guard let annotation = view.annotation else {
            return
        }
        
        if annotation .isKind(of: StationAnnotation.self) {
            
            let stationAnnotation = annotation as! StationAnnotation
            
            print("annotation clicked")
            
            self.selectedStation = stationAnnotation.station
            
            performSegue(withIdentifier: "departures_segue", sender: self)
            
        }
        
    }
    
}

