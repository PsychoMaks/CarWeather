//
//  Weather.swift
//  SkywellCarWeather
//
//  Created by Maks Sergeychuk on 8/11/16.
//  Copyright © 2016 company.com. All rights reserved.
//

import Foundation
import CoreData
import AlamofireImage
import UIKit


class Weather: NSManagedObject {

    class func getWeather(withWeatherInfo weatherInfo: NSDictionary?, inManagedObjectContext context: NSManagedObjectContext) -> Weather? {
        let request = NSFetchRequest(entityName: "Weather")
    
        if let weather = (try? context.executeFetchRequest(request))?.first as? Weather {
            serializeJSON(weatherInfo, forWeather: weather)
            return weather
        } else if let weather = NSEntityDescription.insertNewObjectForEntityForName("Weather", inManagedObjectContext: context) as? Weather {
            serializeJSON(weatherInfo, forWeather: weather)
            return weather
        }
        return nil
    }
    
    private class func serializeJSON(json: NSDictionary?, forWeather weatherItem: Weather) -> Weather? {
        if let json = json {
            if let name = json["name"] as? String {
                weatherItem.city = name
            }
            if let wthr = json["weather"] as? NSArray {
                if let weather = wthr.firstObject as? NSDictionary {
                    if let desc = weather["description"] as? String {
                        weatherItem.sky = desc
                    }
                    if let icon = weather["icon"] as? String {
                        weatherItem.image = NSData(contentsOfURL: NSURL(string: "http://openweathermap.org/img/w/\(icon).png")!)
                    }
                }
            }
            if let main = json["main"] as? NSDictionary {
                if let temp = main["temp"] as? Double {
                    weatherItem.degrees = NSNumber(double: temp - 273.15)
                }
            }
        }
        
        return weatherItem
    }


}
