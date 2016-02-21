//
//  NewFavoriteMeetingLocationVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

class NewFavoriteMeetingLocationVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    lazy var searchBar: UISearchBar = UISearchBar(frame: CGRectMake(0,0,200,20))
    var placesClient: GMSPlacesClient?
    let locationManager = CLLocationManager()
    var searchRegion:MKCoordinateRegion?
    var autocompletePredictions:[GMSAutocompletePrediction] = []
    
    
    var model:Model?
    var delegate:NewFavoriteMeetingLocationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Design
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Setup Google API Key
        GMSServices.provideAPIKey("AIzaSyBMvGu6ZWAj8ZbAn1afQZI7pqC9amM9mw0")
        
        // Other setup
        searchBar.frame.size = CGSizeMake(view.bounds.width - 100.0, 20.0)
        searchBar.placeholder = "Enter Handoff Location"
        let rightNavBarButtonItem = UIBarButtonItem(customView:searchBar)
        self.navigationItem.rightBarButtonItem = rightNavBarButtonItem
        placesClient = GMSPlacesClient()
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44.0
        
        // Get current location
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
            if let currentLocation:CLLocation = locationManager.location {
                let kACCEPTABLE_DISTANCE_IN_METERS:Double = 7500
                searchRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, kACCEPTABLE_DISTANCE_IN_METERS, kACCEPTABLE_DISTANCE_IN_METERS)
            }
        } else {
            //TODO: Display message to user that the app will not work without location services
            print("Location services disabled")
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - SearchBar Delegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Get the new serch text
        if searchText.characters.count < 1 {
            autocompletePredictions = []
            self.tableView.reloadData()
            return
        }
        
        // Make a new location query and display the results
        if let searchRegion = searchRegion {
            let upperLeftBound = CLLocationCoordinate2D(latitude: searchRegion.center.latitude - searchRegion.span.latitudeDelta, longitude: searchRegion.center.longitude - searchRegion.span.longitudeDelta)
            let lowerRightBound = CLLocationCoordinate2D(latitude: searchRegion.center.latitude + searchRegion.span.latitudeDelta, longitude: searchRegion.center.longitude + searchRegion.span.longitudeDelta)
            let bounds = GMSCoordinateBounds(coordinate: upperLeftBound, coordinate: lowerRightBound)
            let filter = GMSAutocompleteFilter()
            filter.type = GMSPlacesAutocompleteTypeFilter.NoFilter
            placesClient?.autocompleteQuery(searchText, bounds: bounds, filter: filter, callback: { (results, error: NSError?) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    if let error = error {
                        print("Autocomplete error \(error)")
                    }
                    if let results = results as? [GMSAutocompletePrediction] {
                        self.autocompletePredictions = results
                        self.tableView.reloadData()
                    }
                })
            })
        } else {
            print("App will not work without location services")
            //TODO: Display message to user that the app will not work without location services
        }
    }
    
    // MARK: - TableView Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompletePredictions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("AutocompleteSuggestion", forIndexPath: indexPath) as? AutoCompleteLocationSuggestionTableViewCell else { return UITableViewCell() }
        let suggestion = autocompletePredictions[indexPath.row]
        let placeID = suggestion.placeID
        
        placesClient?.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                cell.locationNameLabel.text = place.name
                cell.streetNameLabel.text = place.formattedAddress
            } else {
                print("No place details for \(placeID)")
            }
        })
        
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // TODO: Get the locationID for this autocomplete suggestion. Add it to the user's favorite handoff locations
        let suggestion  = autocompletePredictions[indexPath.row]
        let placeID     = suggestion.placeID
        placesClient?.lookUpPlaceID(placeID, callback: {
            (place, error)->Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                let name        = place.name
                let address     = place.formattedAddress
                let isPrivate   = false
                self.model?.favoriteMeetingLocationServiceProvider.createNewFavoriteMeetingLocation(placeID, address: address, name: name, isPrivate: isPrivate, completionHandler: { (success:Bool)->Void in
                    if success {
                        self.searchBar.resignFirstResponder()
                        self.dismissViewControllerAnimated(true, completion: {
                            self.delegate?.didAddNewFavoriteMeetingLocation()
                        })
                    } else {
                        print("Error creating new favorite meeting location")
                    }
                })
            } else {
                print("No place details for \(placeID)")
            }
        })
        
    }
    
    // MARK: - UI Actions
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
}


protocol NewFavoriteMeetingLocationDelegate {
    func didAddNewFavoriteMeetingLocation()
}
