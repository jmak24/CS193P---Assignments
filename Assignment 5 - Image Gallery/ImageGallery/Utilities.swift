//
//  Utilities.swift
//  ImageGallery
//
//  Created by Jon Mak on 2019-01-29.
//  Copyright © 2019 Jon Mak. All rights reserved.
//

import UIKit

class ImageFetcher {
    
    func fetchImage(with url: NSURL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let imageURL = (url as URL).imageURL
            let urlContents = try? Data(contentsOf: imageURL)
            if let imageData = urlContents, let image = UIImage(data: imageData) {
                self?.handler(image)
            }
        }
    }
    
    init(fetch url: NSURL, handler: @escaping (UIImage) -> Void) {
        self.handler = handler
        fetchImage(with: url)
    }
    
    private let handler: (UIImage) -> Void
}


extension URL {
    var imageURL: URL {
        // check to see if there is an embedded imgurl reference
        for query in query?.components(separatedBy: "&") ?? [] {
            let queryComponents = query.components(separatedBy: "=")
            if queryComponents.count == 2 {
                if queryComponents[0] == "imgurl", let url = URL(string: queryComponents[1].removingPercentEncoding ?? "") {
                    return url
                }
            }
        }
        return self.baseURL ?? self
    }
}

extension String {
    func madeUnique(withRespectTo otherStrings: [String]) -> String {
        var possiblyUnique = self
        var uniqueNumber = 1
        while otherStrings.contains(possiblyUnique) {
            possiblyUnique = self + " \(uniqueNumber)"
            uniqueNumber += 1
        }
        return possiblyUnique
    }
}


