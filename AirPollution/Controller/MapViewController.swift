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
import CoreData


class MapViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapSwitchButton: UIButton!
    @IBOutlet weak var legendButton: UIButton!
    @IBOutlet weak var airPollutionAlarmLabel: UILabel!
    
    var locationManager = CLLocationManager()
    
    var legendView:UIPickerView!
    
    var airDataArray: [AirData]!
    
    var stationArray: [Station]!
    
    var isPollutionMapActive: Bool = true
    
    var selectedStation: Station!
    
    var selectedAirData: AirData!
    
    let notificationIdentifier = "myNotification"
    
    var lastUserLocation:CLLocation!
    
    var stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    var lastUpdateTime:Date!
    
    var lastPollutionLevel:Int = -1
    
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>! {
        didSet {
            fetchedResultsController.delegate = self
            executeSearch()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location Update")
        
        let userLocation:CLLocation = locations[0]
        
        var isLastUpdateExpired:Bool = false
        
        if lastUpdateTime != nil {
            let elapsedTime = Date().timeIntervalSince(lastUpdateTime)
            
            // If last location update was more than half an hour ago, reload the data
            if Int(elapsedTime) > 30 * 60 {
                isLastUpdateExpired = true
                lastUpdateTime = Date()
            } else {
                isLastUpdateExpired = false
            }
        } else {
            isLastUpdateExpired = true
            lastUpdateTime = Date()
        }
        
        print("is last update expired \(isLastUpdateExpired)")
        
        if lastUserLocation != nil && !isLastUpdateExpired && userLocation.coordinate.latitude == lastUserLocation.coordinate.latitude && userLocation.coordinate.longitude == lastUserLocation.coordinate.longitude {
            print("Location is same or time is not expired")
            return
        } else {
            lastUserLocation = userLocation
            isLastUpdateExpired = false
        }
        
        if UIApplication.shared.applicationState == .background {
            print("App is backgrounded. New location is %@", userLocation)
            
            AirDataClient.sharedInstance.getClosestAirData(userLatitude: userLocation.coordinate.latitude, userLongitude: userLocation.coordinate.longitude) {
                (result, error ) in
                
                guard error == nil else {
                    return
                }
                
                guard let result = result else {
                    return
                }
                
                print("Closest Air Data ::  \(result.id)")
                
                
                let userAirData = UserAirData(airData: result, userLatitude: userLocation.coordinate.latitude, userLongitude: userLocation.coordinate.longitude, context: self.fetchedResultsController.managedObjectContext)
                print("Added a new user air data \(userAirData)")
                self.stack.save()
                
                let pollutionLevel = self.calculatePollutionLevel(value: userAirData.p10Value)
                
                print("Pollution Level \(pollutionLevel)")
                
                if pollutionLevel != self.lastPollutionLevel {
                    
                    self.scheduleNotification(inSeconds: 3, airData: result, pollutionLevel: pollutionLevel, completion: { success in
                        if success {
                            print("Successfully scheduled notification")
                        } else {
                            print("Error scheduling notification")
                        }
                    })
                    
                    self.lastPollutionLevel = pollutionLevel
                    
                }
                
            }
            
        } else {
            
            getAirdataAndCreateAnnotations(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            
        }
        
        print("Location found \(userLocation.coordinate)")
        
    }
    
    func getAirdataAndCreateAnnotations(latitude: Double, longitude: Double) {
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        AirDataClient.sharedInstance.getAirData(userLatitude: latitude, userLongitude: longitude) {
            (result, error ) in
            
            guard error == nil else {
                return
            }
            
            guard let result = result else {
                return
            }
            
            // Remove old annotations
            for annotation in self.mapView.annotations {
                self.mapView.removeAnnotation(annotation)
            }
            
            self.airDataArray = result
            
            print("Match found \(result.count)")
            
            var closestAirData:AirData!
            
            for airData in result {
                
                let annotation = AirDataAnnotation(airData: airData, valueTypeIndex: 0)
                
                
                if closestAirData != nil {
                    
                    var isPollutionDataIncluded:Bool = false
                    
                    for sensorDataElement in airData.sensorDataArray {
                        
                        if sensorDataElement.valueType == "P1" {
                            isPollutionDataIncluded = true
                        }
                    }
                    
                    if isPollutionDataIncluded && AirDataClient.checkIfDistanceIsCloser(userLatitude: latitude, userLongitude: longitude, sensorLatitude: airData.latitude, sensorLongitude: airData.longitude, closestLatitude: closestAirData.latitude, closestLongitude: closestAirData.longitude) {
                        closestAirData = airData
                    }
                    
                } else {
                    closestAirData = airData
                }
                
                self.mapView.addAnnotation(annotation)
            }
            
            if closestAirData != nil {
                let userAirData = UserAirData(airData: closestAirData, userLatitude: latitude, userLongitude: longitude, context: self.fetchedResultsController.managedObjectContext)
                print("Added a new user air data from foreground \(userAirData)")
                self.stack.save()
                
                self.lastPollutionLevel = self.calculatePollutionLevel(value: userAirData.p10Value)
                
                print("Last Pollution Level \(self.lastPollutionLevel)")
            }
            
        }
        
        self.mapView.setRegion(region, animated: true)
    }
    
    func calculatePollutionLevel(value:Double) -> Int {
        
        var level = value / 25
        
        if level > 4 {
            level = 4
        }
        
        return Int(level)
    }
    
    func scheduleNotification(inSeconds: TimeInterval, airData:AirData, pollutionLevel:Int, completion: @escaping (Bool) -> ()) {
        
        // Create Notification content
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = "Air Pollution Info!"
        
        var subtitle:String!
        
        switch pollutionLevel {
        case 0:
            subtitle = "Air pollution is very low in your area"
        case 1:
            subtitle = "Air pollution is low in your area"
            
        case 2:
            subtitle = "Air pollution is medium in your area"
            
        case 3:
            subtitle = "Air pollution is high in your area"
            
        default:
            subtitle = "Air pollution is very high in your area"
        }
        
        notificationContent.subtitle = subtitle
        notificationContent.body = "PM10: " + String(airData.sensorDataArray[0].value)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: inSeconds, repeats: false)
        
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                print("\(String(describing: error))")
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
    
    @objc func appEntersForeground() {
        if lastUserLocation != nil {
            getAirdataAndCreateAnnotations(latitude: lastUserLocation.coordinate.latitude, longitude: lastUserLocation.coordinate.longitude)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self, selector: "appEntersForeground", name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil )
        
        airPollutionAlarmLabel.layer.cornerRadius = 8
        airPollutionAlarmLabel.clipsToBounds = true
        
        
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
        
        
        AirDataClient.sharedInstance.getFeinstaubAlarm() {(result, error) in
            
            guard error == nil else {
                return
            }
            
            guard let result = result else {
                return
            }
            
            
            if result {
                
                self.airPollutionAlarmLabel.text = "Air Pollution Alert"
                self.airPollutionAlarmLabel.backgroundColor = UIColor.red
                
                
            } else {
                self.airPollutionAlarmLabel.text = "Currently No Air Pollution Alert"
                self.airPollutionAlarmLabel.backgroundColor = UIColor.green
                
            }
            
            
            print("Feinstaub result \(result)")
            
        }
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAirData")
        fr.sortDescriptors = []
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
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


extension MapViewController: NSFetchedResultsControllerDelegate {
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)")
            }
        }
    }
    
}

