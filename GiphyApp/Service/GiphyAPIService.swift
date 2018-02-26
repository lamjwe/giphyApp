//
//  GiphyAPIService.swift
//  GiphyApp
//
//  Created by Jonathan Lam on 2018-02-14.
//  Copyright © 2018 Jonathan Lam. All rights reserved.
//

import UIKit
import Alamofire

// Limit for the number of GIFs to fetch each time
private let limit = 20

class GiphyAPIService: NSObject {
    //singleton
    static let sharedInstance = GiphyAPIService()

    // Fetch trending GIFs
    func getTrending(offset: Int? = 0, completion: @escaping ([GiphImage]?) -> ()) {
        fetchResult(url: "https://api.giphy.com/v1/gifs/trending?api_key=\(AppDelegate.GIPHY_API_KEY)&limit=\(limit)&offset=\(limit * offset!)&rating=\(AppDelegate.RATING)", completion: { (result:[GiphImage]?) in
            completion(result)
        })
    }

    // Fetch GIFs based on keyword
    func searchGIF(searchText: String, offset: Int? = 0, completion: @escaping ([GiphImage]?) -> ()) {
        let url = "https://api.giphy.com/v1/gifs/search?api_key=\(AppDelegate.GIPHY_API_KEY)&q=\(searchText)&limit=\(limit)&offset=\(limit * offset!)&rating=\(AppDelegate.RATING)&lang=en"
        fetchResult(url: url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!, completion: { (result:[GiphImage]?) in
            completion(result)
        })
    }

    private func fetchResult(url: String, completion: @escaping ([GiphImage]?) -> ()) {
        Alamofire.request(url).responseJSON { (responseData) in
            if responseData.result.value != nil {
                let results = responseData.result.value as? [String:Any]

                guard let data = results!["data"] as? [Any] else {
                    return
                }

                if data.count == 0 {
                    DispatchQueue.main.async(execute: {
                        completion([])
                    })
                }

                var resultGiphs:[GiphImage] = []
                for giph in data {
                    guard let giphData = giph as? [String:Any] else {
                        return
                    }

                    let title = giphData["title"] as! String
                    let id = giphData["id"] as! String
                    var fixedHeightUrl:String = ""
                    var originalUrl:String = ""

                    guard let images = giphData["images"] as? [String:Any] else {
                        return
                    }

                    if let fixedHeight = images["fixed_height_downsampled"] as? [String:Any] {
                        fixedHeightUrl = fixedHeight["url"] as! String
                    }

                    if let original = images["original"] as? [String:Any] {
                        originalUrl = original["url"] as! String
                    }

                    resultGiphs.append(GiphImage(title: title, id: id, downsizedUrl: fixedHeightUrl, originalUrl: originalUrl, originalImageData: nil, downsizedImageData: nil))

                    if resultGiphs.count == data.count {
                        DispatchQueue.main.async(execute: {
                            completion(resultGiphs)
                        })
                    }
                }
            } else {
                DispatchQueue.main.async(execute: {
                    completion([])
                })
            }
        }
    }
}
