//
//  ActivityTableViewCell.swift
//  socialNetwork
//
//  Created by Nour Achour on 2021-03-20.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {

 
    @IBOutlet weak var imageFavorite: UIImageView!
    @IBOutlet weak var activityLabel: UILabel!
    
    override func awakeFromNib() {
       super.awakeFromNib()
       //custom logic goes here
      
    }
    
   required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        
    }
    
}


struct ActivityFavorite {
    var title: String
    var isFavorited: Bool
}
