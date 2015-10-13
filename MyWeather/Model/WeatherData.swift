//
//  WeatherData.swift
//  MyWeather
//
//  Created by Игорь Моренко on 10.10.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

import UIKit
import CoreLocation

protocol WeatherDataDelegate {
    
    func updateWeatherInfo() -> Void
    
}

class WeatherData: NSObject {

    var nowTemp = "-1 °C"
    var nowTempMin = "-2 °C"
    var nowTempMax = "2 °C"
    var nowWeather = "---"
    var nowWindSpeed = "30 m/s"
    var nowPressure = "780 mmHg"
    var nowHumidity = "50 %"
    
    var todayTemps = ["morn": "-1", "day": "3", "eve": "0", "night": "-5"]
    
    var nextTemp = ["+1", "+2", "+3", "+4", "+5", "+6", "+7"]
    var nextWeather = ["-1-", "-2-", "-3-", "-4-", "-5-", "-6-", "-7-"]

    static let cities = ["Moscow", "Tula", "Novosibirsk", "SaintPetersburg", "Yekaterinburg"]
    static let cityNames = ["Москва", "Тула", "Новосибирск", "Санкт-Петербург", "Екатеринбург"]
    
    let urlPath = NSURL(string: "http://api.openweathermap.org/data/2.5/")
    
    // Asynchonous Request
    func getData(city: Int, delegate: WeatherDataDelegate) {
        
        let session = NSURLSession.sharedSession()

        let weatherUrl = NSURL(string: "weather?q=\(WeatherData.cities[city])&mode=json&units=metric&APPID=d1c9745179e1566578438f0f6fd39399", relativeToURL: urlPath)
        let task1 = session.dataTaskWithURL(weatherUrl!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            print(response)
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            if data != nil {
                let jsonData = JSON(data: data!)
                
                if let nowTemp = jsonData["main"]["temp"].double {
//                    self.nowTemp = "\(Int( round(nowTemp) ))"
                    self.nowTemp = String(format:"%.2f °C", nowTemp)
                }
                if let nowTempMin = jsonData["main"]["temp_min"].double {
                    self.nowTempMin = String(format:"%.2f °C", nowTempMin)
                }
                
                if let nowTempMax = jsonData["main"]["temp_max"].double {
                    self.nowTempMax = String(format:"%.2f °C", nowTempMax)
                }

                if let nowWindSpeed = jsonData["wind"]["speed"].int {
                    let convert = nowWindSpeed //round( Double(nowWindSpeed) * 3.6 )
                    self.nowWindSpeed = String(format: "%d m/s", Int(convert))
                }
                
                if let nowPressure = jsonData["main"]["pressure"].int {
                    let convert = round(Double(nowPressure) * 0.75006375541921) // 1 hPa = 0.75006375541921 mmHg
                    self.nowPressure = String(format: "%d mmHg", Int(convert))
                }
                
                if let nowHumidity = jsonData["main"]["humidity"].int {
                    self.nowHumidity = String(format:"%d %%", nowHumidity)
                }

                self.nowWeather = jsonData["weather"][0]["main"].string ?? "?"
            
                print("update data")
                delegate.updateWeatherInfo()
            }
        })
        task1.resume()
        
        let forecastDailyUrl = NSURL(string: "forecast/daily?q=\(WeatherData.cities[city])&mode=json&units=metric&cnt=7&APPID=d1c9745179e1566578438f0f6fd39399", relativeToURL: urlPath)
        let task2 = session.dataTaskWithURL(forecastDailyUrl!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            print(response)
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            if data != nil {
                let jsonData = JSON(data: data!)
            
                func convertToRoundInt(d: Double?) -> Int {
                    return Int( round(d ?? 777.0) )
                }
                
//                let night = convertToRoundInt(jsonData["list"][0]["temp"]["night"].double)
//                let morn = convertToRoundInt(jsonData["list"][0]["temp"]["morn"].double)
//                let day = convertToRoundInt(jsonData["list"][0]["temp"]["day"].double)
//                let eve = convertToRoundInt(jsonData["list"][0]["temp"]["eve"].double)
                let night = jsonData["list"][0]["temp"]["night"].double
                let morn = jsonData["list"][0]["temp"]["morn"].double
                let day = jsonData["list"][0]["temp"]["day"].double
                let eve = jsonData["list"][0]["temp"]["eve"].double
            
                self.todayTemps["night"] = String(format:"%.2f °C", night!)
                self.todayTemps["morn"] = String(format:"%.2f °C", morn!)
                self.todayTemps["day"] = String(format:"%.2f °C", day!)
                self.todayTemps["eve"] = String(format:"%.2f °C", eve!)
            
                let count = jsonData["cnt"].int ?? 0
                for i in 0..<count {
                
                    var nextTemp = [Double]()
                
                    if let night = jsonData["list"][i]["temp"]["night"].double {
                        nextTemp.append(night)
                    }
                
                    if let morn = jsonData["list"][i]["temp"]["morn"].double {
                        nextTemp.append(morn)
                    }
                
                    if let day = jsonData["list"][i]["temp"]["day"].double {
                        nextTemp.append(day)
                    }
                
                    if let eve = jsonData["list"][i]["temp"]["eve"].double {
                        nextTemp.append(eve)
                    }
                
                    if nextTemp.count != 0 {
//                        let summ = round( nextTemp.reduce(0, combine: +) / Double(nextTemp.count) )
//                        self.nextTemp[i] = String(format: "%d °C", Int(summ))
                        let summ = nextTemp.reduce(0, combine: +) / Double(nextTemp.count)
                        self.nextTemp[i] = String(format: "%.2f °C", summ)
                    }
                
                    self.nextWeather[i] = jsonData["list"][i]["weather"][0]["main"].string ?? "?"
                }
                print("update data")
                delegate.updateWeatherInfo()
            }
        })
        task2.resume()
    }
    
    // Synchonous Request
    func getCityByLocation(location: CLLocation) -> String? {
        var cityName: String? = nil
        
        let session = NSURLSession.sharedSession()
        let location = String(format: "lon=%f&lat=%f", arguments: [location.coordinate.longitude, location.coordinate.latitude])
        let weatherUrl = NSURL(string: "weather?\(location)&mode=json&units=metric&APPID=d1c9745179e1566578438f0f6fd39399", relativeToURL: urlPath)
        
        let sem = dispatch_semaphore_create(0)
        
        let task1 = session.dataTaskWithURL(weatherUrl!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            print(response)
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            if data != nil {
                let jsonData = JSON(data: data!)
                
                cityName = jsonData["name"].string
                
            }
            dispatch_semaphore_signal(sem)
        })
        task1.resume()
        
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
        
        return cityName
    }
}
