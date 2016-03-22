//
//  Note.swift
//  justype
//
//  Created by Gibson Smiley on 3/15/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import Foundation

class Note: FirebaseType, Equatable {
    
    let kText = "text"
    let kOwner = "ownerID"
    
    var text: String
    var tagIDs: [String] = []
    var ownerID: String?
    var identifier: String?
    var endpoint: String {
        return "notes"
    }
    var jsonValue: [String: AnyObject] {
        return [kText: text, kOwner: ownerID!]
    }
    
    init(text: String, ownerID: String) {
        self.text = text
        self.ownerID = ownerID
    }
    
    required init?(json: [String: AnyObject], identifier: String) {
        guard let text = json[kText] as? String else { self.text = ""; self.ownerID = ""; return nil }
        self.text = text
        self.identifier = identifier
    }
}

func == (lhs: Note, rhs: Note) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}