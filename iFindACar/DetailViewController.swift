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

class DetailViewController: UIViewController, UINavigationControllerDelegate  {
    
    var currentVehicle  :Vehicle?
    
    @IBOutlet var modelYearLabel2    :UILabel!
    @IBOutlet var makeLabel2         :UILabel!
    @IBOutlet var modelLabel2        :UILabel!
    @IBOutlet var mpgLabel           :UILabel!
    
    var hostName4options :String!
    var hostName4detailsByVehicleId :String!
    var vehicleId        :String?
    var powerTrain    :String!; var cityMPG1 :String!; var hwyMPG1 :String!;
    var vehicleIDArray = [String]()
    
    func alamoFire2GetVID(currCar: Vehicle){
        print("in func alamoFire2GetVID")
       hostName4options = "http://www.fueleconomy.gov/ws/rest/vehicle/menu/options?" + "year=" + currCar.modelYear + "&make=" + currCar.make + "&model="+currCar.model
        print("\(hostName4options!)")
        Alamofire.request(hostName4options, method: .get, parameters: nil).response { ( response) in
            // print(response.data!) // if you want to check XML data in debug window.
            let xmlResult = SWXMLHash.parse(response.data!)
            for elem in xmlResult["menuItems"]["menuItem"].all {
                //  print(elem["text"].element!.text!)
                guard let currVehicleId = elem["value"].element!.text!  as? String
                    else {  continue }
                self.vehicleIDArray.append(currVehicleId)
                self.hostName4detailsByVehicleId = "http://www.fueleconomy.gov/ws/rest/vehicle/" + self.vehicleIDArray.first!
                print("hostName4detailsByVehicleID: \(self.hostName4detailsByVehicleId!)")
            }
            sleep(1)
            self.alamoFire3ToGetMPG()
            //  DispatchQueue.main.async {
            //      self.vehicleTableView.reloadData()
            //   }
        }
    }
    
    
    func alamoFire3ToGetMPG(){
        print("in func alamoFire3ToGetMPG")
        self.hostName4detailsByVehicleId = "http://www.fueleconomy.gov/ws/rest/vehicle/" + self.vehicleIDArray.first!
        Alamofire.request(self.hostName4detailsByVehicleId!, method: .get, parameters: nil).response { ( response) in
            // print(response.data!) // if you want to check XML data in debug window.
            let xmlResultFinal = SWXMLHash.parse(response.data!)
            for elem in xmlResultFinal["vehicle"].all {
                //  print(elem["text"].element!.text!)
                guard let cityMPG = elem["city08"].element!.text!  as? String
                    else { print("nothing in currPowerTRain"); continue }
                guard let highwayMPG = elem["highway08"].element!.text!  as? String
                    else { continue }
               // guard let currPowerTrain = elem["tranny"].element!.text!  as? String
                 //   else { continue }

                print("cityMPG: \(cityMPG)")
                self.cityMPG1 = cityMPG
                self.hwyMPG1 = highwayMPG
                
            }
            self.showCarDetails(currCar: self.currentVehicle!)
            self.mpgLabel.text =  "city mpg: " + "\(self.cityMPG1!), high way mpg: \(self.hwyMPG1!)"
            
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
        if vehicleIDArray.count <= 0 {
            alamoFire2GetVID(currCar: currentVehicle!)
            sleep(1)
            alamoFire3ToGetMPG()

           // sleep(1)
        }  else {
            sleep(1)
            alamoFire3ToGetMPG()
        }
        print("from viewDidAppear: \(vehicleIDArray.count)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
}
