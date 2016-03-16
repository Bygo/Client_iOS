//
//  NewListingPhotosVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class NewListingPhotosVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var instructionLabel:UILabel!
    @IBOutlet var collectionView:UICollectionView!
    @IBOutlet var addImageButton:UIButton!
    @IBOutlet var nextButton: UIBarButtonItem!
    
    var model:Model?
    var listingName:String?
    var listingDepartment:Department?
    var listingCategory:Category?
    var listingImages:[UIImage] = []
    
    
    private let kMAX_NUM_IMAGES = 5
    
    var imagePicker:UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        continueButton.enabled = isDataValid()
        addImageButton.enabled = shouldAddMoreImages()
        
//        continueButton.backgroundColor = kCOLOR_FIVE
        addImageButton.backgroundColor = kCOLOR_FIVE
        view.backgroundColor = kCOLOR_THREE
        collectionView.backgroundColor = kCOLOR_THREE
        
        enableNextButtonIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        navigationController?.navigationItem.backBarButtonItem?.title = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func enableNextButtonIfNeeded() {
        if isDataValid() {
            UIView.animateWithDuration(0.5, animations: {
                self.nextButton.enabled = true
            })
        } else {
            UIView.animateWithDuration(0.5, animations: {
                self.nextButton.enabled = false
            })
        }
    }
    
    func disableAddImageButtonIfNeeded() {
        if !shouldAddMoreImages() {
            addImageButton.enabled = false
            UIView.animateWithDuration(0.25, animations: {
                self.addImageButton.alpha = 0.0
            })
        } else {
            addImageButton.enabled = true
            UIView.animateWithDuration(0.25, animations: {
                self.addImageButton.alpha = 1.0
            })
        }
    }
    
    // MARK: - Data
    func isDataValid() -> Bool {
        return listingImages.count > 0
    }
    
    func shouldAddMoreImages() -> Bool {
        return listingImages.count < kMAX_NUM_IMAGES
    }
    
    
    // MARK: - UICollectionView Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listingImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as? NewListingPhotoCollectionViewCell else { return UICollectionViewCell() }
        
        cell.image.contentMode          = UIViewContentMode.ScaleAspectFill
        cell.image.clipsToBounds        = true
        cell.image.layer.masksToBounds  = true
        cell.image.image                = listingImages[indexPath.row]
        cell.image.layer.cornerRadius   = kCORNER_RADIUS
        cell.backgroundColor            = kCOLOR_THREE
        cell.deleteButton.tag           = indexPath.row
        cell.deleteButton.titleLabel?.textColor = kCOLOR_TWO
        cell.deleteButton.addTarget(self, action: "deleteImageButtonTapped:", forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    
    // MARK: - Image Picker Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        listingImages.append(image)
//        continueButton.enabled = isDataValid()
        enableNextButtonIfNeeded()
        addImageButton.enabled = shouldAddMoreImages()
        collectionView.reloadData()
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: collectionView.numberOfItemsInSection(0)-1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        disableAddImageButtonIfNeeded()
    }
    
    
    // MARK: - UIActions
    @IBAction func deleteImageButtonTapped(sender:AnyObject) {
        guard let idx = sender.tag else { return }
        listingImages.removeAtIndex(idx)
//        continueButton.enabled = isDataValid()
        enableNextButtonIfNeeded()
        disableAddImageButtonIfNeeded()
        addImageButton.enabled = shouldAddMoreImages()
        collectionView.performBatchUpdates({
            self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: idx, inSection: 0)])
            }, completion: nil)
    }
    
    @IBAction func newImageButtonTapped(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                self.imagePicker.sourceType     = .PhotoLibrary
                self.imagePicker.delegate       = self
                self.imagePicker.allowsEditing  = false
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        })
        
        let cameraAction = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                self.imagePicker.sourceType     = .Camera
                self.imagePicker.cameraDevice   = UIImagePickerControllerCameraDevice.Rear
                self.imagePicker.delegate       = self
                self.imagePicker.allowsEditing  = false
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(photoLibraryAction)
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func continueButtonTapped(sender:AnyObject) {
        if isDataValid() {
            performSegueWithIdentifier("ShowSetItemValue", sender: nil)
        }
    }
    
    
    // MARK: - UI Actions
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSetItemValue" {
            guard let destVC = segue.destinationViewController as? NewListingValueVC else { return }
            destVC.model                = model
            destVC.listingName          = listingName
            destVC.listingDepartment    = listingDepartment
            destVC.listingCategory      = listingCategory
            destVC.listingImages        = listingImages
        }
    }
}

// MARK: - UICollectionViewDelegate
extension NewListingPhotosVC : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.bounds.width-16.0, (view.bounds.width-16.0) + 48)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0)
    }
}