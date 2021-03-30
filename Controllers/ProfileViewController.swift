//
//  ProfileViewController.swift
//  socialNetwork
//
//  Created by Nour Achour on 2021-02-13.
//

import UIKit
import JGProgressHUD
import Firebase



final class ProfileViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    private let spinner = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
  
    var data = [ "Create New Activity","Favorite activities", "Log Out"]
    
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "user_photo")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableView.tableHeaderView = createTableHeader()
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 30)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        ///add a gestureRecognizer to imageView to allow user to change his profile photo
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.presentPhotoActionSheet))
        self.imageView.isUserInteractionEnabled = true
        gesture.delegate = self
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        self.imageView.addGestureRecognizer(gesture)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        validateAuth()
        
    }
    
    
    private func validateAuth(){
        
        if Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .custom
            present(nav, animated: false)
            
        }
    }
    
    func createTableHeader() -> UIView? {
        let headerView = UIImageView(frame: CGRect(x: 0,
                                                   y: 0,
                                                   width: self.view.width,
                                                   height: 300))
        
        headerView.image = #imageLiteral(resourceName: "cover3")
        
        imageView.frame =  CGRect(x: (headerView.width - 150)/2,
                                  y: 75,
                                  width: 150,
                                  height: 150)
        
        
        imageView.layer.cornerRadius = imageView.width / 2
        headerView.addSubview(imageView)
        
        //MARK: Retrieving user's profile image and name
        
        DispatchQueue.main.async {
            ///Retrieving user's profile image
            Service.getUserProfilePhoto(imageView: self.imageView)
            Service.getUserName {
                /// fetching the current user name from firebase
                let defaults = UserDefaults.standard
                self.label.text = "Welcome \(defaults.string(forKey: "name")!)"
                
                
            } onError: { (error) in
                self.present(Service.createAlertController(title: "Error", message: error!.localizedDescription), animated: true, completion: nil)
            }
            
        }
        
        return headerView
    }
    
    
    @objc func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(
                                title: "Take Photo",
                                style: .default,
                                handler: {[weak self]_ in
                                    
                                    self?.presentCamera()
                                }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self]_ in
            
            self?.handlePlusPhoto()
        }))
        
        present(actionSheet, animated: true)
    }
    
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage{
            imageView.image = editedImage
        }  else if  let originalImage = info[.originalImage] as? UIImage {
            imageView.image = originalImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func handlePlusPhoto(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    
    
    
}



extension ProfileViewController  {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath)
        
        cell.textLabel?.text = data[indexPath.row] as? String
        cell.textLabel?.textAlignment = .center
        cell.selectionStyle = .gray
        
        
        switch cell.textLabel?.text {
        
        case "Create New Activity":
            cell.tintColor = .secondarySystemBackground
        case"My activities":
            cell.textLabel?.textColor = .secondarySystemBackground
        case "Log Out":
            cell.textLabel?.textColor = .red
        default:
            break
        }
        
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        
        switch cell?.textLabel?.text {
        case "Create New Activity":
            
            let storyboard = UIStoryboard(name:"Main" , bundle: Bundle.main)
            let destination = storyboard.instantiateViewController(withIdentifier: "activityID") as! NewActivityViewController
            navigationController?.pushViewController(destination, animated: false)
            
        case "Favorite activities":
            
            let storyboard = UIStoryboard(name:"Main" , bundle: Bundle.main)
            let destination = storyboard.instantiateViewController(withIdentifier: "userActivitiesID") as! userFavoriteActivitiesViewController
            navigationController?.pushViewController(destination, animated: false)
            
        case "Log Out":
            
            
            do {
                try Auth.auth().signOut()
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .custom
                present(nav, animated: false)
                
            }
            catch{
                present(Service.createAlertController(title: "Error", message: error.localizedDescription), animated: true, completion: nil)
                
            }
        default:
            break
        }
        
        
    }
    
    
}

