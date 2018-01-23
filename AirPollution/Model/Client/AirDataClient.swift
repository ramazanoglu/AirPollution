//
//  AirDataClient.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 08.12.17.
//  Copyright © 2017 zigzag. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class AirDataClient: NSObject {
    static let sharedInstance = AirDataClient()
    private override init() {}
    
    
    func getLastDayImage(sensorId:Int, completionHandler: @escaping (_ result: UIImage?, _ error: String?) -> Void) {
        let url = "https://api.luftdaten.info/grafana/render/dashboard-solo/db/single-sensor-view?orgId=1&panelId=2&width=300&height=200&tz=UTC%2B02%3A00&var-node=" + String(sensorId)
        
        Alamofire.request(url).validate().responseImage { response in
            
            switch response.result {
            case .success:
                
                if let image = response.result.value {
                    completionHandler(image, nil)
                }
                
            case  .failure(let error):
                print(error)
                completionHandler(nil, error.localizedDescription)
                
            }
        }
        
    }
    
    func getFloatingImage(sensorId:Int, completionHandler: @escaping (_ result: UIImage?, _ error: String?) -> Void) {
        let url =  "https://api.luftdaten.info/grafana/render/dashboard-solo/db/single-sensor-view?orgId=1&panelId=1&width=300&height=200&tz=UTC%2B02%3A00&var-node=" + String(sensorId)
        
        Alamofire.request(url).validate().responseImage { response in
            
            switch response.result {
            case .success:
                
                if let image = response.result.value {
                    completionHandler(image, nil)
                }
                
            case  .failure(let error):
                print(error)
                completionHandler(nil, error.localizedDescription)
                
            }
        }
        
    }
    
    func getClosestAirData(userLatitude:Double, userLongitude:Double, completionHandler: @escaping (_ result: AirData?, _ error: String?) -> Void) {
        
        let urlRequest = "https://api.luftdaten.info/v1/filter/area=" + String(userLatitude) + "," + String(userLongitude) + ",1"
        
        Alamofire.request(urlRequest).validate().responseJSON { response in
            
            print("Result: \(response.result)")                         // response serialization result
            
            switch response.result {
            case .success:
                
                if let json = response.result.value {
                    print("JSON created") // serialized json response
                    
                    
                    if let array = json as? [Any] {
                        
                        var closestAirData:AirData!
                        
                        for object in array {
                            // access all objects in array
                            
                            let airData = AirData()
                            
                            let element = object as! [String:AnyObject]
                            
                            let id = element["id"] as! Int
                            
                            airData.id = id
                            
                            let location = element["location"] as! [String:AnyObject]
                            
                            let country = location["country"] as! String
                            let latitude = location["latitude"] as! NSString
                            
                            
                            guard let longitude = location["longitude"] as? NSString else  {
                                continue
                            }
                            
                            airData.longitude = longitude.doubleValue
                            
                            
                            let sensor = element["sensor"] as! [String:AnyObject]
                            
                            let sensorId = sensor["id"] as! Int
                            
                            
                            airData.sensorId = sensorId
                            
                            
                            airData.country = country
                            airData.latitude = latitude.doubleValue
                            
                            let sensorDataArray = element["sensordatavalues"] as! [AnyObject]
                            
                            var isPollutionDataIncluded:Bool = false
                            
                            for sensorDataElement in sensorDataArray {
                                let data = sensorDataElement as! [String: AnyObject]
                                
                                let sensorData = SensorData(fromDictionary: data)
                                
                                airData.sensorDataArray.append(sensorData)
                                
                                if sensorData.valueType == "P1" {
                                    isPollutionDataIncluded = true
                                }
                                
                                
                            }
                            
                            if closestAirData != nil {
                                
                                if !isPollutionDataIncluded {
                                    continue
                                }
                                
                                
                                if AirDataClient.checkIfDistanceIsCloser(userLatitude: userLatitude, userLongitude: userLongitude, sensorLatitude: latitude.doubleValue, sensorLongitude: longitude.doubleValue, closestLatitude: closestAirData.latitude, closestLongitude: closestAirData.longitude) {
                                    closestAirData = airData
                                }
                                
                            } else {
                                closestAirData = airData
                            }
                            
                        }
                        
                        completionHandler(closestAirData, nil)
                        
                    }
                    
                }
                
            case  .failure(let error):
                print(error)
                completionHandler(nil, error.localizedDescription)
                
            }
            
        }
        
    }
    
    static func checkIfDistanceIsCloser(userLatitude:Double, userLongitude:Double, sensorLatitude:Double, sensorLongitude:Double, closestLatitude:Double, closestLongitude:Double) -> Bool {
        
        let distance:Double = (sensorLongitude - userLongitude) * (sensorLongitude - userLongitude) + (sensorLatitude - userLatitude) * (sensorLatitude - userLatitude)
        
        let closestDistance:Double =  (closestLongitude - userLongitude) * (closestLongitude - userLongitude) + (closestLatitude - userLatitude) * (closestLatitude - userLatitude)
        
        return distance < closestDistance
        
    }
    
    
    func getFeinstaubAlarm(completionHandler: @escaping (_ result: Bool?, _ error: String?) -> Void) {
        
        let urlRequest = "http://istheutefeinstaubalarm.rocks/api/alarm"
        
        Alamofire.request(urlRequest).validate().responseJSON { response in
            
            print("Result: \(response.result)")                         // response serialization result
            
            switch response.result {
            case .success:
                if let json = response.result.value {
                    
                    if let object = json as? [String:AnyObject] {
                        
                        
                        let feinstaubAlarm = object["feinstaubalarm"] as! Bool
                        
                        completionHandler(feinstaubAlarm, nil)
                        
                    }
                }
            case .failure(let error):
                print(error)
                completionHandler(nil, error.localizedDescription)
            }
        }
    }
    
    func getAirData(userLatitude:Double, userLongitude:Double, completionHandler: @escaping (_ result: [AirData]?, _ error: String?) -> Void) {
        
        let urlRequest = "https://api.luftdaten.info/v1/filter/area=" + String(userLatitude) + "," + String(userLongitude) + ",5"
        
        Alamofire.request(urlRequest).validate().responseJSON { response in
            
            print("Result: \(response.result)")                         // response serialization result
            
            switch response.result {
            case .success:
                
                if let json = response.result.value {
                    print("JSON created") // serialized json response
                    
                    
                    if let array = json as? [Any] {
                        
                        var airDataArray = [AirData]()
                        
                        var sensorIdSet = Set<Int>.init()
                        
                        for object in array {
                            // access all objects in array
                            
                            let airData = AirData()
                            
                            let element = object as! [String:AnyObject]
                            
                            let id = element["id"] as! Int
                            
                            airData.id = id
                            
                            let location = element["location"] as! [String:AnyObject]
                            
                            let country = location["country"] as! String
                            let latitude = location["latitude"] as! NSString
                            
                            
                            guard let longitude = location["longitude"] as? NSString else  {
                                continue
                            }
                            
                            airData.longitude = longitude.doubleValue
                            
                            
                            let sensor = element["sensor"] as! [String:AnyObject]
                            
                            let sensorId = sensor["id"] as! Int
                            
                            if sensorIdSet.contains(sensorId) {
                                continue
                            } else {
                                sensorIdSet.insert(sensorId)
                            }
                            
                            airData.sensorId = sensorId
                            
                            
                            airData.country = country
                            airData.latitude = latitude.doubleValue
                            
                            let sensorDataArray = element["sensordatavalues"] as! [AnyObject]
                            
                            for sensorDataElement in sensorDataArray {
                                let data = sensorDataElement as! [String: AnyObject]
                                
                                let sensorData = SensorData(fromDictionary: data)
                                
                                airData.sensorDataArray.append(sensorData)
                                
                            }
                            
                            airDataArray.append(airData)
                            
                        }
                        
                        completionHandler(airDataArray, nil)
                        
                    }
                    
                }
                
            case  .failure(let error):
                print(error)
                completionHandler(nil, error.localizedDescription)
                
            }
        }
        
    }
    
    
}
