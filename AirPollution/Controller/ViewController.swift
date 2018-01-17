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
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapSwitchButton: UIButton!
    @IBOutlet weak var legendButton: UIButton!
    
    var locationManager = CLLocationManager()
    
    var legendView:UIPickerView!
    
    var airDataArray: [AirData]!
    
    var stationArray: [Station]!
    
    var isPollutionMapActive: Bool = true
    
    var selectedStation: Station!
    
    var selectedAirData: AirData!
    
    let notificationIdentifier = "myNotification"
    
    var lastUserLocation:CLLocation!
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location Update")
        
        let userLocation:CLLocation = locations[0]
        
        if lastUserLocation != nil && userLocation.coordinate.latitude == lastUserLocation.coordinate.latitude && userLocation.coordinate.longitude == lastUserLocation.coordinate.longitude {
            print("Location is same")
            return
        } else {
            lastUserLocation = userLocation
        }
        
        if UIApplication.shared.applicationState == .background {
            print("App is backgrounded. New location is %@", userLocation)
            
            AirDataClient.sharedInstance.getClosestAirData(userLatitude: userLocation.coordinate.latitude, userLongitude: userLocation.coordinate.longitude) {
                (result, error ) in
                
                guard error == nil else {
                    return
                }
                
                print("Closest Air Data ::  \(result.id)")
                
                self.scheduleNotification(inSeconds: 3, airData: result, completion: { success in
                    if success {
                        print("Successfully scheduled notification")
                    } else {
                        print("Error scheduling notification")
                    }
                })
            }
            
        } else {
            
            let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            AirDataClient.sharedInstance.getAirData(userLatitude: userLocation.coordinate.latitude, userLongitude: userLocation.coordinate.longitude) {
                (result, error ) in
                
                guard error == nil else {
                    return
                }
                
                self.airDataArray = result
                
                print("Match found \(result.count)")
                
                for airData in result {
                    
                    let annotation = AirDataAnnotation(airData: airData, valueTypeIndex: 0)
                    
                    
                    self.mapView.addAnnotation(annotation)
                    
                }
                
            }
            
            self.mapView.setRegion(region, animated: true)
        }
        
        print("Location found \(userLocation.coordinate)")
        
    }
    
    func scheduleNotification(inSeconds: TimeInterval, airData:AirData, completion: @escaping (Bool) -> ()) {
        
        // Create Notification content
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = "Air Pollution Alert!"
        notificationContent.subtitle = airData.sensorDataArray[0].valueType
        notificationContent.body = String(airData.sensorDataArray[0].value)
        
        // Create Notification trigger
        // Note that 60 seconds is the smallest repeating interval.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: inSeconds, repeats: false)
        
        // Create a notification request with the above components
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: trigger)
        
        // Add this notification to the UserNotificationCenter
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                print("\(error)")
                completion(false)
            } else {
                completion(true)
            }
        })
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
        } else if segue.identifier == "pollution_detail_segue" {
            if let vc = segue.destination as? PollutionDetailViewController {
                vc.airData = self.selectedAirData
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

