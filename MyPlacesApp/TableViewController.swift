//
//  TableViewController.swift
//  MyPlacesApp
//
//  Created by Антон Филиппов on 14.07.2022.
//

import UIKit
import RealmSwift

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reverseSortingButton: UIBarButtonItem!
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var filtredPlaces: Results<Place>!
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    
    private var isFiltred: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    private var ascendingSorting = true
    private var places: Results<Place>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        places = realm.objects(Place.self)
        
        //Setup search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltred {
            return filtredPlaces.count
        }
        return places.isEmpty ? 0 : places.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        let place = isFiltred ? filtredPlaces[indexPath.row] : places[indexPath.row]
        cell.nameLabel?.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.imageOfPlace?.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace?.clipsToBounds = true
        return cell
    }
    
    // MARK: - Table view deligate
    
    //varian for severals actions on trail swipe
    //    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    //        let place = places[indexPath.row]
    //        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
    //            StorageManager.deletePlace(place)
    //            tableView.deleteRows(at: [indexPath], with: .automatic)
    //        }
    //        return UISwipeActionsConfiguration(actions: [deleteAction])
    //    }
    
    //simple variant for one action on swipe
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let place = isFiltred ? filtredPlaces[indexPath.row] : places[indexPath.row]
            StorageManager.deletePlace(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    
    //  MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place = isFiltred ? filtredPlaces[indexPath.row] : places[indexPath.row]
            let newPlaceVC = segue.destination as! NewPlaceVC
            newPlaceVC.currentPlace = place
        }
    }
    
    
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceVC else {return}
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
    }
    @IBAction func reversedSorting(_ sender: UIBarButtonItem) {
        ascendingSorting.toggle()
        if ascendingSorting == true {
            reverseSortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reverseSortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        sorting()
    }
    
    private func sorting() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
    
}


extension TableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filtredPlaces = places.filter("name CONTAINS[c] %@ or location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
}

