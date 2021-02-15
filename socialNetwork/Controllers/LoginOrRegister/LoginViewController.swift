//
//  LoginViewController.swift
//  socialNetwork
//
//  Created by User on 2021-02-13.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Log In"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        setupInputFiels()
      }
    
    
    //MARK: Views
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
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
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
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
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
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self]authResult, error in
            
            guard let strongSelf = self else{
                return
            }
            guard let result = authResult , error == nil else{
                print("Failed to log in user with email: \(email)")
                self?.presentAlert(with: "Invalid informations! try again")
                return
            }
            
            let user = result.user
            print("logged in user: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
}
    
    
    //MARK: - Navigate to Register Page
    
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: false)
        
    }
   
    //MARK: -CONTRAINTES
    fileprivate func  setupInputFiels(){
        
        view.addSubview(imageView) //on rajoute une sous vue(le bouton plus) a notre vue principale
     
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
    private func presentAlert(with error: String) {
        let alert = UIAlertController(title: "Erreur", message: error, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

