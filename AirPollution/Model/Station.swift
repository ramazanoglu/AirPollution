//
//  Station.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 13.12.17.
//  Copyright © 2017 zigzag. All rights reserved.
//

import UIKit

class Station: NSObject {
    
    var stationId: String!
    var name: String!
    var fullName: String!
    var latitude: Double!
    var longitude: Double!

    
    init?(fromDictionary dictionary:[String:AnyObject]) {
        
        guard let stationId = dictionary["stationId"] as? String else {
            print("Station Id parse")
            return nil
        }
        
        self.stationId = stationId
        
        guard let name = dictionary["name"] as? String else {
            print("name parse")
            return nil
        }
        
        self.name = name
        
        guard let fullName = dictionary["fullName"] as? String else {
            print("fullName parse")
            return nil
        }

        self.fullName = fullName
        
    }
}
