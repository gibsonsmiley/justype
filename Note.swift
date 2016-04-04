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
    let kTimestamp = "timestamp"
    let kOwner = "ownerID"
    
    var title: String?
    var text: NSMutableAttributedString
//    var timestamp: NSDate
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
    
    init(title: String?, text: NSMutableAttributedString, /*timestamp: NSDate = NSDate(),*/ ownerID: String) {
        self.text = text
        self.ownerID = ownerID
        self.title = title
//        self.timestamp = timestamp
    }
    
    required init?(json: [String: AnyObject], identifier: String) {
        guard let textDataString = json[kText] as? String,
            textData = NSData(base64EncodedString: textDataString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters),
            text = try? NSMutableAttributedString(data: textData, options: [NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType], documentAttributes: nil),
            let title = json[kTitle] as? String,
            /*let timestamp = json[kTimestamp] as? NSDate,*/
            let ownerID = json[kOwner] as? String else { return nil }
        self.title = title
        self.text = text
//        self.timestamp = timestamp
        self.identifier = identifier
        self.ownerID = ownerID
    }
}

func == (lhs: Note, rhs: Note) -> Bool {
    return lhs.identifier == rhs.identifier
}
