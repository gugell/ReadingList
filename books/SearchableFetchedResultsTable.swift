//
//  SearchableFetchedResultsTable.swift
//  books
//
//  Created by Andrew Bennet on 29/05/2016.
//  Copyright © 2016 Andrew Bennet. All rights reserved.
//

import UIKit

class SearchableFetchedResultsTable: FetchedResultsTable, UISearchResultsUpdating {
    /// The UISearchController to which this UITableViewController is connected.
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        self.definesPresentationContext = true
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.returnKeyType = .Done
        self.tableView.tableHeaderView = searchController.searchBar
        
        // Offset by the height of the search bar, so as to hide it on load.
        // However, the contentOffset values will change before the view appears,
        // due to the adjusted scroll view inset from the navigation bar.
        self.tableView.setContentOffset(CGPointMake(0, searchController.searchBar.frame.height), animated: false)
        
        super.viewDidLoad()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // We have to update the predicate even if the search text is empty, as the user
        // may have arrived at this state by deleting text from an existing search.
        if let searchText = searchController.searchBar.text {
            updatePredicateAndReloadTable(predicateForSearchText(searchText))
        }
    }
    
    func predicateForSearchText(searchText: String) -> NSPredicate {
        // Should be overriden
        return NSPredicate.FalsePredicate
    }
    
    func isShowingSearchResults() -> Bool {
        return searchController.active && searchController.searchBar.text?.isEmpty == false
    }
    
    func dismissSearch() {
        self.searchController.active = false
        self.searchController.searchBar.showsCancelButton = false
        self.updateSearchResultsForSearchController(self.searchController)
    }
}