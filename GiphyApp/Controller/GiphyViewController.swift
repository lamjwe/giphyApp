//
//  GiphyViewController.swift
//  GiphyApp
//
//  Created by Jonathan Lam on 2018-02-20.
//  Copyright © 2018 Jonathan Lam. All rights reserved.
//

import UIKit

private let popUpMessageWidth:CGFloat = 150
private let popUpMessageHeight:CGFloat = 60

class GiphyViewController: UIViewController {
    var giphImage: GiphImage?
    lazy var popUpMessage = ModalPopUp(frame: CGRect(x: self.view.bounds.midX - 75, y: self.view.bounds.midY - 30, width: popUpMessageWidth, height: popUpMessageHeight))
    var addedPopUpMessage = false

    convenience init(giphImage: GiphImage) {
        self.init()
        self.giphImage = giphImage
    }

    let giphImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "no_image")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.white
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if !addedPopUpMessage {
            addedPopUpMessage = true
            popUpMessage.modalTextView.text = "Loading..."
            self.view.addSubview(popUpMessage)
            popUpMessage.showAnimation()
        }

        self.view.backgroundColor = UIColor.white
        navigationItem.title = self.giphImage?.title ?? ""

        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 18)!, NSAttributedStringKey.foregroundColor: UIColor.white]

    }

    override func viewDidAppear(_ animated: Bool) {
        setupImageView()
    }

    func setupImageView() {
        if giphImage?.originalImageData != nil {
            giphImageView.image = UIImage.gifImageWithData((giphImage?.originalImageData!)!)
        } else {
            var url = ""
            if let originalUrl = giphImage?.originalUrl {
                url = originalUrl
            } else {
                url = (giphImage?.downsizedUrl)!
            }

            giphImageView.image = UIImage.gifImageWithURL(url)
        }

        self.view.addSubview(self.giphImageView)
        self.view.addConstrainstsWithFormat(format: "H:|-[v0]-|", views: self.giphImageView)
        self.view.addConstrainstsWithFormat(format: "V:|-[v0]-|", views: self.giphImageView)

        self.popUpMessage.removeAnimation()
        self.addedPopUpMessage = false
    }
}
