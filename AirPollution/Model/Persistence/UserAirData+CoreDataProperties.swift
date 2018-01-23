//
//  UserAirData+CoreDataProperties.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 18.01.18.
//  Copyright © 2018 zigzag. All rights reserved.
//
//

import Foundation
import CoreData


extension UserAirData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserAirData> {
        return NSFetchRequest<UserAirData>(entityName: "UserAirData")
    }

    @NSManaged public var p2Value: Double
    @NSManaged public var p10Value: Double
    @NSManaged public var sensorLatitude: Double
    @NSManaged public var sensorLongitude: Double
    @NSManaged public var timestamp: NSDate?
    @NSManaged public var userLatitude: Double
    @NSManaged public var userLongitude: Double
    @NSManaged public var address: String!

}
