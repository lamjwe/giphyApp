//
//  FeedViewController.swift
//  GiphyApp
//
//  Created by Jonathan Lam on 2018-02-13.
//  Copyright © 2018 Jonathan Lam. All rights reserved.
//

import UIKit

private let searchBarHeight = 50
private let popUpMessageWidth:CGFloat = 200
private let popUpMessageHeight:CGFloat = 150

class FeedViewController: UITableViewController, UIGestureRecognizerDelegate {
    let cellId = "cellId"

    // Default trending GIFs
    var giphys = [GiphImage]()
    // Search results GIFs
    var searchedGiphys = [GiphImage]()
    // All IDs of GIFs in favourite. Need this to determine whether to show "Add" or "Remove" from Favourite icon
    var favouriteIds = Set<String>()

    var finishedFetching = false
    var finishedFetchingFavIds = false
    var finishedFetchingTrending = false
    var isSearching = false

    // Offsets for pagination
    var trendingOffSet = 1
    var searchedOffSet = 1

    let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: searchBarHeight))

    // For displaying messages to user
    lazy var popUpMessage = ModalPopUp(frame: CGRect(x: self.view.bounds.midX - 100, y: self.view.bounds.midY - 100, width: popUpMessageWidth, height: popUpMessageHeight))
    var addedPopUpMessage = false

    var tapToDismissKeyboard:UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(handleTapToDismissKeyboard))
    }()

    // Fetch default trending GIFs
    func getTrending() {
        GiphyAPIService.sharedInstance.getTrending(completion: { (giphs:[GiphImage]?) in
            self.giphys = giphs!
            self.tableView.reloadData()
            self.finishedFetchingTrending = true

            if self.finishedFetchingTrending && self.finishedFetchingFavIds {
                self.finishedFetching = true
            }
        })
    }

    // Fetch IDs of all GIFs in Core Data
    func getFavouritesIds() {
        GiphyCoreDataHandler.sharedInstance.fetchFavouriteGIPHYIDs(completion: { (results) in
            self.favouriteIds = Set(results!)
            self.finishedFetchingFavIds = true

            if self.finishedFetchingTrending && self.finishedFetchingFavIds {
                self.finishedFetching = true
            }
        })
    }

    @objc func handleRatingButtonClicked() {
        let chooseRatingTableViewController = ChooseRatingTableViewController()
        let navController = UINavigationController(rootViewController: chooseRatingTableViewController)
        present(navController, animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.addedPopUpMessage = false
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 24)!, NSAttributedStringKey.foregroundColor: UIColor.white]

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppDelegate.RATING, style: .plain, target: self, action: #selector(handleRatingButtonClicked))
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        getFavouritesIds()
        getTrending()
        navigationItem.title = "Feed"

        setupSearchBar()

        tapToDismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(handleTapToDismissKeyboard))
        tapToDismissKeyboard.delegate = self
        tableView.register(FeedTableCell.self, forCellReuseIdentifier: cellId)
    
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: Notification.Name("removedFromFavourites"), object: nil)
    }

    func setupSearchBar() {
        searchBar.placeholder = "Search GIFs"
        searchBar.delegate = self
    }

    @objc func handleTapToDismissKeyboard() {
        self.view.endEditing(true)
        self.view.removeGestureRecognizer(tapToDismissKeyboard)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let emptyTableLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height))
        emptyTableLabel.textColor = UIColor.lightGray
        emptyTableLabel.textAlignment = .center
        emptyTableLabel.numberOfLines = 2

        if isSearching {
            if self.searchedGiphys.count == 0 {
                emptyTableLabel.text = "Cannot find any GIPHYS."
                self.tableView.backgroundView = emptyTableLabel
                self.tableView.separatorStyle = .none
            } else {
                self.tableView.backgroundView = nil
                self.tableView.separatorStyle = .singleLine
            }
            return searchedGiphys.count
        }

        if self.giphys.count == 0 {
            if self.finishedFetching {
                emptyTableLabel.text = "Cannot find any GIPHYS."
            } else {
                emptyTableLabel.text = "Loading..."
            }

            self.tableView.backgroundView = emptyTableLabel
            self.tableView.separatorStyle = .none
        } else {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
        }

        return self.giphys.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! FeedTableCell

        if isSearching {
            cell.giphImage = self.searchedGiphys[indexPath.item]
        } else {
            cell.giphImage = self.giphys[indexPath.item]
        }

        // Display "Remove from Favourite" icon if GIF already in Favourites. Vice Versa
        if favouriteIds.contains((cell.giphImage?.id)!) {
            cell.addRemoveFavouritesButton.setImage(UIImage(named: "dislike-icon"), for: UIControlState.normal)
        } else {
            cell.addRemoveFavouritesButton.setImage(UIImage(named: "like-icon"), for: UIControlState.normal)
        }

        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var giphImage:GiphImage?
        if isSearching {
            giphImage = self.searchedGiphys[indexPath.item]
        } else {
            giphImage = self.giphys[indexPath.item]
        }

        let giphyViewController = GiphyViewController(giphImage: giphImage!)
        giphyViewController.hidesBottomBarWhenPushed = true

        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.pushViewController(giphyViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 270
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(searchBarHeight)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var totalRows = 0
        if isSearching {
            totalRows = searchedGiphys.count
        } else {
            totalRows = giphys.count
        }

        if !(indexPath.row + 1 < totalRows) {
            if isSearching {
                searchedOffSet = searchedOffSet + 1
                GiphyAPIService.sharedInstance.searchGIF(searchText: searchBar.text!, offset: searchedOffSet) { (results) in
                    self.isSearching = true
                    self.searchedGiphys.append(contentsOf: results!)
                    self.tableView.reloadData()
                }
            } else {
                trendingOffSet = trendingOffSet + 1
                GiphyAPIService.sharedInstance.getTrending(offset: trendingOffSet, completion: { (giphs:[GiphImage]?) in
                    self.giphys.append(contentsOf: giphs!)
                    self.tableView.reloadData()
                })
            }
        }
    }

    @objc func reloadTableView(_ notification: NSNotification) {
        let sender = notification.object
        // We only want to process notifications when sent by the object of type GiphImage
        guard (sender as? GiphImage) != nil else {
            return
        }
        let giphImage = sender as? GiphImage
        favouriteIds.remove((giphImage?.id)!)
        self.tableView.reloadData()
    }
}

