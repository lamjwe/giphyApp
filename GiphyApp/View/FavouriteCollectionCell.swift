//
//  FavouriteCollectionCell.swift
//  GiphyApp
//
//  Created by Jonathan Lam on 2018-02-14.
//  Copyright © 2018 Jonathan Lam. All rights reserved.
//

import UIKit

protocol FavouriteCollectionCellDelegate: class {
    func handleDelete(cell: FavouriteCollectionCell)
}

class FavouriteCollectionCell: UICollectionViewCell {
    weak var delegate: FavouriteCollectionCellDelegate?
    public var giphImage: GiphImage? {
        didSet {
            guard let downsizedUrl = giphImage?.downsizedUrl else {
                return
            }

            guard let title = giphImage?.title else {
                return
            }

            titleLabel.text = title

            if giphImage?.downsizedImageData != nil {
                thumbnailImageView.image = UIImage.gifImageWithData((giphImage?.downsizedImageData!)!)
            } else {
                thumbnailImageView.image = UIImage.gifImageWithURL(downsizedUrl)
            }
        }
    }

    let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "no_image")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "-"
        label.numberOfLines = 2
        return label
    }()

    var titleLabelHeightConstraint: NSLayoutConstraint?

    let optionCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let options = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return options
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    func setupViews() {
        self.contentView.layer.borderWidth = 1.0

        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true

        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.contentView.layer.cornerRadius).cgPath
        self.contentView.backgroundColor = UIColor.white

        addSubview(thumbnailImageView)
        addSubview(titleLabel)

        let deleteButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 32, y: 241, width: 25, height: 25))
        deleteButton.setImage(UIImage(named: "dislike-icon"), for: UIControlState.normal)
        deleteButton.addTarget(self, action: #selector(handleDeleteButtonClicked), for: UIControlEvents.touchUpInside)
        deleteButton.isUserInteractionEnabled = true
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(deleteButton)
        bringSubview(toFront: deleteButton)

        addConstrainstsWithFormat(format: "H:|[v0]|", views: thumbnailImageView)
        addConstraint(NSLayoutConstraint(item: thumbnailImageView, attribute: .height, relatedBy: .equal, toItem: thumbnailImageView.self, attribute: .height, multiplier: 0, constant: 100))

        // top constraints
        addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: thumbnailImageView, attribute: .bottom, multiplier: 1, constant: 8))

        // left and right constraints
        addConstrainstsWithFormat(format: "H:|-4-[v0]-4-|", views: titleLabel)

        // height constraints
        titleLabelHeightConstraint = NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 44)
        addConstraint(titleLabelHeightConstraint!)

        deleteButton.anchor(self.contentView.topAnchor, left: nil, bottom: nil, right: self.contentView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 6, rightConstant: 0, widthConstant: 25, heightConstant: 25)
    }

    @objc func handleDeleteButtonClicked() {
        delegate?.handleDelete(cell: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
