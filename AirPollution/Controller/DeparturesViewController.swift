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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
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
        
        activityIndicator.showActivityIndicator()
        
        VVSClient.sharedInstance.getDeparturesForStation(stationId: (station?.stationId)!, completionHandler: ({result, error in
            
            self.activityIndicator.hideActivityIndicator()
            
            guard error == nil else {
                self.showAlertDialog(message: error!)
                return
            }
            
            guard let result = result else {
                self.showAlertDialog(message: "Couldn't load data")
                return
            }
            
            self.departureArray = result
            self.departureTableView.reloadData()
        }))
        
    }
    
    func showAlertDialog(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return departureArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DepartureTableViewCell = self.departureTableView.dequeueReusableCell(withIdentifier: "departureTableCell") as! DepartureTableViewCell!
        
        
        let departure = departureArray[indexPath.row]
        
        cell.departureLabel.text = departure.departureTime
        
        if departure.delay != "0" {
            cell.delayLabel.text = "+" + departure.delay + " min"
        } else {
            cell.delayLabel.text = ""
        }
        cell.directionLabel.text = departure.direction
        cell.lineLabel.text = "Line: " + departure.number
        
        if departure.delay != "0" {
            cell.backgroundColor = UIColor.red
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
        
    }
    
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
}
