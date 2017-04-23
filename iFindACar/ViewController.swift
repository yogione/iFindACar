//
//  ViewController.swift
//  iFindACar
//
//  Created by Srini Motheram on 4/15/17.
//  Copyright © 2017 Srini Motheram. All rights reserved.
//

import UIKit
//import Parse
import SWXMLHash
import Alamofire


class ViewController: UIViewController {
    
    var hostName4model :String!
    
    var vehicleArray = [Vehicle]()
    var makeArray = ["Chevrolet", "Nissan","Ford", "Toyota", "Honda", "Chrysler"]
    var yearArray = ["2017", "2016", "2015"]
    
    @IBOutlet var vehicleTableView      :UITableView!
    
    func alamoFire(){
        for year in yearArray {
            for make in makeArray {
                hostName4model = "http://www.fueleconomy.gov/ws/rest/vehicle/menu/model?" + "year=" + year + "&make=" + make
                Alamofire.request(hostName4model, method: .get, parameters: nil).response { ( response) in
                   // print(response.data!) // if you want to check XML data in debug window.
                    let xmlResult = SWXMLHash.parse(response.data!)
                    for elem in xmlResult["menuItems"]["menuItem"].all {
                      //  print(elem["text"].element!.text!)
                        guard let currModel = elem["text"].element!.text! as? String
                        else { continue }
                        
                       // print("year: \(year), make: \(make), model: \(currModel)")
                        let newVehicle = Vehicle(modelYear: year, make: make, model: currModel)
                        self.vehicleArray.append(newVehicle)
                    }
                  //  self.vehicleArray.sorted(by: { $0.make > $1.make })
                    DispatchQueue.main.async {
                        self.vehicleTableView.reloadData()
                    }
                } // makeArray loop
            } // yearArray loop
//           sleep(1)
//           self.vehicleTableView.reloadData()
        }
    }
    
    //Mark: - interactive methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToShowDetailFromCell" {
            let indexPath = vehicleTableView.indexPathForSelectedRow!
            let currentVehicle = vehicleArray[indexPath.row]
            let destVC = segue.destination as! DetailViewController
            destVC.currentVehicle = currentVehicle
            vehicleTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func seedTestData(){
        let newVehicle1 = Vehicle(modelYear: "2016", make: "Honda", model: "Civic 4Dr")
        let newVehicle2 = Vehicle(modelYear: "2017", make: "Toyota", model: "Corolla")
        self.vehicleArray.append(newVehicle1)
        self.vehicleArray.append(newVehicle2)
    }
 
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
       // seedTestData()
        self.alamoFire()
       // self.vehicleTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.vehicleTableView.reloadData()
        print("vehicleArrayCount: \(vehicleArray.count)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       // print("in table view numRows method: \(vehicleArray.count)")
        return vehicleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! VehicleTableViewCell
        let currentVehicle = vehicleArray[indexPath.row]
        cell.modelYearLabel.text = currentVehicle.modelYear
        cell.makeLabel.text = currentVehicle.make
        cell.modelLabel.text = currentVehicle.model
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
}

