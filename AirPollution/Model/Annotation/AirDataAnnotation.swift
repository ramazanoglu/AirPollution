//
//  AirDataAnnotation.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 12.12.17.
//  Copyright © 2017 zigzag. All rights reserved.
//

import UIKit
import MapKit

class AirDataAnnotation: NSObject, MKAnnotation {
    var coordinate = CLLocationCoordinate2D()
    var title: String?
    var subtitle: String?
    var image: UIImage?
    var color: UIColor?
    var airData: AirData?
    
    static var airDataTypes: [(query: String, title: String)] = [
        
        (query: "P1", title: "P 10"),
        (query: "P2", title: "P 2.5"),
        (query: "temperature", title: "Temperature"),
        (query: "humidity", title: "Humidity"),
        (query: "pressure", title: "Pressure")
        
        
    ]
    
    
    init(airData: AirData, valueTypeIndex:Int) {
        super.init()
        self.coordinate = CLLocationCoordinate2D(latitude: airData.latitude, longitude: airData.longitude)
        
        self.airData = airData
        
        adjustCircle(valueTypeIndex: valueTypeIndex)
        
    }
    
    func adjustCircle(valueTypeIndex:Int) {
        
        guard let airData = airData else {
            print("air data nil")
            return
        }
        
        for sensorData in (airData.sensorDataArray)! {
            
            if sensorData.valueType == AirDataAnnotation.airDataTypes[valueTypeIndex].query {
                
                switch sensorData.valueType {
                    
                case "P1":
                    setColorAndValue(sensorData: sensorData, baseValue: 500, valueTypeIndex: valueTypeIndex)
                    
                    return
                case "P2":
                    setColorAndValue(sensorData: sensorData, baseValue: 500, valueTypeIndex: valueTypeIndex)
                    
                    return
                    
                case "humidity":
                    setColorAndValue(sensorData: sensorData, baseValue: 100, valueTypeIndex: valueTypeIndex)
                    
                    return
                case "pressure":
                    setColorAndValue(sensorData: sensorData, baseValue: 100000, valueTypeIndex: valueTypeIndex)
                    
                    return
                case "temperature":
                    setColorAndValue(sensorData: sensorData, baseValue: 35, valueTypeIndex: valueTypeIndex)
                    
                    return
                default:
                    color = UIColor.clear
                    
                }
            } else {
                color = UIColor.clear
            }
            
        }
    }
    
    func setColorAndValue(sensorData: SensorData, baseValue: Double, valueTypeIndex:Int) {
        
        var hue = CGFloat(0.3 + sensorData.value / baseValue)
        
        if hue > 1 {
            hue = 1
        }
        
        color = UIColor.init(hue: hue, saturation: 1, brightness: 1, alpha: 0.25)
        
        title = String(sensorData.value)
        subtitle = AirDataAnnotation.airDataTypes[valueTypeIndex].title
        
    }
}

