//
//  DeparturesViewController.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 14.12.17.
//  Copyright © 2017 zigzag. All rights reserved.
//

import UIKit

class DeparturesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var departureTableView: UITableView!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var departureTimeLabel: UILabel!
    var station: Station?
    
    var departureArray = [Departure]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stationNameLabel.text = station?.fullName
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        
        departureTimeLabel.text = String(hour) + ":" + String(minutes)
        
        departureTableView.delegate = self
        departureTableView.dataSource = self
        
        VVSClient.sharedInstance.getDeparturesForStation(stationId: (station?.stationId)!, completionHandler: ({result, error in
            
            if error == nil {
                self.departureArray = result!
                self.departureTableView.reloadData()
            }
        }))
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return departureArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DepartureTableViewCell = self.departureTableView.dequeueReusableCell(withIdentifier: "departureTableCell") as! DepartureTableViewCell!
        
        
        let departure = departureArray[indexPath.row]
        
        cell.departureLabel.text = departure.departureTime
        cell.delayLabel.text = departure.delay + " min"
        cell.directionLabel.text = departure.direction
        cell.lineLabel.text = departure.number
        
        return cell
        
    }
    
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
}
