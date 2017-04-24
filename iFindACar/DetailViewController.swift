//
//  DetailViewController.swift
//  iFindACar
//
//  Created by Srini Motheram on 4/17/17.
//  Copyright © 2017 Srini Motheram. All rights reserved.
//

import UIKit
import SWXMLHash
import Alamofire
import SwiftyJSON

class DetailViewController: UIViewController, UINavigationControllerDelegate  {
    
    var currentVehicle  :Vehicle?
    
    @IBOutlet var modelYearLabel2    :UILabel!
    @IBOutlet var makeLabel2         :UILabel!
    @IBOutlet var modelLabel2        :UILabel!
    @IBOutlet var mpgLabel           :UILabel!
    @IBOutlet var trannyLabel           :UILabel!
    @IBOutlet var vehicleClassLabel           :UILabel!
    
    var hostName4options :String!
    var hostName4detailsByVehicleId :String!
    var vehicleId        :String?
    var powerTrain    :String!; var cityMPG1 :String!; var hwyMPG1 :String!; var vehicleClass :String!
    var vehicleIDArray = [String]()
    
    // Get vehicle id from fuel economy.gov given make, model and year
    func alamoFire2GetVID(currCar: Vehicle){
        print("in func alamoFire2GetVID")
       hostName4options = "http://www.fueleconomy.gov/ws/rest/vehicle/menu/options?" + "year=" + currCar.modelYear + "&make=" + currCar.make + "&model="+currCar.model
        print("\(hostName4options!)")
        Alamofire.request(hostName4options, method: .get, parameters: nil).response { ( response) in
            // print(response.data!) // if you want to check XML data in debug window.
            let xmlResult = SWXMLHash.parse(response.data!)
            for elem in xmlResult["menuItems"]["menuItem"].all {
                //  print(elem["text"].element!.text!)
                guard let currVehicleId = elem["value"].element!.text  // ! as? String
                    else {  continue }
                self.vehicleIDArray.append(currVehicleId)
                self.hostName4detailsByVehicleId = "http://www.fueleconomy.gov/ws/rest/vehicle/" + self.vehicleIDArray.first!
                print("hostName4detailsByVehicleID: \(self.hostName4detailsByVehicleId!)")
            }
           // sleep(1)
          //  self.alamoFire3ToGetMPG()
              DispatchQueue.main.async {
                if self.vehicleIDArray.count > 0 {
                  self.alamoFire3ToGetMPG()
                }
               }
        }
    }
    
    
    func alamoFire3ToGetMPG(){
        print("from alamoFire3ToGetMPG: \(vehicleIDArray.count)")

        self.hostName4detailsByVehicleId = "http://www.fueleconomy.gov/ws/rest/vehicle/" + self.vehicleIDArray.first!
        Alamofire.request(self.hostName4detailsByVehicleId!, method: .get, parameters: nil).response { ( response) in
            // print(response.data!) // if you want to check XML data in debug window.
            let xmlResultFinal = SWXMLHash.parse(response.data!)
            for elem in xmlResultFinal["vehicle"].all {
                //  print(elem["text"].element!.text!)
                guard let cityMPG = elem["city08"].element!.text //!  as? String
                    else { print("nothing in currPowerTRain"); continue }
                guard let highwayMPG = elem["highway08"].element!.text  //!  as? String
                    else { continue }
                guard let currPowerTrain = elem["trany"].element!.text  //!  as? String
                    else { continue }
                guard let currVehicleClass = elem["VClass"].element!.text //!  as? String
                    else { continue }

                print("cityMPG: \(cityMPG)")
                self.cityMPG1 = cityMPG
                self.hwyMPG1 = highwayMPG
                self.powerTrain = currPowerTrain
                self.vehicleClass = currVehicleClass
                
            }
            self.showCarDetails(currCar: self.currentVehicle!)
            self.mpgLabel.text =  "city mpg: " + "\(self.cityMPG1!), high way mpg: \(self.hwyMPG1!)"
            self.trannyLabel.text =  "power train: " + "\(self.powerTrain!)"
            self.vehicleClassLabel.text =  "vehicle class: " + "\(self.vehicleClass!)"
            
            }
        }
    
    func showCarDetails(currCar: Vehicle) {
        modelYearLabel2.text = currCar.modelYear
        makeLabel2.text = currCar.make
        modelLabel2.text = currCar.model
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        alamoFire2GetVID(currCar: currentVehicle!)
        showCarDetails(currCar: currentVehicle!)
       
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if vehicleIDArray.count == 0 {
            print("in view did appear - IF")
            alamoFire2GetVID(currCar: currentVehicle!)
        }
//        else {
//            print("in view did appear - ELSE")
//            sleep(1)
//            alamoFire3ToGetMPG()
//        }
        print("from viewDidAppear: \(vehicleIDArray.count)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


/*    tried to get a car picture from edmunds or google CSE - need more time
 
 func googleCSEforCarPics(){
 let googURL = "https://www.googleapis.com/customsearch/v1?key=AIzaSyD7ut7MqqZneOYRVFuEOnRrYDiQ8D1G16g&cx=006117311130417845890%3A1rupjxyiqvw&q=honda%20civic%202016&searchType=image&fileType=jpg&imgSize=medium&alt=json"
 Alamofire.request(googURL).responseJSON { (responseData) -> Void in
 if((responseData.result.value) != nil) {
 let swiftyJsonVar = JSON(responseData.result.value!)
 print("from google cse: \(swiftyJsonVar)")
 }
 }
 }
 
 func parseEdmundsJSON4imageURL(){
 print("in edmunds api")
 Alamofire.request("https://api.edmunds.com/api/media/v2/honda/civic/2013/photos?api_key=zn4xt3awf9vx9dwnfbqvxn8f").responseJSON { (responseData) -> Void in
 if((responseData.result.value) != nil) {
 let swiftyJsonVar = JSON(responseData.result.value!)
 print("from edumund: \(swiftyJsonVar)")
 }
 }
 }
 
 */
