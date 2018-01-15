//
//  PollutionDetailViewController.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 18.12.17.
//  Copyright © 2017 zigzag. All rights reserved.
//

import UIKit

class PollutionDetailViewController: UIViewController {

    @IBOutlet weak var floatingImageView: UIImageView!
    @IBOutlet weak var lastDayImageView: UIImageView!
    var airData:AirData!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        AirDataClient.sharedInstance.getLastDayImage(sensorId: airData.sensorId) {
            (result, error ) in
        
            if error == nil {
                self.lastDayImageView.image = result
            }
        }
        
        AirDataClient.sharedInstance.getFloatingImage(sensorId: airData.sensorId) {
            (result, error ) in
            
            if error == nil {
                self.floatingImageView.image = result
            }
        }

    }

    @IBAction func onBackPressed(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
