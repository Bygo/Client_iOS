//
//  EditListingDescription.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class EditListingDescriptionVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet var instructionLabel:UILabel!
    @IBOutlet var descriptionLabel:UILabel!
    @IBOutlet var descriptionTextView:UITextView!
    @IBOutlet var continueButton:UIButton!
    
    var model:Model?
    var delegate:EditListingDescriptionDelegate?
    var listing:Listing?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        // TODO: Give the description text view a placeholder
        continueButton.enabled = isDataValid()
        
        guard let itemDescription = listing?.itemDescription else { return }
        descriptionTextView.text = itemDescription
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
    
    
    // MARK: - UIActions
    @IBAction func continueButtonTapped(sender:AnyObject) {
        if isDataValid() {

            guard let itemDescription = descriptionTextView.text else { return }
            
            guard let listingID         = listing?.listingID            else { return }
            guard let name              = listing?.name                 else { return }
            guard let categoryID        = listing?.categoryID           else { return }
            guard let totalValue        = listing?.totalValue.value     else { return }
            guard let hourlyRate        = listing?.hourlyRate.value     else { return }
            guard let dailyRate         = listing?.dailyRate.value      else { return }
            guard let weeklyRate        = listing?.weeklyRate.value     else { return }
            
            model?.listingServiceProvider.updateListing(listingID, name: name, categoryID: categoryID, totalValue: totalValue, hourlyRate: hourlyRate, dailyRate: dailyRate, weeklyRate: weeklyRate, itemDescription: itemDescription, completionHandler: {
                (success:Bool) in
                if success {
                    self.delegate?.didUpdateDescription()
                    self.navigationController?.popToRootViewControllerAnimated(true)
                } else {
                    print("Error updating the Listing")
                }
            })
            
            // NOTE: Diabled for demo mode
            //            guard let item = item else { return }
            //            guard let itemDescription = descriptionTextView.text else { return }
            //
            //
            //
            //            model?.updateItem(item.itemID, name: item.name, categoryID: item.categoryID, totalValue: item.totalValue, hourlyRate: item.hourlyRate, dailyRate: item.dailyRate, weeklyRate: item.weeklyRate, itemDescription: itemDescription, completionHandler: {(success:Bool)->Void in
            //                if success {
            //                    self.descriptionTextView.resignFirstResponder()
            //                    self.delegate?.didUpdateDescription()
            //                    self.navigationController?.popToRootViewControllerAnimated(true)
            //                } else {
            //                    print("Error updating description")
            //                }
            //            })
//            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
}


protocol EditListingDescriptionDelegate {
    func didUpdateDescription()
}
