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
    var results = [User]()
    
    private let searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users..."
        return searchBar
        
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .red
        label.font = .systemFont(ofSize: 21 , weight: .medium)
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(tableView)
        view.addSubview(noResultsLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        fetchAllUsers()
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4, y: (view.height-200)/2, width: view.width/2, height: 200)
        
    }
    
    
    @objc private func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }
 
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        spinner.show(in: view)
        guard let text = searchBar.text , !text.replacingOccurrences(of: " ", with: "").isEmpty else{return}
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        self.filterUsers(with: text)
        tableView.reloadData()
        print("results array count :\(results.count)")
        
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
                self.tableView.reloadData()
                self.spinner.dismiss()
            }
            
        })
    }
    
    
    func updateUI(){
        if results.isEmpty {
            spinner.dismiss()
            tableView.isHidden = true
            noResultsLabel.isHidden = false
            
        }else{
            tableView.isHidden = false
            noResultsLabel.isHidden = true
            tableView.reloadData()
        }
    }
    
    //MARK: filtring users
    func filterUsers (with term: String) {
        
        let filterdUsers :[User] = self.allUsers.filter({
            let name = $0.name.lowercased()
            return name.hasPrefix(term.lowercased())
        })
        self.results = filterdUsers
        tableView.reloadData()
        self.spinner.dismiss()
        updateUI()
    }
}

extension NewConversationViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.isFocused && searchBar.text != " "{
   
            return results.count
        }else{
            return allUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        
        if searchBar.isFocused && searchBar.text != " "{
           
            cell.textLabel?.text = results[indexPath.row].name
            cell.detailTextLabel?.text = results[indexPath.row].email
        }else{
            cell.textLabel?.text = allUsers[indexPath.row].name
            cell.detailTextLabel?.text = allUsers[indexPath.row].email
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUserData = allUsers[indexPath.row]
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData)
        })
    }
}



