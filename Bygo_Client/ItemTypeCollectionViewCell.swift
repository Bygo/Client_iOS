//
//  QuickRequestCollectionViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 5/3/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class ItemTypeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
 
    override func prepareForReuse() {
        backgroundColor = .whiteColor()
    }
    
}
