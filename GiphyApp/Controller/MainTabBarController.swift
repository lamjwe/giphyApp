//
//  MainTabBarController.swift
//  GiphyApp
//
//  Created by Jonathan Lam on 2018-02-13.
//  Copyright © 2018 Jonathan Lam. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let feedViewController = FeedViewController()
        let feedNavigationController = UINavigationController(rootViewController: feedViewController)
        feedNavigationController.title = "Feed"
        feedNavigationController.tabBarItem.image = UIImage(named: "feed-icon")?.withRenderingMode(.alwaysTemplate)

        let favouritesViewController = FavouritesViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let favouritesNavigationController = UINavigationController(rootViewController: favouritesViewController)
        favouritesNavigationController.title = "Favourites"
        favouritesNavigationController.tabBarItem.image = UIImage(named: "like-icon")?.withRenderingMode(.alwaysTemplate)

        viewControllers = [feedNavigationController, favouritesNavigationController]

        tabBar.isTranslucent = false
        tabBar.tintColor = AppDelegate.NAVBARTINTCOLOR
        tabBar.clipsToBounds = true
    }
}
