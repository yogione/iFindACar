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
    
    var hostName4options :String!
    var vehicleId        :String!
    var powerTrain    = "no data"
    
    // let hostName4options = "http://www.fueleconomy.gov/ws/rest/vehicle/menu/options?year=2012&make=Honda&model=Fit"
    
    
    func alamoFire2(currCar: Vehicle){
    
     hostName4options = "http://www.fueleconomy.gov/ws/rest/vehicle/menu/options?" + "year=" + currCar.modelYear + "&make=" + currCar.make + "&model="+currCar.model
print("\(hostName4options!)")
        Alamofire.request(hostName4options, method: .get, parameters: nil).response { ( response) in
                    // print(response.data!) // if you want to check XML data in debug window.
                    let xmlResult = SWXMLHash.parse(response.data!)
                    for elem in xmlResult["menuItems"]["menuItem"].all {
                        //  print(elem["text"].element!.text!)
                        guard let currPowerTrain = elem["text"].element!.text!  as? String
                            else { print("nothing in currPowerTRain"); continue }
                        self.powerTrain = currPowerTrain
                        print("\(currPowerTrain)")
                        
                       // if currPowerTrain = "Auto"
                        // print("year: \(year), make: \(make), model: \(currModel)")
                    }
                  //  DispatchQueue.main.async {
                  //      self.vehicleTableView.reloadData()
                 //   }
        }
    }

    
    func showCarDetails(currCar: Vehicle) {
        modelYearLabel2.text = currCar.modelYear
        makeLabel2.text = currCar.make
        modelLabel2.text = currCar.model + " " + powerTrain
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        alamoFire2(currCar: currentVehicle!)
        showCarDetails(currCar: currentVehicle!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
}
