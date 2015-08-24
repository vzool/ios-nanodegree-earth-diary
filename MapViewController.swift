//
//  ViewController.swift
//  Map Forecast Diary
//
//  Created by Abdelaziz Elrashed on 8/18/15.
//  Copyright (c) 2015 Abdelaziz Elrashed. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var lpgr: UILongPressGestureRecognizer!
    
    var selected_pin:Pin!
    var selected_annotation:MapPoint!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "exitApp")
        navigationItem.title = "Earth Diary"
        
        lpgr = UILongPressGestureRecognizer(target: self, action: "gestureHandler:")
        lpgr.minimumPressDuration = 1.0
        
        mapView.addGestureRecognizer(lpgr)
        
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
        
        loadPins()
        
        showIndicator(true)
    }
    
    var long_pressed_once = false
    
    func gestureHandler(gestureRecognizer:UIGestureRecognizer){
        
        if !long_pressed_once{
            
            let touchPoint = gestureRecognizer.locationInView(mapView)
            
            var newCoord:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
            
            var newAnotation = MapPoint()
            newAnotation.coordinate = newCoord
            selected_annotation = newAnotation
            mapView.addAnnotation(newAnotation)
            
            dispatch_async(dispatch_get_main_queue()){
                self.showIndicator(true)
            }
            
            OpenWeatherMap.GetTodayForecast("\(newCoord.latitude)", lon: "\(newCoord.longitude)", completion: { (data: NSDictionary) -> Void in
                
                // error handler
                if let error = data.valueForKey("error") as? NSError{
                    
                    dispatch_async(dispatch_get_main_queue()){
                        
                        self.showError(error.localizedDescription)
                        
                        self.mapView.removeAnnotation(self.selected_annotation)
                    }

                }else{
                    
                    // error handler
                    
                    if let message = data.valueForKey("message") as? String{
                        
                        dispatch_async(dispatch_get_main_queue()){
                            self.showError(message)
                            self.mapView.removeAnnotation(self.selected_annotation)
                        }
                        
                    }else{
                        
                        dispatch_async(dispatch_get_main_queue()){
                            
                            var forcast = Forecast(data:data, context: self.sharedContext)
                            
                            var pin = Pin(data: data, context: self.sharedContext)
                            
                            pin.lat = newCoord.latitude
                            pin.lon = newCoord.longitude
                            
                            forcast.pin = pin
                            self.selected_pin = pin
                            
                            CoreDataStackManager.sharedInstance().saveContext()
                            
                            if let name = data.valueForKey("name") as? String{
                                
                                var word = "Forecast"
                                word += pin.forecasts.count > 1 ? "s" : ""
                                
                                if pin.forecasts.count <= 0{
                                    word = "No \(word)s"
                                }else{
                                    word = "\(pin.forecasts.count) \(word)"
                                }
                                
                                self.selected_annotation.title = word
                                self.selected_annotation.pin = pin
                            }
                            
                            self.goToFirstForcast()
                        }
                    }
                }
            })
        }
        
        long_pressed_once = !long_pressed_once
    }
    
    func goToFirstForcast(){
        showIndicator(false)
        performSegueWithIdentifier("show_pin_forecast", sender: self)
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
    
    func showIndicator(state:Bool){
        
        indicator.hidden = !state
        navigationItem.leftBarButtonItem?.enabled = !state
        lpgr.enabled = !state
        
        if state{
            indicator.startAnimating()
        }else{
            indicator.stopAnimating()
        }
    }
    
    func showError(error: String){
        var alert = UIAlertController(title: "Alert", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
        showIndicator(false)
    }
    
    // MARK: - mapView
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView!) {
        showIndicator(false)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            if let pin = annotationView.annotation as? MapPoint{
                
                self.selected_pin = pin.pin
                
                performSegueWithIdentifier("show_forecasts", sender: self)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show_pin_forecast"{
            let vc = segue.destinationViewController as! ForecastViewController
            vc.pin = self.selected_pin
        }
        
        if segue.identifier == "show_forecasts"{
            let vc = segue.destinationViewController as! ForecastListTableViewController
            vc.pin = self.selected_pin
        }
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
    
    func loadPins(){
        
        mapView.removeAnnotations(mapView.annotations)
        
        if let info = fetchedResultsController.sections![0] as? NSFetchedResultsSectionInfo{
            
            var annotations = [MKPointAnnotation]()
            
            for(var i = 0; i < info.numberOfObjects; i++){
                
                let pin = fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as! Pin
                
                let lat = CLLocationDegrees(pin.lat.doubleValue)
                let long = CLLocationDegrees(pin.lon.doubleValue)
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                var annotation = MapPoint()
                annotation.coordinate = coordinate
                
                var word = "Forecast"
                word += pin.forecasts.count > 1 ? "s" : ""
                
                if pin.forecasts.count <= 0{
                    word = "No \(word)s"
                }else{
                    word = "\(pin.forecasts.count) \(word)"
                }
                
                annotation.title = word
                
                annotation.pin = pin
                
                annotations.append(annotation)
            }
            
            mapView.addAnnotations(annotations)
        }
    }
}
