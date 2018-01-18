//
//  UserAirData+CoreDataClass.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 18.01.18.
//  Copyright © 2018 zigzag. All rights reserved.
//
//

import Foundation
import CoreData

@objc(UserAirData)
public class UserAirData: NSManagedObject {
    
    convenience init(airData:AirData, userLatitude:Double, userLongitude:Double, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "UserAirData", in: context) {
            
            self.init(entity: ent, insertInto: context)
            
            self.sensorLatitude = airData.latitude
            self.sensorLongitude = airData.longitude
            self.userLatitude = userLatitude
            self.userLongitude = userLongitude
            self.timestamp = NSDate()
            
            for sensorData:SensorData in airData.sensorDataArray {
                
                if sensorData.valueType == "P1" {
                    self.p10Value = sensorData.value
                } else if sensorData.valueType == "P2" {
                    self.p2Value = sensorData.value
                }
            }
            
        } else {
            fatalError("Unable to find Entity Name")
        }
        
    }
    
}
