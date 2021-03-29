//
//  PostTableViewCell.swift
//  socialNetwork
//
//  Created by Nour Achour on 2021-03-18.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var activityName: UILabel!
    
    
    @IBOutlet weak var authorName: UILabel!
    
    @IBOutlet weak var startDate: UILabel!
    
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var teamMembers: UILabel!
            

    
    
    public func configure(with model: Post){
        
        self.activityName.text = "Activity name: \(model.activityName)"
        self.authorName.text = "shared by: \(model.author)"
        self.startDate.text = "starting Date: \(model.startingDate)"
        self.endDate.text = "Ending Date: \(model.endingDate)"
        self.location.text = "Location: \(model.Location)"
        self.teamMembers.text = "Team Members: \(model.teamMembers)"
        
        
        DispatchQueue.main.async {
            Service.getUserProfilePhoto(imageView: self.profileImage)
        }
    }
}
    
    
    
    

