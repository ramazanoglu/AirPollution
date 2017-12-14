//
//  StationAnnotation.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 14.12.17.
//  Copyright © 2017 zigzag. All rights reserved.
//

import UIKit
import MapKit

class StationAnnotation:  NSObject, MKAnnotation {
    var coordinate = CLLocationCoordinate2D()
    var title: String?
    var subtitle: String?
    var station: Station?
    
}
