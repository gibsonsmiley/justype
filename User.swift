//
//  User.swift
//  justype
//
//  Created by Gibson Smiley on 3/15/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import Foundation

class User: FirebaseType, Equatable {
    
    let kEmail = "email"
    let kNotes = "notes"
    
    let email: String
    var noteIDs: [String] = [] {
        didSet {
            if self.identifier == UserController.currentUser.identifier {
                NSUserDefaults.standardUserDefaults().setValue(jsonValue, forKey: UserController.sharedController.kUser)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    var notes: [Note] = []

    var identifier: String?
    var endpoint: String {
        return "users"
    }
    var jsonValue: [String: AnyObject] {
        return [kEmail: email, kNotes: noteIDs/*, kTags: tagIDs*/]
    }
    
    init(email: String, indentifier: String?) {
        self.email = email
    }
    
    required init?(json: [String : AnyObject], identifier: String) {
        guard let email = json[kEmail] as? String else { return nil }
        self.email = email
        self.identifier = identifier
        if let noteIDs = json[kNotes] as? [String] {
            self.noteIDs = noteIDs
        }
    }
}

func == (lhs: User, rhs: User) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}