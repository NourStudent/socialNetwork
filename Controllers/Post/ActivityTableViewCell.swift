//
//  ActivityTableViewCell.swift
//  socialNetwork
//
//  Created by Nour Achour on 2021-03-20.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {

    var link: userFavoriteActivitiesViewController?
   
    
    override func awakeFromNib() {
       super.awakeFromNib()
       //custom logic goes here
        let startButton = UIButton(type: .system)
        startButton.setImage(#imageLiteral(resourceName: "fav"), for: .normal)
        startButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        startButton.tintColor = .gray
        startButton.addTarget(self, action: #selector(handleMarkAsFavorite), for: .touchUpInside)
        accessoryView = startButton
    }
    
    
    @objc private func handleMarkAsFavorite(){
        link?.favoriteUserActivities(cell: self)
        
        let startButton = UIButton(type: .system)
        startButton.setImage(#imageLiteral(resourceName: "fav"), for: .normal)
        startButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        startButton.tintColor = .red
        accessoryView = startButton
       
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        
    }
    
}
