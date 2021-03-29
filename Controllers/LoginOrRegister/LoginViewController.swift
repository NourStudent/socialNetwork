//
//  LoginViewController.swift
//  socialNetwork
//
//  Created by Nour Achour on 2021-02-13.
//

import UIKit
import Firebase
import JGProgressHUD

class LoginViewController: UIViewController,UITextFieldDelegate{
    
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Log In"
       view.backgroundColor = .systemBackground
        setImageBackground()
         navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        setupInputFiels()
        emailTextField.delegate = self
        passwordTextField.delegate = self
      }
    
    
    //MARK: Views
    
    
    func setImageBackground(){
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = #imageLiteral(resourceName: "ecran2")
        backgroundImage.contentMode = .scaleToFill
        backgroundImage.alpha = 0.4
        self.view.insertSubview(backgroundImage, at: 0)
    }
    
    private let imageView :UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage (named: "welcome_back")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
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
        let isFormValid = emailTextField.text?.count ?? 0 > 0  && passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        }else{
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    //MARK: Handeling the sign in
    
    let signUpButton: UIButton = {
        let bouton = UIButton(type: .system)
      
        bouton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        bouton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        bouton.setTitle("Log In", for: .normal)
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
      
        guard let password = passwordTextField.text, password.count > 0 else {
            return
        }
        spinner.show(in: view)
        
        Service.signIn(email: email, password: password) {
            //self.performSegue(withIdentifier: "userSigned", sender: nil)
            let storyboard = UIStoryboard(name:"Main" , bundle: Bundle.main)
            let destination = storyboard.instantiateViewController(withIdentifier: "profileNewUser") as! UITabBarController
            destination.modalPresentationStyle = .fullScreen
            self.navigationController?.present(destination, animated: true, completion: nil)
            
           
            
        } onError: { (error) in
            self.present(Service.createAlertController(title: "Error", message: error!.localizedDescription), animated: true, completion: nil)
        }
        spinner.dismiss()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
         passwordTextField.resignFirstResponder()
        return true
    }
    
    
    //MARK: - Navigate to Register Page
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: false)
        
    }
   
    //MARK: -CONTRAINTES
    fileprivate func  setupInputFiels(){
        
        view.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.layer.cornerRadius = 20
        imageView.layer.shadowColor = UIColor.gray.cgColor
        imageView.anchors(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 150, leftConstant: 0, bottomConstant: 0, rightConstant: 0, width: 140, height: 140)
        let stackView = UIStackView(arrangedSubviews: [emailTextField,  passwordTextField,signUpButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        view.addSubview(stackView)
        stackView.anchors( top: imageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 40, bottomConstant: 0, rightConstant: 40 ,width: 0, height: 200)  //les contraintes de la stackView
      
    }
  
}