extension FeedViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.view.addGestureRecognizer(tapToDismissKeyboard)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = searchBar.text != "" ? true : false
        self.view.addGestureRecognizer(tapToDismissKeyboard)
        self.tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !addedPopUpMessage {
            addedPopUpMessage = true
            searchedOffSet = 1
            popUpMessage.frame = CGRect(x: self.view.bounds.midX - 100, y: self.view.bounds.midY - 100, width: popUpMessageWidth, height: popUpMessageHeight)
            popUpMessage.modalTextView.text = "Searching..."
            self.view.addSubview(popUpMessage)
            popUpMessage.showAnimation()

            GiphyAPIService.sharedInstance.searchGIF(searchText: searchBar.text!) { (results) in
                self.isSearching = true
                self.searchedGiphys = results!
                self.tableView.reloadData()
                self.tableView.contentOffset = .zero
                self.popUpMessage.removeAnimation()
                self.addedPopUpMessage = false
            }
            self.view.endEditing(true)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.view.addGestureRecognizer(tapToDismissKeyboard)
    }

    // Helper function to show pop up messages to user
    func showPopUpMessage(message:String) {
        if !addedPopUpMessage {
            addedPopUpMessage = true
            
            popUpMessage.frame = CGRect(x: self.view.bounds.midX - 100, y: self.view.bounds.midY - 100, width: popUpMessageWidth, height: popUpMessageHeight)
            popUpMessage.modalTextView.text = message
            self.view.addSubview(popUpMessage)
            popUpMessage.showAnimationAndRemove(completion: { (completed) in
                if completed {
                    self.addedPopUpMessage = false
                }
            })
        }
    }
}

extension FeedViewController: FeedTableCellDelegate {
    func removeFromFavourites(cell: FeedTableCell) {
        GiphyCoreDataHandler.sharedInstance.deleteGIPHYFromFavourite(id: (cell.giphImage?.id)!, completion: { (success:Bool) in
            if success {
                self.showPopUpMessage(message: "Removed From Favourites")
                NotificationCenter.default.post(name: Notification.Name("removedFromFavourites"), object: cell.giphImage)
                cell.addRemoveFavouritesButton.setImage(UIImage(named: "like-icon"), for: UIControlState.normal)
                self.favouriteIds.remove((cell.giphImage?.id)!)
            } else {
                self.showPopUpMessage(message: "Failed to Remove From Favourites")
            }
        })
    }

    func addToFavourites(cell: FeedTableCell) {
        self.showPopUpMessage(message: "Adding To Favourites")
        GiphyCoreDataHandler.sharedInstance.fetchFavouriteGIPHYs(id: cell.giphImage?.id, completion: { (giphs:[GiphImage]?) in
            if let results = giphs {
                if results.count > 0 {
                    print("GIPH already in Core Data")
                    return
                } else {
                    if GiphyCoreDataHandler.sharedInstance.saveGIPHYToFavourite(giphy: cell.giphImage!) {
                        NotificationCenter.default.post(name: Notification.Name("addFavourites"), object: cell.giphImage)
                        cell.addRemoveFavouritesButton.setImage(UIImage(named: "dislike-icon"), for: UIControlState.normal)
                        self.favouriteIds.insert((cell.giphImage?.id)!)
                    } else {
                        self.showPopUpMessage(message: "Opps Something Went Wrong...")
                    }
                }
            }
        })
    }
}
