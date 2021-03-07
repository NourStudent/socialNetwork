//
//  NewActivityViewController.swift
//  socialNetwork
//
//  Created by Nour Achour on 2021-02-25.
//

import UIKit
import MapKit

class NewActivityViewController: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource {
  
    
   
    @IBOutlet weak var activityName: UIPickerView!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelStepper: UILabel!
    @IBAction func stepper(_ sender: UIStepper) {
        labelStepper.text = String(sender.value)}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    @IBAction func startDateChanged(_ sender: UIDatePicker) {
        
        print("print \(sender.date)")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY"
        let startDate = dateFormatter.string(from: sender.date)

        print(startDate)
    }
    
    @IBAction func endDateChanged(_ sender: UIDatePicker) {
        
        print("print \(sender.date)")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY"
        let endDate = dateFormatter.string(from: sender.date)

        print(endDate)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return activities.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return activities[row]
    }
    
    
    @IBAction func postActivity(_ sender: UIButton) {
        
        let selectedActivity = activityName.selectedRow(inComponent: 0)
        let startedDate: () = endDateChanged(startDatePicker)
        let endingDate: () = endDateChanged(endDatePicker)
        let teamNumber = labelStepper.text
        //let location = mapView.userLocation
        
        guard let teamNB = teamNumber else {
            return
        }
        Service.uploadPostsToDatabase(activityName:"\(selectedActivity)", startingDate: "\(startedDate)", endingDate: "\(endingDate)", teamMembers: "\(teamNB)") {
            
         self.navigationController?.pushViewController(ActivitiesCollectionViewController(), animated: false)
        }
    }
    }
    


