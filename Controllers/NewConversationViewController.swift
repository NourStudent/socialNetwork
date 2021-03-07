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
    
    
    public var completion: (([String:String])-> (Void))?
    
    private let spinner = JGProgressHUD(style: .dark)
    var allUsers = [NSDictionary?]()
    var results = [NSDictionary?]()
    var searchController : UISearchController!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        
        searchAllUsers()
       
        view.backgroundColor = .white
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
    
    
    //MARK: searching users by name
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)

        filterContent(searchText: searchText)

        DispatchQueue.main.async {

            self.tableView.reloadData()

        }
        print(results.count)

        self.spinner.dismiss()
    }
    
    func updateSearchResults(for searchController: UISearchController) {

        if let searchText = searchController.searchBar.text {
            filterContent(searchText: searchText)
            tableView.reloadData()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

       if let searchText = searchBar.text {
            filterContent(searchText: searchText)
            tableView.reloadData()
        }
    }


    //MARK: fetching all users
    func searchAllUsers(){
        spinner.show(in: view)
        let ref = Database.database().reference()
        ref.child("users").queryOrdered(byChild: "name").observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            self.allUsers.append(snapshot.value as? NSDictionary)
            self.tableView.insertRows(at: [IndexPath(row: self.allUsers.count-1, section: 0)], with: .automatic)
            self.spinner.dismiss()
        }) {(error) in
            print(error.localizedDescription)
            
        }
    
       }
    
    //MARK: filtring users
    
    func filterContent(searchText: String){
        spinner.show(in: view)
        let filtredSource = self.allUsers.filter{ user in
            let username = user!["name"] as? String
            return(username?.lowercased().contains(searchText.lowercased()))!
        }
        results = filtredSource
        tableView.reloadData()
       
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
        let user : NSDictionary?
        if searchBar.isFocused && searchBar.text != " "{
            user = results[indexPath.row]
        }else{
            user = allUsers[indexPath.row]
        }
        
        cell.textLabel?.text = user?["name"] as? String
        cell.detailTextLabel?.text = user?["email"] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUserData = allUsers[indexPath.row]
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData as! [String : String])
        })
        
       
    }
    
}



