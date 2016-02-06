//
//  ProposedMeetingTime.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class ProposedMeetingTime: Object {
    
    dynamic var time:NSDate?        = nil
    dynamic var duration: Double    = 0.0
    dynamic var isAvailable: Bool   = false
    
}
