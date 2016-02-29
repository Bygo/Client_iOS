//
//  DataValidator.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

let kMIN_FIRST_NAME_NUM_CHARACTERS = 1
let kMIN_LAST_NAME_NUM_CHARACTERS = 1
let kMIN_PASSWORD_NUM_CHARACTERS = 5
let kREQUIRED_CODE_NUM_CHARACTERS = 6

class DataValidator: NSObject {
    
    // Return true if the str is a valid password
    func isValidPassword(str:String) -> Bool {
        return str.characters.count >= kMIN_PASSWORD_NUM_CHARACTERS
    }
    
    // Return true if the str is a valid phone number
    func isValidPhoneNumber(str:String) -> Bool {
        var digits = str.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        digits = digits.filter({$0 != ""})
        if digits.count != 4 { return false }
        let countryCode = digits[0]
        let areaCode = digits[1]
        let prefix = digits[2]
        let suffix = digits[3]
        if countryCode != "1" { return false }
        if areaCode.characters.count != kAREA_CODE_CHARACTER_COUNT { return false }
        if prefix.characters.count != kPREFIX_CHARACTER_COUNT { return false }
        if suffix.characters.count != kSUFFIX_CHARACTER_COUNT { return false }
        return true
    }
    
    
    // Return true if the str is a valid email
    func isValidEmail(str:String) -> Bool {
//        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(str)
    }
    
    
    // Return true if the str is a valid first name
    func isValidFirstName(str:String) -> Bool {
        return str.characters.count >= kMIN_FIRST_NAME_NUM_CHARACTERS
    }
    
    
    // Return true if the str is a valid last name
    func isValidLastName(str:String) -> Bool {
        return str.characters.count >= kMIN_LAST_NAME_NUM_CHARACTERS
    }
    
    // Return true if the str might be a valid verification code
    func isValidMobileVerificationCode(str:String) -> Bool {
        return str.characters.count == kREQUIRED_CODE_NUM_CHARACTERS
    }
}


// MARK - Phone Number Constants
let kMAX_PHONE_NUMBER_CHARACTER_COUNT = 11
let kAREA_CODE_CHARACTER_COUNT = 3
let kPREFIX_CHARACTER_COUNT = 3
let kSUFFIX_CHARACTER_COUNT = 4
let kUSA_COUNTRY_CODE = "+1"
