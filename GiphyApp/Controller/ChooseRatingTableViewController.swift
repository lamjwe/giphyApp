//
//  ChooseRatingTableViewController.swift
//  GiphyApp
//
//  Created by Jonathan Lam on 2018-02-20.
//  Copyright © 2018 Jonathan Lam. All rights reserved.
//

import UIKit

class ChooseRatingTableViewController: UITableViewController {
    let cellId = "cellId"
    var ratings = ["Y", "G", "PG", "PG-13", "R"]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        navigationItem.title = "Select Rating"

        tableView?.estimatedRowHeight = 50
        tableView.allowsMultipleSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
    }

    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ratings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = ratings[indexPath.item]
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Save Rating
        AppDelegate.RATING = ratings[indexPath.item]
        dismiss(animated: true, completion: nil)
    }
}
