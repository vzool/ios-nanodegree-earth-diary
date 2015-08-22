//
//  Pin.swift
//  Map Forecast Diary
//
//  Created by Abdelaziz Elrashed on 8/18/15.
//  Copyright (c) 2015 Abdelaziz Elrashed. All rights reserved.
//

import CoreData

@objc(Pin)

class Pin : NSManagedObject{

    struct Keys{
        
        static let ID = "ID"
        static let Lat = "lat"
        static let Lon = "lon"
        static let Base = "base"
        static let Name = "name"
        static let CreatedDate = "created_date"
    }
    
    @NSManaged var id:String
    
    @NSManaged var lat:NSNumber
    @NSManaged var lon:NSNumber
    @NSManaged var created_date:NSDate
    
    @NSManaged var base:String
    @NSManaged var name:String
    
    @NSManaged var forecasts:[Forecast]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(data: NSDictionary ,context: NSManagedObjectContext){
        
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)
        super.init(entity: entity!, insertIntoManagedObjectContext: context)
        
        if let name = data.valueForKey("name") as? String{
            self.name = name
        }
        
        if let base = data.valueForKey("base") as? String{
            self.base = base
        }
        
        id = NSUUID().UUIDString
        created_date = NSDate()
    }
}
