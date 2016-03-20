
//
//  UserController.swift
//  justype
//
//  Created by Gibson Smiley on 3/15/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import Foundation

class UserController {
    
    static let sharedController = UserController()
    private let kUser = "userKey"
    static var notes: [Note] = []
    static var currentUser: User! {
        get {
        guard let uid = FirebaseController.base.authData?.uid, let userDictionary = NSUserDefaults.standardUserDefaults().valueForKey(sharedController.kUser) as? [String: AnyObject] else { return nil }
        return User(json: userDictionary, identifier: uid)
        }
        set {
            if let newValue = newValue {
                NSUserDefaults.standardUserDefaults().setValue(newValue.jsonValue, forKey: sharedController.kUser)
                NSUserDefaults.standardUserDefaults().synchronize()
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(sharedController.kUser)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }
    
    static func fetchUserForID(ID: String, completion:(user: User?) -> Void) {
        FirebaseController.dataAtEndpoint("users/\(ID)") { (data) -> Void in
            if let json = data as? [String: AnyObject] {
                let user = User(json: json, identifier: ID)
                completion(user: user)
            } else {
                completion(user: nil)
            }
        }
    }
    
    static func observeNotesForUser(user: User, completion: () -> Void) {
        guard let ID = user.identifier else { completion(); return }
        FirebaseController.base.childByAppendingPath("users/\(ID)/notes").observeEventType(.Value, withBlock: { (snapshot) -> Void in
            var notes: [Note] = []
            if let noteIDs = snapshot.value as? [String] {
                let thread = dispatch_group_create()
                for noteID in noteIDs {
                    dispatch_group_enter(thread)
                    NoteController.noteForID(noteID, completion: { (note) -> Void in
                        if let note = note {
                            notes.append(note)
                        }
                    })
                }
                dispatch_group_notify(thread, dispatch_get_main_queue(), { () -> Void in
                    completion()
                })
            } else {
                completion()
            }
        })
    }
    
    static func authenticateUser(email: String, password: String, completion: (success: Bool, user: User?) -> Void) {
        FirebaseController.base.authUser(email, password: password) { (error, authData) -> Void in
            if error != nil {
                UserController.fetchUserForID(authData.uid, completion: { (user) -> Void in
                    if let user = user {
                        currentUser = user
                    }
                    completion(success: true, user: user)
                })
            } else {
                print("Error authenticating user : \(error.localizedDescription)")
                completion(success: false, user: nil)
            }
        }
    }
    
    static func createUser(email: String, password: String, completion: (success: Bool, user: User?) -> Void) {
        FirebaseController.base.createUser(email, password: password) { (error, response) -> Void in
            if let uid = response["uid"] as? String {
                var user = User(email: email, indentifier: uid)
                user.save()
                
                authenticateUser(email, password: password, completion: { (success, user) -> Void in
                    completion(success: success, user: user)
                })
            } else {
                completion(success: false, user: nil)
            }
        }
    }
    
    static func logoutUser() {
        FirebaseController.base.unauth()
    }
}