//
//  Document.swift
//  Persistant Image Gallery
//
//  Created by Jon Mak on 2019-02-09.
//  Copyright © 2019 Jon Mak. All rights reserved.
//

import UIKit

class ImageGalleryDocument: UIDocument {
    
    var imageGallery: ImageGallery?
    var thumbnail: UIImage?
    
    override func contents(forType typeName: String) throws -> Any {
        return imageGallery?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let json = contents as? Data {
            imageGallery = ImageGallery(json: json)
        }
    }
    
    override func fileAttributesToWrite(to url: URL, for saveOperation: UIDocument.SaveOperation) throws -> [AnyHashable : Any] {
        var attributes = try super.fileAttributesToWrite(to: url, for: saveOperation)
        if let thumbnail = self.thumbnail {
            attributes[URLResourceKey.thumbnailDictionaryKey] =
                [URLThumbnailDictionaryItem.NSThumbnail1024x1024SizeKey:thumbnail]
        }
        return attributes
    }
}

