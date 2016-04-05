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
    let kImageEndpoint = "image"
    
    var title: String?
    var text: NSMutableAttributedString
    var timestamp: NSDate
    var imageEndpoint: String?
    var tagIDs: [String] = []
    var ownerID: String?
    var identifier: String?
    var endpoint: String {
        return "notes"
    }
    var jsonValue: [String: AnyObject] {
        var json: [String: AnyObject] = [kText: NSAttributedString(attributedString: text)]
        if let textData = try? self.text.dataFromRange(NSMakeRange(0, text.length), documentAttributes: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType]) {
            let textDataString = textData.base64EncodedStringWithOptions(.EncodingEndLineWithLineFeed)
            json[kText] = textDataString
        }
        
        if let ownerID = ownerID {
            json[kOwner] = ownerID
            json[kTitle] = title
            json[kTimestamp] = timestamp.timeIntervalSince1970
            json[kImageEndpoint] = imageEndpoint
        }
        return json
    }
    
    init(title: String?, text: NSMutableAttributedString, timestamp: NSDate = NSDate(), imageEndpoint: String?, ownerID: String) {
        self.text = text
        self.ownerID = ownerID
        self.title = title
        self.imageEndpoint = imageEndpoint
        self.timestamp = timestamp
    }
    
    required init?(json: [String: AnyObject], identifier: String) {
        guard let textDataString = json[kText] as? String,
            textData = NSData(base64EncodedString: textDataString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters),
            text = try? NSMutableAttributedString(data: textData, options: [NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType], documentAttributes: nil),
            let title = json[kTitle] as? String,
//            let imageEndpoint = json[kImageEndpoint] as? String,
            let timestamp = json[kTimestamp] as? NSTimeInterval,
            let ownerID = json[kOwner] as? String else { return nil }
        self.title = title
        self.text = text
        self.imageEndpoint = json[kImageEndpoint] as? String ?? ""
        self.timestamp = NSDate(timeIntervalSince1970: timestamp)
        self.identifier = identifier
        self.ownerID = ownerID
    }
}

func == (lhs: Note, rhs: Note) -> Bool {
    return lhs.identifier == rhs.identifier
}
