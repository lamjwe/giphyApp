//
//  ModalPopUp.swift
//  GiphyApp
//
//  Created by Jonathan Lam on 2018-02-20.
//  Copyright © 2018 Jonathan Lam. All rights reserved.
//

import UIKit

class ModalPopUp: UIView {

    let modalTextView: UITextView = {
        let tv = UITextView()
        tv.text = ""
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = ""
        tv.font = UIFont(name: "Avenir-Black", size: 20)
        tv.textColor = UIColor.white
        tv.backgroundColor = UIColor.clear
        tv.textAlignment = .center
        tv.isEditable = false
        tv.isSelectable = false
        return tv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupComponents()
        self.alpha = 0.0
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }

    func setupComponents() {
        self.backgroundColor = UIColor.clear.withAlphaComponent(0.4)
        self.clipsToBounds = true
        self.addSubview(modalTextView)

        modalTextView.anchor(self.centerYAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: -50, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 0)
    }

    func showAnimation() {
        self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.alpha = 0.0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1.0
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }

    func removeAnimation() {
        UIView.animate(withDuration: 0.25, delay: 0.25, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.alpha = 0.0
        }) { (finished) in
            if finished {
                self.removeFromSuperview()
            }
        }
    }

    func showAnimationAndRemove(completion: @escaping (Bool) -> ()) {
        self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 1.0
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }) { (finished) in
            if finished {
                UIView.animate(withDuration: 0.25, delay: 1.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    self.alpha = 0.0
                }, completion: { (finished) in
                    if finished {
                        self.removeFromSuperview()
                        completion(true)
                    } else {
                        completion(false)
                    }
                })
            }
        }
    }
}
