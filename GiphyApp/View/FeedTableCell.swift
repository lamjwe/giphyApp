//
//  FeedTableCell.swift
//  GiphyApp
//
//  Created by Jonathan Lam on 2018-02-14.
//  Copyright © 2018 Jonathan Lam. All rights reserved.
//

import UIKit

protocol FeedTableCellDelegate: class {
    func addToFavourites(cell: FeedTableCell)
    func removeFromFavourites(cell: FeedTableCell)
}

class FeedTableCell: UITableViewCell {
    weak var delegate: FeedTableCellDelegate?

    public var giphImage: GiphImage? {
        didSet {
            guard let downsizedUrl = giphImage?.downsizedUrl else {
                return
            }

            if let title = giphImage?.title {
                titleLabel.text = title
            }

            thumbnailImageView.image = UIImage.gifImageWithURL(downsizedUrl)
        }
    }

    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "no_image")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(displayP3Red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "-"
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    var titleLabelHeightConstraint: NSLayoutConstraint?

    lazy var addRemoveFavouritesButton: UIButton = {
        let buttonYPos = self.frame.height - 48
        let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 32, y: buttonYPos, width: 25, height: 25))
        button.setImage(UIImage(named: "like-icon"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(handleAddRemoveFavouritesButtonClicked), for: UIControlEvents.touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }()

    @objc func handleAddRemoveFavouritesButtonClicked() {
        if addRemoveFavouritesButton.imageView?.image == UIImage(named: "like-icon") {
            delegate?.addToFavourites(cell: self)
        } else {
            delegate?.removeFromFavourites(cell: self)
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(thumbnailImageView)
        addSubview(titleLabel)
        addSubview(addRemoveFavouritesButton)
        addSubview(seperatorView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        thumbnailImageView.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        titleLabel.anchor(thumbnailImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: addRemoveFavouritesButton.leftAnchor, topConstant: 8, leftConstant: 16, bottomConstant: 16, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        // height constraints
        titleLabelHeightConstraint = NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 40)
        addConstraint(titleLabelHeightConstraint!)

        addRemoveFavouritesButton.anchor(titleLabel.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 8, widthConstant: 25, heightConstant: 25)

        seperatorView.anchor(titleLabel.bottomAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 16)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
