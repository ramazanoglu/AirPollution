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
                return
            }
        
            guard let result = result else {
                return
            }
            
            
           self.lastDayImageView.image = result
            
        }
        
        AirDataClient.sharedInstance.getFloatingImage(sensorId: airData.sensorId) {
            (result, error ) in
            
            self.activityIndicator.hideActivityIndicator()
            
            guard error == nil else {
                return
            }
            
            guard let result = result else {
                return
            }
            
            self.floatingImageView.image = result
            
        }

    }

    @IBAction func onBackPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
