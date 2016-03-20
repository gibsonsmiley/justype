//
//  Tag.swift
//  justype
//
//  Created by Gibson Smiley on 3/15/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import Foundation

class Tag: FirebaseType {
    
    let kTitle = "title"
    let kNotes = "notes"
    
    var title: String
    var noteIDs: [String] = []
    var notes: [Note] = []
    var identifier: String?
    var endpoint: String {
        return "tags"
    }
    var jsonValue: [String: AnyObject] {
        return [kTitle: title, kNotes: noteIDs]
    }
    
    init(title: String, identifier: String? = nil) {
        self.title = title
    }
    
    required init?(json: [String: AnyObject], identifier: String) {
        guard let title = json[kTitle] as? String else { self.title = ""; return nil }
        self.title = title
        self.identifier = identifier
    }
}

func == (lhs: Tag, rhs: Tag) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}