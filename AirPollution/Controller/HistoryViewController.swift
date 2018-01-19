//
//  HistoryViewController.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 19.01.18.
//  Copyright © 2018 zigzag. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    @IBOutlet weak var historyTableView: UITableView!
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>! {
        didSet {
            fetchedResultsController.delegate = self
            executeSearch()
        }
    }
    
    var userAirDataArray:[UserAirData]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
        let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!

        var startDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        
        startDate = cal.startOfDay(for: startDate!)
        
        let endDate = Date()
        
        print("date starts ::  \(startDate) ends :: \(endDate)")
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "UserAirData")
        fr.sortDescriptors = []
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fr.predicate = NSPredicate(format: "timestamp > %@ AND timestamp < %@", startDate! as NSDate, endDate as NSDate)
        
        
        do {
            let fetchedResults = try stack.context.fetch(fr) as! [UserAirData]

            self.userAirDataArray = fetchedResults
            
            print(fetchedResults.count)
            
            let maxElement = fetchedResults.map{$0.p10Value}.max()
            let minElement = fetchedResults.map{$0.p10Value}.min()
            
            let average = fetchedResults.map{$0.p10Value}.reduce(0, +) / Double(fetchedResults.count)
            
            print("Max \(maxElement) and min \(minElement) average :: \(average)")


        } catch {
            print("catch fetch error")
        }
        
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (userAirDataArray?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HistoryTableViewCell = self.historyTableView.dequeueReusableCell(withIdentifier: "historyTableViewCell") as! HistoryTableViewCell!
        
        
        geocode(latitude: userAirDataArray[indexPath.row].userLatitude, longitude: userAirDataArray[indexPath.row].userLongitude) { placemark, error in
            guard let placemark = placemark, error == nil else { return }
            DispatchQueue.main.async {
                
                cell.addressLabel.text = placemark.thoroughfare

            }
        }

        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date
        formatter.dateFormat = "HH:mm:ss"
        
        cell.timeLabel.text = formatter.string(from: userAirDataArray[indexPath.row].timestamp as! Date)
        cell.pollutionLabel.text = String(userAirDataArray[indexPath.row].p10Value)
      
        
        return cell
        
    }
    
    func geocode(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?, Error?) -> ())  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                completion(nil, error)
                return
            }
            completion(placemark, nil)
        }
    }

}

extension HistoryViewController: NSFetchedResultsControllerDelegate {
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)")
            }
        }
    }
    
}
