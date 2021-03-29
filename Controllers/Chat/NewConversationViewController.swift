//
//  NewConversationViewController.swift
//  socialNetwork
//
//  Created by Nour Achour on 2021-02-13.
//

import UIKit
import JGProgressHUD
import Firebase

class NewConversationViewController: UIViewController, UISearchBarDelegate{
    
    public var completion: ((User)-> (Void))?
    private let spinner = JGProgressHUD(style: .dark)
    var allUsers = [User]()
    var results:[User]!
    
    private let searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users..."
        return searchBar
        
    }()
  
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchAllUsers()
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       
        view.addSubview(tableView)
       
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        results = allUsers
       
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
      }
    
    
    @objc private func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }
 

    //MARK: Search Bar Config
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       results = []
        
        if searchText == "" {
            results = allUsers
        }else{
            
            for user in allUsers {
                if user.name.lowercased().contains(searchText.lowercased()){
                    results.append(user)
                }
                
            }
        }
        
       
        tableView.reloadData()
    }
     
    
    //MARK: Fetching Users
    
    func fetchAllUsers(){
        spinner.show(in: view)
        let ref = Database.database().reference()
        ref.child("users").observe(.childAdded, with: { snapshot in
            
            if let dictionary = snapshot.value as? [String:Any]{
                let name = dictionary["name"] as! String
                let email = dictionary["email"] as! String
                
                let user = User(name: name, email: email)
                self.allUsers.append(user)
            }
            DispatchQueue.main.async {
                self.results = self.allUsers
                self.tableView.reloadData()
                self.spinner.dismiss()
            }
            
        })
    }
 
}

extension NewConversationViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
   
            return results.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
       
        cell.textLabel?.text = results[indexPath.row].name
        cell.detailTextLabel?.text = results[indexPath.row].email
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUserData = results[indexPath.row]
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData)
        })
    }
}



