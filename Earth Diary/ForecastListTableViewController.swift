//
//  ForecastListTableViewController.swift
//  Earth Diary
//
//  Created by Abdelaziz Elrashed on 8/21/15.
//  Copyright (c) 2015 Abdelaziz Elrashed. All rights reserved.
//

import UIKit
import CoreData

class ForecastListTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {

    var pin:Pin!
    var selected_index:Int!
    var is_fetch_forecast_required: Bool = true
    
    @IBOutlet var tableViewObject: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.title = "Location Forecasts"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Analyze", style: UIBarButtonItemStyle.Plain, target: self, action: "analyze")
        
        // Get Reminder Date (which is Due date minus 2 hours lets say)
        var reminderDate = NSDate().addHours(-2)
            
        // check if last forcast was old than 2 hours, if so request new forecast
        let fc = pin.forecasts[pin.forecasts.count - 1]
        is_fetch_forecast_required =  reminderDate.isGreaterThanDate(fc.created_date)
        
        if is_fetch_forecast_required{

            showIndicator(true)
            
            OpenWeatherMap.GetTodayForecast("\(pin.lat)", lon: "\(pin.lon)", completion: { (data) -> Void in
                
                // error handler
                if let error = data.valueForKey("error") as? NSError{
                    
                    dispatch_async(dispatch_get_main_queue()){
                        self.showError(error.localizedDescription)
                    }
                    
                }else{
                    
                    // error handler
                    
                    if let message = data.valueForKey("message") as? String{
                        
                        dispatch_async(dispatch_get_main_queue()){
                            self.showError(message)
                        }
                        
                    }else{
                        
                        dispatch_async(dispatch_get_main_queue()){
                            
                            var forcast = Forecast(data:data, context: self.sharedContext)
                            
                            forcast.pin = self.pin
                            
                            CoreDataStackManager.sharedInstance().saveContext()
                            
                            self.finishFetchedForcasts()
                        }
                    }
                }
            })
        }
    }
    
    func finishFetchedForcasts(){
        
        showIndicator(false)
        
        if let updatedPin = self.getUpdatedPin(){
            pin = updatedPin
        }
        
        tableViewObject.reloadData()
    }
    
    func showIndicator(state: Bool){
        
        navigationItem.leftBarButtonItem?.enabled = !state
        navigationItem.rightBarButtonItem?.enabled = !state
        
        if state{
            
            navigationItem.title = "Fetching Forecasts..."
            
        }else{
            
            navigationItem.title = "Location Forecasts"
        }
    }
    
    func showError(error: String){
        var alert = UIAlertController(title: "Alert", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
        showIndicator(false)
    }
    
    // MARK: - tableView
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pin.forecasts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        let fc = pin.forecasts[indexPath.row]
        
        cell.textLabel?.text = "Temp: \(fc.temp), T.Max: \(fc.temp_max), T.Min: \(fc.temp_min)"
        cell.detailTextLabel?.text = "\(fc.created_date)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selected_index = indexPath.row
        performSegueWithIdentifier("show_forecast_details", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show_forecast_details"{
            let vc = segue.destinationViewController as! ForecastViewController
            vc.forcast = pin.forecasts[selected_index]
        }
        
        if segue.identifier == "analyze"{
            let vc = segue.destinationViewController as! AnalyzeViewController
            vc.pin = pin
        }
    }
    
    func analyze(){
        performSegueWithIdentifier("analyze", sender: self)
    }
    
    // MARK: - CoreData
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    // Mark: - Fetched Results
    
    func getUpdatedPin() -> Pin?{
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.predicate = NSPredicate(format: "id == %@", self.pin.id)
        
        let fetchedEntities = self.sharedContext.executeFetchRequest(fetchRequest, error: nil) as! [Pin]
        return fetchedEntities.first
    }
}
