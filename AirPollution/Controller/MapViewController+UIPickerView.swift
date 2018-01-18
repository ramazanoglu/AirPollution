//
//  MapViewController+UIPickerView.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 18.01.18.
//  Copyright © 2018 zigzag. All rights reserved.
//

import Foundation
import UIKit

extension MapViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AirDataAnnotation.airDataTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return AirDataAnnotation.airDataTypes[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        for annotation in mapView.annotations {
            
            mapView.removeAnnotation(annotation)
            
        }
        
        for airData in self.airDataArray {
            let annotation = AirDataAnnotation(airData: airData, valueTypeIndex: row)
            
            
            self.mapView.addAnnotation(annotation)
        }
        
        UIView.animate(withDuration: 0.5, animations: ({
            
            self.legendView.backgroundColor = UIColor.white;
            
            self.legendView.frame = CGRect(x: 0.0, y: self.view.frame.size.height, width: self.view.frame.size.width, height:200.0)
            
        })
            
            
        )
        
        
    }
}
