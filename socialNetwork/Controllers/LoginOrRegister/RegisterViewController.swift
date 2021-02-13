//
//  RegisterViewController.swift
//  socialNetwork
//
//  Created by User on 2021-02-13.
//

import UIKit
import Firebase
import FirebaseStorage

class RegisterViewController: UIViewController ,UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    let plusPhotoBouton :UIButton =
        {
            let bouton = UIButton(type: .system)// ce type de bouton preprogramme dans le systeme permet une effet floute lorsqu'on clique sur dessus
          
            bouton.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)//(withRenderingMode(.alwaysOriginal)) pour garder toujours la couleur originale de la photo
            
            bouton.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
            return bouton
    }()
    
    @objc func handlePlusPhoto(){
       let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
       present(imagePickerController, animated: true, completion: nil)
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
    
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email Adress"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
 
    let usernameTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "User name"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    let passwordTextField:UITextField = {
        let tf = UITextField()
        
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 14)
        
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
    
    
    let signUpButton: UIButton = {
        let bouton = UIButton(type: .system)
      
        bouton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        bouton.titleLabel?.font = .boldSystemFont(ofSize: 14)
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

        Auth.auth().createUser(withEmail: email, password: password) { (user, error:Error?) in
            if let err = error{
                print("Echec pour la creation d'un nouveau utilisateur:" , err)
            }
            
            print("l'utilisteur a ete cree correctement" , user?.user.uid ?? "")
            let filename = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference().child("profile_Images").child(filename)
            
            guard let image = self.plusPhotoBouton.imageView?.image else {return}
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else {return}
            storageRef.putData(uploadData, metadata: nil) { (metadata, err) in
                if let err = err {
                    print("uploading profile image failed" , err)
                    return
                }
                
                storageRef.downloadURL { (downloadURL, err) in
                    guard let profileImageUrl = downloadURL?.absoluteString else {return}
                    print("uploading profile image succeed", profileImageUrl)
                    
                    guard let uid = user?.user.uid else {return}
                    let dictionaryValues = ["username" : username , "profileImageUrl":profileImageUrl]
                    let values = [uid : dictionaryValues]
                    Database.database().reference().child("users").updateChildValues(values) { (err, ref) in
                        if let err = err {
                            print ("backup user informations failed " , err)
                            return
                        }
                            print("backup user informations succeed ")
                        }
                }
            }
         
        
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupInputFiels()
    }
    
    fileprivate func  setupInputFiels(){
        
        view.addSubview(plusPhotoBouton) //on rajoute une sous vue(le bouton plus) a notre vue principale
     
        plusPhotoBouton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        plusPhotoBouton.anchors(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, width: 140, height: 140)
      
        let stackView = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField,signUpButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
      
        view.addSubview(stackView)
     
        stackView.anchors(top: plusPhotoBouton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 40, bottomConstant: 0, rightConstant: 40 ,width: 0, height: 200)  //les contraintes de la stackView
      
    }
}




