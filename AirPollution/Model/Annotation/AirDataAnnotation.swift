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
                    title = String(sensorData.value)
                    subtitle = AirDataAnnotation.airDataTypes[valueTypeIndex].title
                    
                    color = UIColor.interpolateRGBColorTo(sensorData.value)
                    
                    return
                case "P2":
                    title = String(sensorData.value)
                    subtitle = AirDataAnnotation.airDataTypes[valueTypeIndex].title
                    
                    color = UIColor.interpolateRGBColorTo(sensorData.value)
                    
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

struct ColorComponents {
    var r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat
}


extension UIColor {
    
  static  func interpolateRGBColorTo(_ value: Double) -> UIColor? {
        
        var endColor:UIColor
        var fraction:CGFloat
        var startColor:UIColor
    
    
        if value <= 20 {
            fraction = CGFloat(value / 20)
            endColor =  UIColor(red: 0, green: 121 / 255, blue: 107 / 255, alpha: 0.7)
            startColor = UIColor.green
        } else if value <= 40 {
            fraction = CGFloat(value / 40)
            endColor = UIColor(red: 249 / 255, green: 168 / 255, blue: 37 / 255, alpha: 0.7)
            startColor =  UIColor(red: 0, green: 121 / 255, blue: 107 / 255, alpha: 0.7)

        } else if value <= 60 {
            fraction = CGFloat(value / 60)
            endColor = UIColor(red: 230 / 255, green: 81 / 255, blue: 0, alpha: 0.7)
            startColor = UIColor(red: 249 / 255, green: 168 / 255, blue: 37 / 255, alpha: 0.7)

        } else if value <= 100 {
            fraction = CGFloat(value / 100)
            endColor = UIColor(red: 221 / 255, green: 44 / 255, blue: 0, alpha: 0.7)
            startColor =  UIColor(red: 230 / 255, green: 81 / 255, blue: 0, alpha: 0.7)
        } else {
            fraction = CGFloat(value / 100)
            endColor = UIColor(red: 140 / 255, green: 0, blue: 132 / 255, alpha: 0.7)
            startColor = UIColor(red: 221 / 255, green: 44 / 255, blue: 0, alpha: 0.7)
        }
        
        let f = min(max(0, fraction), 1)
        
        let c1 = startColor.getComponents()
        let c2 = endColor.getComponents()
        
       
        let r = c1.r + (c2.r - c1.r) * f
        let g = c1.g + (c2.g - c1.g) * f
        let b = c1.b + (c2.b - c1.b) * f
        let a = c1.a + (c2.a - c1.a) * f
    
    
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func getComponents() -> ColorComponents {
        if (cgColor.numberOfComponents == 2) {
            let cc = cgColor.components!
            return ColorComponents(r:cc[0], g:cc[0], b:cc[0], a:cc[1])
        }
        else {
            let cc = cgColor.components!
            return ColorComponents(r:cc[0], g:cc[1], b:cc[2], a:cc[3])
        }
    }

}

