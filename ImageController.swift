//
//  ImageController.swift
//  justype
//
//  Created by Gibson Smiley on 4/4/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import Foundation
import UIKit

class ImageController {
    
    static func uploadImage(image: UIImage, completion: (imageID: String?) -> Void) {
        if let base64Image = image.base64String {
            let base = FirebaseController.base.childByAppendingPath("images").childByAutoId()
            base.setValue(base64Image)
            completion(imageID: base.key)
        } else {
            completion(imageID: nil)
        }
    }
    static func imageForIdentifier(identifier: String, completion: (image: UIImage?) -> Void) {
        FirebaseController.dataAtEndpoint("images/\(identifier)") { (data) -> Void in
            if let data = data as? String {
                let image = UIImage(base64: data)
                completion(image: image)
            } else {
                completion(image: nil)
            }
        }
    }
}

extension UIImage {
    var base64String: String? {
        guard let data = UIImageJPEGRepresentation(self, 0.8) else { return nil }
        return data.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
    }
    convenience init?(base64: String) {
        if let imageData = NSData(base64EncodedString: base64, options: .IgnoreUnknownCharacters) {
            self.init(data: imageData)
        } else {
            return nil
        }
    }
}