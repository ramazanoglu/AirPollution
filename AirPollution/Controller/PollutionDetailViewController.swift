//
//  PollutionDetailViewController.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 18.12.17.
//  Copyright © 2017 zigzag. All rights reserved.
//

import UIKit

class PollutionDetailViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var floatingImageView: UIImageView!
    @IBOutlet weak var lastDayImageView: UIImageView!
    
    var airData:AirData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.showActivityIndicator()
        
        // Do any additional setup after loading the view.
        
        AirDataClient.sharedInstance.getLastDayImage(sensorId: airData.sensorId) {
            (result, error ) in
            
            self.activityIndicator.hideActivityIndicator()
            
            guard error == nil else {
                self.showAlertDialog(message: error!)
                
                return
            }
            
            guard let result = result else {
                self.showAlertDialog(message: "Couldn't load last day data")
                
                return
            }
            
            
            self.lastDayImageView.image = result
            
        }
        
        AirDataClient.sharedInstance.getFloatingImage(sensorId: airData.sensorId) {
            (result, error ) in
            
            self.activityIndicator.hideActivityIndicator()
            
            guard error == nil else {
                self.showAlertDialog(message: error!)
                
                return
            }
            
            guard let result = result else {
                self.showAlertDialog(message: "Couldn't load 24h floating data")
                
                return
            }
            
            self.floatingImageView.image = result
            
        }
        
    }
    
    func showAlertDialog(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
