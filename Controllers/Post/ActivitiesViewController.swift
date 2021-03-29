//
//  ActivitiesViewController.swift
//  socialNetwork
//
//  Created by Nour Achour on 2021-03-18.
//

import UIKit
import JGProgressHUD
import Firebase

class ActivitiesViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
  
    public var completion: (([String:String])-> (Void))?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
   
    @IBOutlet weak var dismissButton: UIButton!
    
    
    private let noPostsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Activities Yet!"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize:21, weight : .medium)
        label.isHidden = false
        return label
    }()
    
    
    private let spinner = JGProgressHUD(style: .dark)
    var allPosts = [Post]()
    var searchedPosts:[Post]!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        searchAllPosts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noPostsLabel)
        searchedPosts = allPosts
        dismissButton.layer.cornerRadius = 10
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        noPostsLabel.frame = CGRect(x: 10,
                                            y: (view.height-100)/2,
                                            width: view.width-20,
                                            height: 100)
    }
  
    //MARK: fetching all activities
    func searchAllPosts(){
       let ref = Database.database().reference()
            ref.child("allPosts").observe(.childAdded) { snapshot in
                if let dictionary = snapshot.value as? [String:Any]{
                    
                    let authorName = dictionary["author"] as! String
                    let activityName = dictionary["activityName"] as! String
                    let startDate = dictionary["startingDate"] as! String
                    let endDate = dictionary["endingDate"] as! String
                    let location = dictionary["Location"] as! String
                    let teamMembers = dictionary["teamMembers"] as! String
                    let imageUrl = dictionary["authorImage"] as! String
                    let post = Post(Location: location, activityName: activityName, author: authorName, authorImage: imageUrl, endingDate: endDate, startingDate: startDate, teamMembers: teamMembers)
                    self.allPosts.append(post)
                   
                    DispatchQueue.main.async {
                        self.searchedPosts = self.allPosts
                        self.tableView.reloadData()
                        self.noPostsLabel.isHidden = true
                        
                    }
                }
           }
    }
    
    
    //MARK: filtring users
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedPosts = []
        
        if searchText == "" {
            searchedPosts = allPosts
        }else{
            
            for post in allPosts {
                if post.author.lowercased().contains(searchText.lowercased()) || post.activityName.lowercased().contains(searchText.lowercased()) {
                    searchedPosts.append(post)
                }
                
            }
        }
        
       
        tableView.reloadData()
    }
   

    
    @IBAction func dismissViewAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func participate(_ sender: Any) {
    }

    
    
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return searchedPosts.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell",for: indexPath) as! PostTableViewCell
       
            let model = searchedPosts[indexPath.row]
            cell.configure(with: model)
        
            return cell
        
       
    
    }

}
