//
//  Category.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 3/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class Category: Object {
    
    dynamic var categoryID:String?  = nil
    dynamic var name:String?        = nil
    
    // Relations
    dynamic var departmentID:String? = nil
}
