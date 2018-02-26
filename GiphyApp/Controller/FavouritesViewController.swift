//
//  FavouritesViewController.swift
//  GiphyApp
//
//  Created by Jonathan Lam on 2018-02-13.
//  Copyright © 2018 Jonathan Lam. All rights reserved.
//

import UIKit

private let popUpMessageWidth:CGFloat = 200
private let popUpMessageHeight:CGFloat = 150

class FavouritesViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    // To store all favourited GIFs in Core Data
    var favouriteGIPHY = [GiphImage]()
    let cellId = "favCellId"

    var finishedFetching = false

    // For displaying messages to user
    lazy var popUpMessage = ModalPopUp(frame: CGRect(x: self.view.bounds.midX - 100, y: self.view.bounds.midY - 100, width: popUpMessageWidth, height: popUpMessageHeight))
    var addedPopUpMessage = false

    // Retrieving all stored GIFs in Core Data
    @objc func getFavourites() {
        GiphyCoreDataHandler.sharedInstance.fetchFavouriteGIPHYs(completion: { (giphs:[GiphImage]?) in
            if giphs != nil {
                self.favouriteGIPHY = giphs!
                self.favouriteGIPHY.sort { $0.title < $1.title }
                self.collectionView?.reloadData()
            }
            self.finishedFetching = true
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        self.addedPopUpMessage = false
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 24)!, NSAttributedStringKey.foregroundColor: UIColor.white]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(getFavourites), name: Notification.Name("addFavourites"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getFavourites), name: Notification.Name("removedFromFavourites"), object: nil)
        getFavourites()
        self.collectionView?.backgroundColor = UIColor.white
        navigationItem.title = "Favourites"

        collectionView?.register(FavouriteCollectionCell.self, forCellWithReuseIdentifier: cellId)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.favouriteGIPHY.count == 0 {
            let emptyTableLabel = UILabel(frame: CGRect(x: 0, y: 0, width: (self.collectionView?.bounds.width)!, height: (self.collectionView?.bounds.height)!))
            emptyTableLabel.textColor = UIColor.lightGray
            if self.finishedFetching {
                emptyTableLabel.text = "No GIPHYS in Favourites."
            } else {
                emptyTableLabel.text = "Loading..."
            }
            emptyTableLabel.textAlignment = .center
            emptyTableLabel.numberOfLines = 2

            self.collectionView?.backgroundView = emptyTableLabel
        } else {
            self.collectionView?.backgroundView = nil
        }
        return favouriteGIPHY.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FavouriteCollectionCell
        cell.giphImage = favouriteGIPHY[indexPath.item]
        cell.delegate = self
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let giphyViewController = GiphyViewController(giphImage: self.favouriteGIPHY[indexPath.item])
        giphyViewController.hidesBottomBarWhenPushed = true

        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.pushViewController(giphyViewController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 16 - 16)/2.0
        let height:CGFloat = 160.0

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10,10,10,10)
    }

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

extension FavouritesViewController: FavouriteCollectionCellDelegate {
    func handleDelete(cell: FavouriteCollectionCell) {
        print("Delete Button Clicked")
        GiphyCoreDataHandler.sharedInstance.deleteGIPHYFromFavourite(id: (cell.giphImage?.id)!, completion: { (success:Bool) in
            if success {
                self.showPopUpMessage(message: "Removed From Favourites")
                NotificationCenter.default.post(name: Notification.Name("removedFromFavourites"), object: cell.giphImage)
            } else {
                self.showPopUpMessage(message: "Failed to Remove From Favourites")
            }
        })

        self.favouriteGIPHY = self.favouriteGIPHY.filter( {$0.id != cell.giphImage?.id} )
        if let indexPath = collectionView?.indexPath(for: cell) {
            self.collectionView?.deleteItems(at: [indexPath])
        }
    }
}
