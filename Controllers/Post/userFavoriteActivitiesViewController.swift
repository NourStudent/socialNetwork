//
//  userActivitiesViewController.swift
//  socialNetwork
//
//  Created by Nour Achour on 2021-03-20.
//

   import UIKit
   import JGProgressHUD
   import Firebase


class userFavoriteActivitiesViewController: UIViewController ,UITableViewDelegate , UITableViewDataSource{

   private let spinner = JGProgressHUD(style: .dark)
    var activitiesDictionary = [String:[String]]()
    var activitiesTitle = [String]()
    var favoritesArray = [String]()
    var isFavorited = false
  
    @IBOutlet weak var tableView: UITableView!
    
 
    
    //using custom delegation
    func favoriteUserActivities(cell:UITableViewCell){
        print("Inside of userFavoriteViewController now...")
        // we're going to figure out which activityName we're clicking on
        
       let indexPathTapped = tableView.indexPath(for: cell)
       let activityNameSection = activitiesTitle[indexPathTapped!.section]
       let activityName = activitiesDictionary[activityNameSection]![indexPathTapped!.row]
        print("\(activityName) clicked..")
        
        if favoritesArray.contains(activityName){
            Service.deleteFromFavoriteActivity(activityName: activityName, completion: {success in
                if success{
                    print("deleted succefully")
                }else{
                    print("failed to delete")
                }
            })
        }else{
            Service.favoriteActivities(activityName: activityName, completion: {success in
                       if success{
                           print("added succefully")
                       }else{
                           print("failed to add")
                       }
                   })
        }
        
     
    }
    
    
    func getAllFavoritesActivities(){
        
     guard let user = Auth.auth().currentUser ,let currentUserEmail = user.email else {return}
        let safeEmail = Service.safeEmail(email: currentUserEmail).lowercased()
        let ref = Database.database().reference().child("users").child("\(safeEmail)").child("favoriteActivities")
             ref.observe(.value, with:{ snapshot in
                print(snapshot)
              
                 guard let favoriteActivities = snapshot.value as? [String] else{return}
                self.favoritesArray = favoriteActivities
                print(self.favoritesArray.count)
             })
    }
        
 
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllFavoritesActivities()
        self.title = "Favorite Activities"
        for activity in activities{
            let activityKey = String(activity.prefix(1))
            if var activityValues = activitiesDictionary[activityKey]{
                activityValues.append(activity)
                activitiesDictionary[activityKey] = activityValues
            }else{
                activitiesDictionary[activityKey] = [activity]
            }
        }
        activitiesTitle = [String](activitiesDictionary.keys)
        activitiesTitle = activitiesTitle.sorted(by: {$0 < $1})
        
        
    }
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
       return activitiesTitle.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let activityKey = activitiesTitle[section]
        if let activitiesValue = activitiesDictionary[activityKey]{
            return activitiesValue.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userPostscell", for: indexPath) as! ActivityTableViewCell
        

        cell.link = self
        let activityKey = activitiesTitle[indexPath.section]
        if let activitiesValue = activitiesDictionary[activityKey]{
            cell.textLabel?.text = activitiesValue[indexPath.row]
        }
        
        
        return cell
        

    }

    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return activitiesTitle[section]
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return activitiesTitle
    }
    
 
}
