//
//  SensorData.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 08.12.17.
//  Copyright © 2017 zigzag. All rights reserved.
//

import UIKit

class SensorData: NSObject {

    var id: Int!
    var value: Double!
    var valueType: String!
    
    
    init(fromDictionary dictionary:[String:AnyObject]) {
        self.value = (dictionary["value"] as! NSString).doubleValue
        self.valueType = dictionary["value_type"] as! String
        self.id = dictionary["id"] as! Int
    }
    
}
