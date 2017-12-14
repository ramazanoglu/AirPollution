//
//  Departure.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 14.12.17.
//  Copyright © 2017 zigzag. All rights reserved.
//

import UIKit

class Departure: NSObject {
    
    var direction: String!
    var delay: String!
    var stopName: String!
    var departureTime: String!
    var number: String!
    
    init?(fromDictionary dictionary:[String:AnyObject]) {
        
        guard let direction = dictionary["direction"] as? String else {
            print("Direction parse")
            return nil
        }
        
        self.direction = direction
        
        guard let delay = dictionary["delay"] as? String else {
            print("delay parse")
            return nil
        }
        
        self.delay = delay
        
        guard let stopName = dictionary["stopName"] as? String else {
            print("stopName parse")
            return nil
        }
        
        self.stopName = stopName
        
        guard let departureTime = dictionary["departureTime"] as? [String:AnyObject] else {
            print("departureTime")
            return nil
        }
        
        guard let hour = departureTime["hour"] as? String else {
            print("hour")
            return nil
        }
        
        guard let minute = departureTime["minute"] as? String else {
            print("minute")
            return nil
        }
        
        self.departureTime = hour + ":" + minute
        
        guard let number = dictionary["number"] as? String else {
            print("number")
            return nil
        }
        
        self.number = number
        
    }
    
}
