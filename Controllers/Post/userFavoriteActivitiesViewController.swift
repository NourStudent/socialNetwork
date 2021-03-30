//
//  userActivitiesViewController.swift
//  socialNetwork
//
//  Created by Nour Achour on 2021-03-20.
//

   import UIKit
   import JGProgressHUD
   import Firebase


class userFavoriteActivitiesViewController: UIViewController {

   private let spinner = JGProgressHUD(style: .dark)
   @IBOutlet weak var tableView: UITableView!
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
         
        self.title = "Favorite Activities"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
       }
}
    
extension userFavoriteActivitiesViewController: UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfactivities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    let cell = tableView.dequeueReusableCell(withIdentifier: "userPostscell", for: indexPath) as! ActivityTableViewCell
         
        let activity = listOfactivities[indexPath.row]
        cell.activityLabel.text = activity.title
        cell.imageFavorite.image = activity.isFavorited == true ? UIImage(named: "favorited") : UIImage(named: "notFavorited")
        
       return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? ActivityTableViewCell else {
            return
        }
        var activity = listOfactivities[indexPath.row]
   
        activity.isFavorited = !activity.isFavorited
        cell.imageFavorite.image = UIImage(named: "favorited")
        
        listOfactivities.remove(at: indexPath.row)
        listOfactivities.insert(activity, at: indexPath.row)
        
        if activity.isFavorited == true {
            
        cell.imageFavorite.image = UIImage(named: "favorited")
            Service.favoriteActivities(activityName: activity.title, completion: { succes in
                if succes {
                    print("added to database suuccefully")
                } else{
                    print("failed to add it")
                }
            })
        
    } else{
        
        cell.imageFavorite.image = UIImage(named: "notFavorited")
        Service.deleteFromFavoriteActivity(activityName: activity.title, completion: { success in
            if success{
                print("deleted suuccefully")
            } else{
                print("failed delete it")
            }
            
        })
        
    
    
    }
    }

    
    
 
}
