//
//  ViewController+AlertDialog.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 26.01.18.
//  Copyright © 2018 zigzag. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlertDialog(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
}
