//
//  HistoryViewController.swift
//  MemoryTraining
//
//  Created by Александр Подрабинович on 09/01/15.
//  Copyright (c) 2015 Alex Podrabinovich. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate  {

    @IBOutlet weak var historyTable: UITableView!
    
    let managedObject = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    var fetchedResultsController: NSFetchedResultsController = NSFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        fetchedResultsController = getFetchResultsController()
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //Table View Functions
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var historyCell: HistoryTableViewCell = self.historyTable.dequeueReusableCellWithIdentifier("historyCell") as HistoryTableViewCell

        let currentHistory = fetchedResultsController.objectAtIndexPath(indexPath) as History
        
        let calendar = NSCalendar.currentCalendar()
        let comp = calendar.components((.HourCalendarUnit | .MinuteCalendarUnit | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitYear), fromDate: currentHistory.date)
        let hour = comp.hour
        let minute = comp.minute
        let day = comp.day
        let month = comp.month
        let year = comp.year
        
        historyCell.levelLabel.text = "\(currentHistory.level)"
        historyCell.dateLabel.text = "\(day).\(month).\(year) \(hour):\(minute)"

        return historyCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    //End of Table View Functions
    
    //Data Core Functions
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.historyTable.reloadData()
    }
    
    func pillsFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "History")
        let activeSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [activeSortDescriptor]
        
        return fetchRequest
    }
    
    func getFetchResultsController() -> NSFetchedResultsController {
        fetchedResultsController = NSFetchedResultsController(fetchRequest: pillsFetchRequest(), managedObjectContext: managedObject, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }
    //Data Core Functions end
}
