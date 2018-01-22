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
import Charts

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var bubbleChartView: BubbleChartView!
    @IBOutlet weak var dateLabel: UILabel!
    
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
        
        
        // Initialize chart
        bubbleChartView.noDataText = "No data found for selected date"

        bubbleChartView.chartDescription?.enabled = false
        
        bubbleChartView.dragEnabled = false
        bubbleChartView.setScaleEnabled(false)
        bubbleChartView.maxVisibleCount = 200
        bubbleChartView.pinchZoomEnabled = false
        
        bubbleChartView.legend.horizontalAlignment = .center
        bubbleChartView.legend.verticalAlignment = .bottom
        bubbleChartView.legend.orientation = .horizontal
        bubbleChartView.legend.drawInside = false
        bubbleChartView.legend.font = UIFont(name: "HelveticaNeue-Light", size: 10)!
        
        bubbleChartView.leftAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
        bubbleChartView.leftAxis.spaceTop = 0.3
        bubbleChartView.leftAxis.spaceBottom = 0.3
        bubbleChartView.leftAxis.axisMinimum = 0
//        bubbleChartView.leftAxis.axisMaximum = 200
        
        bubbleChartView.rightAxis.enabled = false
        
        bubbleChartView.xAxis.axisMinimum = -20
        bubbleChartView.xAxis.axisMaximum = 20
        bubbleChartView.xAxis.drawLabelsEnabled = false
        
    
        
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
        
        let cal = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!

        var startDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        
        startDate = cal.startOfDay(for: startDate!)
        
        let endDate = Date()
        
        print("date starts ::  \(startDate) ends :: \(endDate)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy"

        
        dateLabel.text = String(describing: dateFormatter.string(from: endDate))
        
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
            
            
            //Set chart data
            setDataCount(minimum: minElement, maximum: maxElement, average: average, count: fetchedResults.count)


        } catch {
            print("catch fetch error")
        }
        
    }

    func setDataCount(minimum:Double!, maximum:Double!, average:Double, count:Int) {
        
        guard maximum != nil && minimum != nil &&  count > 0 else {
            return
        }
        
        
        let averageSize = max(min(12, average), 6)

        
        let yVals1 : [ChartDataEntry] = [BubbleChartDataEntry(x: 0, y: maximum, size: CGFloat(3))]
        
        let yVals2 : [ChartDataEntry] = [BubbleChartDataEntry(x: 0, y: average, size: CGFloat(averageSize))]
        
        let yVals3 : [ChartDataEntry] = [BubbleChartDataEntry(x: 0, y: minimum, size: CGFloat(3))]
        
        
        
        let set1 = BubbleChartDataSet(values: yVals1, label: "MAX")
        set1.drawIconsEnabled = false
        set1.setColor(UIColor.interpolateRGBColorTo(maximum)!, alpha: 0.5)
        set1.drawValuesEnabled = true
        set1.normalizeSizeEnabled = false
        
        let set2 = BubbleChartDataSet(values: yVals2, label: "Average")
        set2.drawIconsEnabled = false
        set2.setColor(UIColor.interpolateRGBColorTo(average)!, alpha: 0.5)
        set2.drawValuesEnabled = true
        set2.normalizeSizeEnabled = false
        set2.highlightEnabled = true
        
        let set3 = BubbleChartDataSet(values: yVals3, label: "MIN")
        set3.setColor(UIColor.interpolateRGBColorTo(minimum)!, alpha: 0.5)
        set3.drawValuesEnabled = true
        set3.normalizeSizeEnabled = false

        
        let data = BubbleChartData(dataSets: [set1, set2, set3])
        data.setDrawValues(false)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 7)!)
        data.setHighlightCircleWidth(1.5)
        data.setValueTextColor(.white)
        
        bubbleChartView.data = data
        
        bubbleChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
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
        
        cell.timeLabel.text = formatter.string(from: userAirDataArray[indexPath.row].timestamp! as Date)
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
