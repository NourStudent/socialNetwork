//
//  ProfileViewController.swift
//  socialNetwork
//
//  Created by Nour Achour on 2021-02-13.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    let data = [ "Create New Activity", "Log Out"]
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 30)
       
        // fetching the current user name from firebase
        let defaults = UserDefaults.standard
        
        Service.getUserName {
            self.label.text = "Welcome \(defaults.string(forKey: "userNameKey")!)"
        } onError: { (error) in
            self.present(Service.createAlertController(title: "Error", message: error!.localizedDescription), animated: true, completion: nil)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableHeaderView = createTableHeader()
    }
    
    
    
    
    func createTableHeader() -> UIView? {
        let headerView = UIImageView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: 300,
                                        height: 300))
        
        headerView.image = #imageLiteral(resourceName: "coverPhotoProfile")
        
        let imageView = UIImageView()
        headerView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.centerXAnchor.constraint(lessThanOrEqualTo: headerView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(lessThanOrEqualTo: headerView.centerYAnchor).isActive = true
        imageView.contentMode = .scaleAspectFit
        
       
        //MARK: Retrieving user's profile image
        DispatchQueue.main.async {
            Service.getUserProfilePhoto(imageView: imageView)
         }
        
    return headerView
}

}
        
