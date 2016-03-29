//
//  Note.swift
//  justype
//
//  Created by Gibson Smiley on 3/15/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

class Note: FirebaseType, Equatable {
    
    let kText = "text"
    let kOwner = "ownerID"
    
    var text: NSMutableAttributedString
    var tagIDs: [String] = []
    var ownerID: String?
    var identifier: String?
    var endpoint: String {
        return "notes"
    }
    var jsonValue: [String: AnyObject] {
        var json: [String: AnyObject] = [:]
        if let textData = try? self.text.dataFromRange(NSMakeRange(0, text.length), documentAttributes: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType]) {
            json[kText] = textData
        }
        if let ownerID = ownerID {
            json[kOwner] = ownerID
        }
        return json
    }
    
    init(text: NSMutableAttributedString, ownerID: String) {
        self.text = text
        self.ownerID = ownerID
    }
    
    required init?(json: [String: AnyObject], identifier: String) {
        guard let textData = json[kText] as? NSData,
            text = try? NSMutableAttributedString(data: textData, options: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType], documentAttributes: nil),
            let ownerID = json[kOwner] as? String else { return nil }
        self.text = text
        self.identifier = identifier
        self.ownerID = ownerID
    }
}

func == (lhs: Note, rhs: Note) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}