//
//  Note.swift
//  justype
//
//  Created by Gibson Smiley on 3/15/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

class Note: FirebaseType, Equatable {
    
    let kTitle = "title"
    let kText = "text"
    let kOwner = "ownerID"
    
    var title: String?
    var text: NSMutableAttributedString
    var tagIDs: [String] = []
    var ownerID: String?
    var identifier: String?
    var endpoint: String {
        return "notes"
    }
    var jsonValue: [String: AnyObject] {
        var json: [String: AnyObject] = [kText:NSAttributedString(attributedString: text)]
        if let textData = try? self.text.dataFromRange(NSMakeRange(0, text.length), documentAttributes: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType]) {
            let textDataString = textData.base64EncodedStringWithOptions(.EncodingEndLineWithLineFeed)
            json[kText] = textDataString
        }
        if let ownerID = ownerID {
            json[kOwner] = ownerID
            json[kTitle] = title
        }
        return json
    }
    
    init(title: String?, text: NSMutableAttributedString, ownerID: String) {
        self.text = text
        self.ownerID = ownerID
        self.title = title
    }
    
    required init?(json: [String: AnyObject], identifier: String) {
        guard let textDataString = json[kText] as? String,
            textData = NSData(base64EncodedString: textDataString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters),
            text = try? NSMutableAttributedString(data: textData, options: [NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType], documentAttributes: nil),
            let title = json[kTitle] as? String,
            let ownerID = json[kOwner] as? String else { return nil }
        self.title = title
        self.text = text
        self.identifier = identifier
        self.ownerID = ownerID
    }
}

func == (lhs: Note, rhs: Note) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

//extension NSMutableAttributedString {
//    var base64String: String? {
//        guard let data = __ {
//            return nil
//        }
//        return data.encode
//    }
//    
//    convenience init?(base64: String) {
//        if let textData = NSData(base64EncodedData: base64, options: .)
//    }
//}