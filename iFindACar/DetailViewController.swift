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
    @IBOutlet var vehicleClassLabel      :UILabel!
    @IBOutlet var safetyRatingLabel      :UILabel!
    @IBOutlet var carImageView           :UIImageView!
    
    var hostName4options :String!
    var hostName4detailsByVehicleId :String!
    var vehicleId        :String?
    var powerTrain   :String!; var cityMPG1 :String!; var hwyMPG1 :String!; var vehicleClass :String!; var safetyRating :String!
    var imageurl    :String!
    var vehicleIDArray = [String]()
    var vehicleIDArrayNHTSA = [String]()
    
    var hostName4NHTSAVid :String!
    var hostName4NHTSAByVehicleId :String!
    
    //MARK: - fuel economy.gov methods - given make, model and year
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
    //MARK:- NHTSA methods
    
    func getNHTSAdataVID(currCar: Vehicle){
        print("in func getNHTSAdataVID")
        hostName4NHTSAVid = "https://one.nhtsa.gov/webapi/api/SafetyRatings/modelyear/" + currCar.modelYear + "/make/" + currCar.make + "/model/" + currCar.model + "?format=xml"
        print("\(hostName4NHTSAVid!)")
        Alamofire.request(hostName4NHTSAVid, method: .get, parameters: nil).response { ( response) in
           //  print(response.data!) // if you want to check XML data in debug window.
            let xmlResult = SWXMLHash.parse(response.data!)
            for elem in xmlResult["Response"]["Results"]["CrashTestedVehicle"].all {
                  print(elem["VehicleId"].element!.text!)
                guard let currVehicleId = elem["VehicleId"].element!.text  // ! as? String
                    else {  continue }
                self.vehicleIDArrayNHTSA.append(currVehicleId)
                print("nthsa array count: \(self.vehicleIDArrayNHTSA.count)")
                self.hostName4NHTSAByVehicleId = "https://one.nhtsa.gov/webapi/api/SafetyRatings/VehicleId/" + self.vehicleIDArrayNHTSA.first! + "?format=xml"
                print("hostName4NHTSAByVehicleId: \(self.hostName4NHTSAByVehicleId!)")
            }
            DispatchQueue.main.async {
                if self.vehicleIDArrayNHTSA.count > 0 {
                   self.getSafetyRatingAndImageFromNHTSA()
                }
            }
        }
    }

    func getSafetyRatingAndImageFromNHTSA(){
        print("from getSafetyRatingAndImageFromNHTSA: \(vehicleIDArrayNHTSA.count)")
        
       self.hostName4NHTSAByVehicleId = "https://one.nhtsa.gov/webapi/api/SafetyRatings/VehicleId/" + self.vehicleIDArrayNHTSA.first! + "?format=xml"
        Alamofire.request(self.hostName4NHTSAByVehicleId!, method: .get, parameters: nil).response { ( response) in
            // print(response.data!) // if you want to check XML data in debug window.
            let xmlResultFinal = SWXMLHash.parse(response.data!)
            for elem in xmlResultFinal["Response"]["Results"]["SafetyRatingAssessment"].all {
                //  print(elem["text"].element!.text!)
                guard let overallRating1 = elem["OverallRating"].element!.text
                    else { continue }
                guard let imageurl1 = elem["VehiclePicture"].element!.text
                    else { continue }
                
                
                print("overall rating: \(overallRating1), \(imageurl1)")
                self.safetyRating = overallRating1
                self.imageurl = imageurl1
                
                
            }
            self.showCarDetails(currCar: self.currentVehicle!)
            self.safetyRatingLabel.text =  "safety rating stars: " + "\(self.safetyRating!)"
            
          //  self.carImageView.setImageFromURl(stringImageUrl: "http://www.safercar.gov/staticfiles/DOT/safercar/ncapmedia/images/2017/v09969P084.jpg")
            
//            let url = NSURL(string:self.imageurl)
//            let data = NSData(contentsOf:url! as URL)
//            
//            // It is the best way to manage nil issue.
//            if (data?.length)! > 0 {
//                self.carImageView.image = UIImage(data:data! as Data)
//            } else {
//                // In this when data is nil or empty then we can assign a placeholder image
//                self.carImageView.image = UIImage(named: "http://www.safercar.gov/staticfiles/DOT/safercar/ncapmedia/images/2017/v09969P084.jpg")
//            }
            
            
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
        DispatchQueue.main.async {
            self.getNHTSAdataVID(currCar: self.currentVehicle!)
        }
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

extension UIImageView{
    
    func setImageFromURl(stringImageUrl url: String){
        
        if let url = NSURL(string: url) {
            if let data = NSData(contentsOf: url as URL) {
                self.image = UIImage(data: data as Data)
            }
        }
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
