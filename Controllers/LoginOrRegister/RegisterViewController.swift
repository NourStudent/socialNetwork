//
//  RegisterViewController.swift
//  socialNetwork
//
//  Created by Nour Achour on 2021-02-13.
//

import UIKit
import Firebase
import FirebaseStorage
import JGProgressHUD

class RegisterViewController: UIViewController ,UIImagePickerControllerDelegate , UINavigationControllerDelegate, UITextFieldDelegate {
   
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.title = "Register"
        
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
       
        
        setupInputFiels()
        setImageBackground()
    }
    
    //MARK: -Handeling the profile photo
    
    func setImageBackground(){
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = #imageLiteral(resourceName: "ecran")
        backgroundImage.contentMode = .scaleToFill
        backgroundImage.alpha = 0.4
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    let plusPhotoBouton :UIButton =
        {
            let bouton = UIButton(type: .system)// ce type de bouton preprogramme dans le systeme permet une effet floute lorsqu'on clique sur dessus
          
            bouton.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)//(withRenderingMode(.alwaysOriginal)) pour garder toujours la couleur originale de la photo
            
            bouton.addTarget(self, action: #selector(presentPhotoActionSheet), for: .touchUpInside)
            return bouton
    }()
    
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
            plusPhotoBouton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        else if  let originalImage = info[.originalImage] as?UIImage {
            plusPhotoBouton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        plusPhotoBouton.layer.cornerRadius = plusPhotoBouton.frame.width/2
        plusPhotoBouton.layer.masksToBounds = true
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Handeling the textFields
    
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email Adress"
        tf.backgroundColor = .secondarySystemBackground
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        tf.returnKeyType = .continue
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
 
    let usernameTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "User name"
        tf.backgroundColor = .secondarySystemBackground
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        tf.returnKeyType = .continue
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    let passwordTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = .secondarySystemBackground
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        tf.returnKeyType = .done
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    @objc func handleTextInputChange(){
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        }else{
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    
    //MARK: -Handling sign Up
    
    let signUpButton: UIButton = {
        let bouton = UIButton(type: .system)
      
        bouton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        bouton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        bouton.setTitle("Register", for: .normal)
        bouton.setTitleColor(.white, for: .normal)
        bouton.layer.cornerRadius = 5
        
        bouton.addTarget(self, action: #selector(handleSighUp), for: .touchUpInside)
        bouton.isEnabled = false
        return bouton
    }()
    
  
    @objc func handleSighUp(){
      
        guard let email = emailTextField.text, email.count > 0 else {
            return
        }
        guard let username = usernameTextField.text, username.count > 0 else {
            return
        }
        guard let password = passwordTextField.text, password.count > 0 else {
            return
        }
        guard let image = plusPhotoBouton.imageView?.image else {return}
        
        spinner.show(in: view)
       
        Service.signUpUser(email: email, name: username, password: password, image: image, onSuccess: {
            let storyboard = UIStoryboard(name:"Main" , bundle: Bundle.main)
            let destination = storyboard.instantiateViewController(withIdentifier: "profileNewUser") as! UITabBarController
            destination.modalPresentationStyle = .fullScreen
            self.navigationController?.present(destination, animated: true, completion: nil)
          
        }, onError:{ (error)  in
            self.present(Service.createAlertController(title: "Error", message: error!.localizedDescription), animated: true, completion: nil)
           
        })

            
    spinner.dismiss()
        
}
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
                
    
    
   //MARK: -Contraintes
    
    fileprivate func  setupInputFiels(){
        
        view.addSubview(plusPhotoBouton) //on rajoute une sous vue(le bouton plus) a notre vue principale
     
        plusPhotoBouton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        plusPhotoBouton.anchors(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 150, leftConstant: 0, bottomConstant: 0, rightConstant: 0, width: 140, height: 140)
      
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField,signUpButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
      
        view.addSubview(stackView)
     
        stackView.anchors(top: plusPhotoBouton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 40, bottomConstant: 0, rightConstant: 40 ,width: 0, height: 200)  //les contraintes de la stackView
      
    }
}





