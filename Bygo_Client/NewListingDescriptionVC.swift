//
//  NewListingDescriptionVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class NewListingDescriptionVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet var instructionLabel:UILabel!
    @IBOutlet var descriptionLabel:UILabel!
    @IBOutlet var descriptionTextView:UITextView!
    @IBOutlet var continueButton:UIButton!
    @IBOutlet var continueButtonDistanceToBottomLayoutGuide: NSLayoutConstraint!
    
    
    var model:Model?
    var listingName:String?
    var listingDepartment:Department?
    var listingCategory:Category?
    var listingImages:[UIImage] = []
    var listingValue:Double?
    var listingHourlyRate:Double?
    var listingDailyRate:Double?
    var listingWeeklyRate:Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        // TODO: Give the description text view a placeholder
        continueButton.enabled = isDataValid()
    }
    
    override func viewDidAppear(animated: Bool) {
        navigationController?.navigationItem.backBarButtonItem?.title = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Data
    func isDataValid() -> Bool {
        return descriptionTextView.text.characters.count > 0
    }
    
    
    // MARK: - Keyboard
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            descriptionTextView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        descriptionTextView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    func textViewDidChange(textView: UITextView) {
        continueButton.enabled = isDataValid()
    }
    
    // MARK: - UI Actions
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - UIActions
    @IBAction func continueButtonTapped(sender:AnyObject) {
        
        print(model)
        print(model?.userServiceProvider.getLocalUser())
        print(model?.userServiceProvider.getLocalUser()?.userID)
        
        // Validate the Listing data
        guard let userID            = model?.userServiceProvider.getLocalUser()?.userID else { print("No user id"); return }
        guard let name              = listingName                   else { return }
        guard let categoryID        = listingCategory?.categoryID   else { return }
        guard let totalValue        = listingValue                  else { return }
        guard let hourlyRate        = listingHourlyRate             else { return }
        guard let dailyRate         = listingDailyRate              else { return }
        guard let weeklyRate        = listingWeeklyRate             else { return }
        guard let itemDescription   = descriptionTextView.text      else { return }
        
        // Create the new Listing
        model?.listingServiceProvider.createNewListing(userID, name: name, categoryID: categoryID, totalValue: totalValue, hourlyRate: hourlyRate, dailyRate: dailyRate, weeklyRate: weeklyRate, itemDescription: itemDescription, completionHandler: {
            (success:Bool) in
            if success {
                self.navigationController?.topViewController?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                print("Error creating new Listing")
            }
        })
    }
}
