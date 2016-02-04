//
//  AccountSettingsVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class AccountSettingsVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var lastNameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    var imagePicker:UIImagePickerController = UIImagePickerController()
    
    var model:Model?
    var delegate:AccountSettingsDelegate?
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the profile imageView
        profileImageView.contentMode = UIViewContentMode.ScaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2.0
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 0.0
        
        // Set user specific UI
        configureUserSpecificUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - User
    func configureUserSpecificUI() {
        
        // Setup the user name and profile image
        guard let user      = model?.userServiceProvider.getLocalUser() else { return }
        if let firstName    = user.firstName    { firstNameTextField.text = firstName }
        if let lastName     = user.lastName     { lastNameTextField.text = lastName }
        if let email        = user.email        { emailTextField.text = email }
        if let phoneNumber  = user.phoneNumber  { phoneNumberTextField.text = phoneNumber }
    }
    
    
    // MARK: - UI Actions
    @IBAction func changePhotoButtonTapped(sender: AnyObject) {
        // TODO: Update image
        
        // Create the 'Photo Library' option
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                self.imagePicker.sourceType = .PhotoLibrary
                self.imagePicker.delegate = self
                self.imagePicker.allowsEditing = false
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        })
        
        // Create the 'Camera' option
        let cameraAction = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                self.imagePicker.sourceType = .Camera
                self.imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
                self.imagePicker.delegate = self
                self.imagePicker.allowsEditing = false
                self.presentViewController(self.imagePicker, animated: false, completion: nil)
            }
        })
        
        // Create the 'Cancel' option
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        // Show the action sheet
        optionMenu.addAction(photoLibraryAction)
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissKeyboard()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        dismissKeyboard()
        
        // Check that all the Account data is valid
        // TODO: If any of these guards fail, show the user where the error occured
        guard let model         = model                     else { return }
        guard let firstName     = firstNameTextField.text   else { return }
        guard let lastName      = lastNameTextField.text    else { return }
        guard let phoneNumber   = phoneNumberTextField.text else { return }
        guard let email         = emailTextField.text       else { return }
        if !model.dataValidator.isValidPhoneNumber(phoneNumber) { return }
        if !model.dataValidator.isValidEmail(email)             { return }
        if !model.dataValidator.isValidFirstName(firstName)     { return }
        if !model.dataValidator.isValidLastName(lastName)       { return }
        
        // Update the local user Account
        model.userServiceProvider.updateLocalUser(firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, completionHandler: {(success:Bool)->Void in
            if success {
                self.dismissViewControllerAnimated(true, completion: {
                    self.delegate?.didUpdateAccountSettings()
                })
            } else {
                // TODO: Throw an error message
            }
        })
    }
    
    
    // MARK: - Text Field Delegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        // Format the phoneNumberTextField to "+1 123 456 7890" format
        if textField == phoneNumberTextField {
            if let text = textField.text {
                let newString = (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
                let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
                
                let decimalString = components.joinWithSeparator("") as NSString
                let length = decimalString.length
                if length == 0 || length > kMAX_PHONE_NUMBER_CHARACTER_COUNT {
                    let newLength = (text as NSString).length + (string as NSString).length - range.length as Int
                    return (newLength > kMAX_PHONE_NUMBER_CHARACTER_COUNT) ? false : true
                }
                var index = 0 as Int
                let formattedString = NSMutableString()
                
                formattedString.appendString("\(kUSA_COUNTRY_CODE) ")
                index += 1
                
                if (length-index) > kAREA_CODE_CHARACTER_COUNT {
                    let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                    formattedString.appendFormat("%@ ", areaCode)
                    index += kAREA_CODE_CHARACTER_COUNT
                }
                
                
                if length - index > kPREFIX_CHARACTER_COUNT {
                    let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                    formattedString.appendFormat("%@ ", prefix)
                    index += kPREFIX_CHARACTER_COUNT
                }
                
                let remainder = decimalString.substringFromIndex(index)
                formattedString.appendString(remainder)
                textField.text = formattedString as String
                return false
            }
        }
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        
        // Format the phoneNumberTextField to a constant country code of "+1 "
        if textField == phoneNumberTextField {
            textField.text = "\(kUSA_COUNTRY_CODE) "
            return false
        }
        return true
    }
    
    // MARK: - Image Picker Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        profileImageView.image = image
        // TODO: Update the local user object
    }
 
    
    // MARK: - Keyboard Handler
    private func dismissKeyboard() {
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        phoneNumberTextField.resignFirstResponder()
    }
}

protocol AccountSettingsDelegate {
    func didUpdateAccountSettings();
}
