//
//  ListViewController.swift
//  Earth Diary
//
//  Created by Abdelaziz Elrashed on 8/21/15.
//  Copyright (c) 2015 Abdelaziz Elrashed. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    var selected_index:NSIndexPath!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "exitApp")
        navigationItem.title = "Earth Diary"
        
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchedResultsController.performFetch(nil)
        tableView.reloadData()
    }
    
    // MARK: - tableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let info = fetchedResultsController.sections![0] as! NSFetchedResultsSectionInfo
        return info.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        
        let pin = fetchedResultsController.objectAtIndexPath(indexPath) as! Pin
        cell.textLabel?.text = pin.name
        cell.detailTextLabel?.text = pin.base
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selected_index = indexPath
        performSegueWithIdentifier("show_forecasts", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show_forecasts"{
            let vc = segue.destinationViewController as! ForecastListTableViewController
            let pin = fetchedResultsController.objectAtIndexPath(selected_index) as! Pin
            vc.pin = pin
        }
    }
    
    func exitApp(){
        
        var alert = UIAlertController(title: "Alert", message: "Do you want to Exit?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                exit(0)
                
            case .Cancel:
                return
                
            case .Destructive:
                return
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - CoreData
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    // Mark: - Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Pin.Keys.CreatedDate, ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
}
