//
//  Post.swift
//  socialNetwork
//
//  Created by Nour Achour on 2021-03-18.
//

import Foundation
import UIKit


class Post {
    var Location: String
    var activityName: String
    var author: String
    var authorImage: String
    var endingDate: String
    var startingDate: String
    var teamMembers:String
    
    init(Location: String,activityName: String,author: String,authorImage: String,endingDate: String,startingDate: String,teamMembers:String) {
        self.Location = Location
        self .activityName = activityName
        self.author = author
        self.authorImage = authorImage
        self.endingDate = endingDate
        self.startingDate = startingDate
        self.teamMembers = teamMembers
        
    }
}
