//
//  EditListingPhotosVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 21/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import Haneke

class EditListingPhotosVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet var instructionLabel:UILabel!
    @IBOutlet var collectionView:UICollectionView!
    @IBOutlet var addImageButton:UIButton!
    @IBOutlet var continueButton:UIButton!
    
    var model:Model?
    var delegate:EditListingPhotosDelegate?
    var listing:Listing?
    
    private let kMAX_NUM_IMAGES = 5
    
    var imagePicker:UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Data
    func isDataValid() -> Bool {
        return listing?.imageLinks.count > 0
    }
    
    func shouldAddMoreImages() -> Bool {
        return listing?.imageLinks.count < kMAX_NUM_IMAGES
    }
    
    
    // MARK: - UICollectionView Data Source
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let listing = listing {
            return listing.imageLinks.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as? NewListingPhotoCollectionViewCell else { return UICollectionViewCell() }
        
        cell.image.contentMode          = UIViewContentMode.ScaleAspectFill
        cell.image.clipsToBounds        = true
        cell.image.layer.masksToBounds  = true
        cell.image.hnk_setImageFromURL(NSURL(string: listing!.imageLinks[indexPath.row].value!)!)
//        cell.image.image                = listingImages[indexPath.row]
        cell.image.layer.cornerRadius   = kCORNER_RADIUS
        cell.deleteButton.tag           = indexPath.row
        cell.deleteButton.titleLabel?.textColor = kCOLOR_TWO
        cell.deleteButton.addTarget(self, action: "deleteImageButtonTapped:", forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    
    // MARK: - Image Picker Delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        
        guard let listingID = listing?.listingID else { return }
        model?.listingServiceProvider.addImageForListing(listingID, image: image, completionHandler: {
            (success:Bool) in
            if success {
                dispatch_async(GlobalMainQueue, {
                    self.continueButton.enabled = self.isDataValid()
                    self.addImageButton.enabled = self.shouldAddMoreImages()
                    self.collectionView.reloadData()
                    self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: self.collectionView.numberOfItemsInSection(0)-1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
                })
            }
        })
    }
    
    
    // MARK: - UIActions
    @IBAction func deleteImageButtonTapped(sender:AnyObject) {
//        guard let idx = sender.tag else { return }
//        listingImages.removeAtIndex(idx)
//        continueButton.enabled = isDataValid()
//        addImageButton.enabled = shouldAddMoreImages()
//        collectionView.performBatchUpdates({
//            self.collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: idx, inSection: 0)])
//            }, completion: nil)
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
                self.presentViewController(self.imagePicker, animated: false, completion: nil)
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
            delegate?.didUpdatePhotos()
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    
    // MARK: - UI Actions
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}



protocol EditListingPhotosDelegate {
    func didUpdatePhotos()
}


// MARK: - UICollectionViewDelegate
extension EditListingPhotosVC : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.bounds.width-16.0, view.bounds.width-16.0 + 55.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 16.0
    }
}