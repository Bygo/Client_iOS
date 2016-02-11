//
//  MeetingResponderCollectionViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 7/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class MeetingResponderCollectionViewCell: UICollectionViewCell {
    @IBOutlet var renterImageImageView: UIImageView!
    @IBOutlet var renterNameLabel: UILabel!
    @IBOutlet var renterRatingImageView: UIImageView!
    @IBOutlet var tableView: UITableView!
    
    override func prepareForReuse() {
        if tableView != nil {
            print("Prepare for reuse")
            tableView.contentOffset.y = -400.0
        }
        
        print(tableView.contentOffset)
    }
}
