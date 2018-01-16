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
                    print("image downloaded: \(image)")
                    
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
                    print("image downloaded: \(image)")
                    
                    completionHandler(image, nil)
                }
                
            case  .failure(let error):
                print(error)
                completionHandler(nil, error.localizedDescription)
                
            }
        }
    
    }
    
    func getAirData(userLatitude:Double, userLongitude:Double, completinHandler: @escaping (_ result: [AirData], _ error: String?) -> Void) {
        
        let urlRequest = "https://api.luftdaten.info/v1/filter/area=" + String(userLatitude) + "," + String(userLongitude) + ",5"
        
        Alamofire.request(urlRequest).responseJSON { response in
            
            print("Result: \(response.result)")                         // response serialization result
            
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
                        
                        
                        //                        if (airData.longitude > userLongitude - 0.01 && airData.longitude < userLongitude + 0.01) && (airData.latitude > userLatitude - 0.01 && airData.latitude < userLatitude + 0.01) {
                        
                        airDataArray.append(airData)
                        
                        //                        }
                        
                        
                    }
                    
                    
                    completinHandler(airDataArray, nil)
                    
                }
                
            }
            
        }
        
    }
    
    
}
