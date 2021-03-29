//
//  NewActivityViewController.swift
//  socialNetwork
//
//  Created by Nour Achour on 2021-02-25.
//

import UIKit
import MapKit
import CoreLocation
import JGProgressHUD


class NewActivityViewController: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource {
  
    private let spinner = JGProgressHUD(style: .dark)
    @IBOutlet weak var shareActivityButton: UIButton!
    @IBOutlet weak var activityName: UIPickerView!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelStepper: UILabel!
    @IBAction func stepper(_ sender: UIStepper) {
        labelStepper.text = String(sender.value)}
    
    @IBOutlet weak var endDateTextField: UITextField!
    
    @IBOutlet weak var startDateTextField: UITextField!
    
 
    @IBOutlet weak var adressLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let regionInMeters:Double = 10000
    var previousLocation : CLLocation?
    
    
    
    
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        mapView.delegate = self
        checkLocationServices()
        shareActivityButton.layer.cornerRadius = 5
    }
    
    @IBAction func startDateChanged(_ sender: UIDatePicker) {
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY hh:mm:ss"
        let startDate = dateFormatter.string(from: sender.date)
         
        self.startDateTextField.text = startDate
        print("startDate: \(startDate)")
      
    }
   
    
    @IBAction func endDateChanged(_ sender: UIDatePicker) {
      
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY hh:mm:ss"
        let endDate = dateFormatter.string(from: sender.date)
        
        self.endDateTextField.text = endDate
        print("endDate: \(endDate)")
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
    
    //MARK: Handling Location
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            //setup our location manager
            setupLocationManager()
            checkLocationAuthorization()
        }else{
            //Show alert letting the user know they have to turn this on
        }
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
           startTrackingUserLocation()
        case .denied:
        //show alert
            break
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            //show alert
            break
        case .authorizedAlways:
            break
        default:
            break
        }
    }
    
    func startTrackingUserLocation(){
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    func getCenterLocation(for mapView: MKMapView)-> CLLocation{
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    //MARK: Adding new activity to firebase
    @IBAction func postActivity(_ sender: UIButton) {
       
        let selectedActivity = activityName.selectedRow(inComponent: 0)
        let activity = activities[selectedActivity]
      

        guard let teamNumber = labelStepper.text,teamNumber.count > 0, let postId = createPostId(), let startDate = startDateTextField.text,startDate.count > 0, let endDate = endDateTextField.text, endDate.count > 0 , let location = adressLabel.text, location.count > 0 else {
            
            self.present(Service.createAlertController(title: "Alert", message: "Please complete all fields!"), animated: true, completion: nil)
            return}
        
        spinner.show(in: view)

        
        Service.createNewPost(postId: postId, activityName: activity, startingDate: startDate, endingDate: endDate , teamMembers: teamNumber ,location:location) { (success) in
            if success {
                let storyboard = UIStoryboard(name:"Main" , bundle: Bundle.main)
                let destination = storyboard.instantiateViewController(withIdentifier: "AllPosts") as! ActivitiesViewController
               destination.modalPresentationStyle = .fullScreen
              self.navigationController?.present(destination, animated: true)
        } else {
            
                self.present(Service.createAlertController(title: "Error", message: "failed to create this activity"), animated: true, completion: nil)
            }
        }
        
        spinner.dismiss()
   
    }
    
    
    private func createPostId() -> String? {
      
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let selectedActivity = activityName.selectedRow(inComponent: 0)
        let activity = activities[selectedActivity]
       
       let safeCurrentEmail = Service.safeEmail(email: currentUserEmail ).lowercased()
      
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(activity)_\(safeCurrentEmail)_\(dateString)"
        
        print("created post id: \(newIdentifier)")
        
        return newIdentifier
    }
    
}



//MARK: Handling Location
extension NewActivityViewController: CLLocationManagerDelegate{

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
    
extension NewActivityViewController: MKMapViewDelegate {
      
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else{return}
        
        guard center.distance(from: previousLocation) > 50 else {return}
        self.previousLocation = center
        
        geoCoder.reverseGeocodeLocation(center) {[weak self] (placemarks, error) in
            guard let strongSelf = self else {return}
            
            if let _ = error {
                return
            }
            
            guard let placemark = placemarks?.first else {
                return
            }
            
            guard let streetNumber = placemark.subThoroughfare else {return}
            guard let streetName = placemark.thoroughfare else{return}
            
            DispatchQueue.main.async {
               strongSelf.adressLabel.text = "\(streetNumber) \(streetName)"
                
            }
        }
    }
}

    
    


