//
//  Forecast.swift
//  Map Forecast Diary
//
//  Created by Abdelaziz Elrashed on 8/18/15.
//  Copyright (c) 2015 Abdelaziz Elrashed. All rights reserved.
//

import CoreData

@objc(Forecast)

class Forecast : NSManagedObject{
    
    struct Keys{
        static let ID = "id"
        static let Temp = "temp"
        static let Pressure = "pressure"
        static let Humidity = "humidity"
        static let TempMin = "temp_min"
        static let TempMax = "temp_max"
        static let WindSpeed = "wind_speed"
        static let WindDirection = "wind_direction"
        static let CreatedDate = "created_date"
    }
    
    @NSManaged var id:String
    @NSManaged var temp:NSNumber
    @NSManaged var pressure:NSNumber
    @NSManaged var humidity:NSNumber
    @NSManaged var temp_max:NSNumber
    @NSManaged var temp_min:NSNumber
    @NSManaged var wind_speed:NSNumber
    @NSManaged var wind_direction:NSNumber
    @NSManaged var created_date:NSDate
    
    @NSManaged var pin:Pin
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(data: NSDictionary ,context: NSManagedObjectContext?) {
        
        let entity = NSEntityDescription.entityForName("Forecast", inManagedObjectContext: context!)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        if let main = data.valueForKey("main") as? NSDictionary{
            
            if let temp = main.valueForKey("temp") as? Double{
                self.temp = temp
            }
            
            if let temp_max = main.valueForKey("temp_max") as? Double{
                self.temp_max = temp_max
            }
            
            if let temp_min = main.valueForKey("temp_min") as? Double{
                self.temp_min = temp_min
            }
            
            if let humidity = main.valueForKey("humidity") as? Int{
                self.humidity = humidity
            }
            
            if let pressure = main.valueForKey("pressure") as? Int{
                self.pressure = pressure
            }
        }
        
        if let wind = data.valueForKey("wind") as? NSDictionary{
            
            if let direction = wind.valueForKey("deg") as? Double{
                self.wind_direction = direction
            }
            
            if let speed = wind.valueForKey("speed") as? Double{
                self.wind_speed = speed
            }
        }
        
        id = NSUUID().UUIDString
        created_date = NSDate()
    }
}
