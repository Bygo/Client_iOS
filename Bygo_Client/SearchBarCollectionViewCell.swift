//
//  SearchBarCollectionViewCell.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 5/3/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class SearchBarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var searchBar: SearchBar!
    
    override func prepareForReuse() {
        backgroundColor = .clearColor()
    }
    
}
