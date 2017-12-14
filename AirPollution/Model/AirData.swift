//
//  AirData.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 08.12.17.
//  Copyright © 2017 zigzag. All rights reserved.
//

import UIKit

class AirData: NSObject {
    
    var id: Int!
    var country: String!
    var latitude: Double!
    var longitude: Double!
    var sensorDataArray: [SensorData]!
    
    override init() {
        self.sensorDataArray = [SensorData]()
    }

}
