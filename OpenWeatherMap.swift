//
//  OpenWeatherMap.swift
//  Map Forecast Diary
//
//  Created by Abdelaziz Elrashed on 8/18/15.
//  Copyright (c) 2015 Abdelaziz Elrashed. All rights reserved.
//

import Foundation

extension String {
    func toDouble() -> Double? {
        return NSNumberFormatter().numberFromString(self)?.doubleValue
    }
}

class OpenWeatherMap{
    
    struct Key{
        static let API_KEY = "d1bdb0aa0a27c34ffc59f7da125de3a8"
        static let BASE_URL = "http://api.openweathermap.org/data/2.5/weather"
    }
    
    static internal func GetTodayForecast(lat:String, lon:String, completion: ((data: NSDictionary) -> Void)? ){
        
        let param = [
            "lat": lat,
            "lon": lon,
            "APPID": Key.API_KEY,
            "units": "metric"
        ]

        let session = NSURLSession.sharedSession()
        let urlString = OpenWeatherMap.Key.BASE_URL + escapedParameters(param)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                
                println("Could not complete the request \(error)")
                
                if let completion = completion{
                    var resultError = NSDictionary(objects: [error], forKeys: ["error"])
                    completion(data: resultError)
                }
                
            } else {
                
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let completion = completion{
                    completion(data: parsedResult)
                }
                
            }
        }
        
        task.resume()
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    static func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
}
