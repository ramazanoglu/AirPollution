//
//  VVSClient.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 13.12.17.
//  Copyright © 2017 zigzag. All rights reserved.
//

import UIKit
import Alamofire

class VVSClient: NSObject {
    static let sharedInstance = VVSClient()
    private override init() {}
    
    var stationLocationDictionary = [String:(Double, Double)]()
    
    
    func getStations(completinHandler: @escaping (_ result: [Station], _ error: String?) -> Void) {
        let urlRequest = "https://efa-api.asw.io/api/v1/station/"
        
        Alamofire.request(urlRequest).responseJSON { response in
            
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value {
                print("JSON created") // serialized json response
                
                
                if let array = json as? [Any] {
                    
                    var stationArray = [Station]()
                    
                    for object in array {
                        
                        let station = Station(fromDictionary: object as! [String:AnyObject])
                        
                        guard station != nil else  {
                            continue
                        }
                        
                        guard self.stationLocationDictionary[(station?.stationId)!] != nil else {
                            print("Cannot find the location for \(station?.stationId)")
                            continue
                        }
                        
                        station?.latitude = self.stationLocationDictionary[(station?.stationId)!]?.1
                        station?.longitude = self.stationLocationDictionary[(station?.stationId)!]?.0
                        
                        
                        stationArray.append(station!)
                        
                        
                    }
                    
                    completinHandler(stationArray, nil)
                    
                }
                
            }
        }
    }
    
    
    func readStationLocationFile() {
        guard let filepath = Bundle.main.path(forResource: "station_location_data", ofType: "txt")
            else {
                print("guard error")
                return
        }
        
        do {
            let contents = try String(contentsOfFile: filepath)
            
            let rows = contents.split(separator: "\n")
            
            for row in rows {
                
                let items = row.split(separator: ",")
                
                stationLocationDictionary.updateValue((Double(items[1])!, Double(items[2])!), forKey: String(items[0]))
                
            }
            
            
        } catch {
            print("File Read Error for file \(filepath)")
        }
    }
    
    func getDeparturesForStation(stationId:String, completionHandler: @escaping (_ result: [Departure], _ error: String?) -> Void) {
        let urlRequest = "https://efa-api.asw.io/api/v1/station/" + stationId + "/departures"
        
        
        Alamofire.request(urlRequest).responseJSON { response in
            
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value {
                print("JSON created") // serialized json response
                
                if let array = json as? [Any] {
                    
                    var departureArray = [Departure]()
                    
                    for object in array {
                        
                        let departure = Departure(fromDictionary: object as! [String:AnyObject])
                        
                        guard departure != nil else {
                            continue
                        }
                        
                        departureArray.append(departure!)
                        
                    }
                    
                    completionHandler(departureArray, nil)
                    
                }
                
            }
        }
        
    }
}
