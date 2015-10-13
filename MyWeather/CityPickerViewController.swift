//
//  CitySelectViewController.swift
//  MyWeather
//
//  Created by Игорь Моренко on 11.10.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

import UIKit
import CoreLocation

class CityPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate {

    var selectedCity: Int?
    var location: CLLocation?
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        if selectedCity != nil {
            pickerView.selectRow(selectedCity!, inComponent: 0, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func definedLocation(sender: AnyObject) {
        // requestLocation
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    // MARK: - Picker View Data Source

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return WeatherData.cityNames.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return WeatherData.cityNames[row]
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "SaveSelectedCity" {
            selectedCity = pickerView.selectedRowInComponent(0)
            print("prepareForSegue:SaveSelectedCity")
        }
    }

    // MARK: - Location Manager Delegate

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationFirst = locations.first {
            location = locationFirst
//            locationLabel.text = "\(location)"
            locationLabel.text = String(format: "lon:%f, lat:%f", arguments: [location!.coordinate.longitude, location!.coordinate.latitude])
            
            let weatherData = WeatherData()
            //print(weatherData.getCityByLocation(37.62, lat: 55.75))
            if let cityName = weatherData.getCityByLocation(location!) {
                cityLabel.text = cityName
                if let cityIndex = WeatherData.cities.indexOf(cityName) {
                    selectedCity = cityIndex
                    pickerView.selectRow(selectedCity!, inComponent: 0, animated: true)
                }
                
            }

        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error finding location: \(error.localizedDescription)")
        // show error alert
        let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        errorAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            errorAlert.dismissViewControllerAnimated(true, completion: nil)
        }))
        presentViewController(errorAlert, animated: true, completion: nil)
    }
}
