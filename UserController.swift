
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
    let kUser = "userKey"
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
        guard let identifier = user.identifier else { completion(); return }
        FirebaseController.base.childByAppendingPath("users/\(identifier)/notes").observeEventType(.Value, withBlock: { (snapshot) -> Void in
            var notes: [Note] = []
            if let noteIDs = snapshot.value as? [String]{
                let group = dispatch_group_create()
                for noteID in noteIDs {
                    dispatch_group_enter(group)
                    NoteController.noteForID(noteID, completion: { (note) in
                        if let note = note {
                            notes.append(note)
                        }
                        dispatch_group_leave(group)
                    })
                }
                dispatch_group_notify(group, dispatch_get_main_queue(), { () -> Void in
                    user.notes = notes
                    completion()
                })
            } else {
                completion()
            }
        })
    }
    
    static func authenticateUser(email: String, password: String, completion: (success: Bool, user: User?) -> Void) {
        FirebaseController.base.authUser(email, password: password) { (error, authData) -> Void in
            if let error = error {
                print("Error authenticating user: \(error.localizedDescription)")
                completion(success: false, user: nil)
            } else {
                print("User authenticated successfully")
                UserController.fetchUserForID(authData.uid, completion: { (user) -> Void in
                    if let user = user {
                        currentUser = user
                    }
                    completion(success: true, user: user)
                })
            }
        }
    }
    
    static func createUser(email: String, password: String, completion: (success: Bool, user: User?) -> Void) {
        FirebaseController.base.createUser(email, password: password) { (error, response) -> Void in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                completion(success: false, user: nil)
            } else {
            if let uid = response["uid"] as? String {
                let user = User(email: email, indentifier: uid)
                FirebaseController.base.childByAppendingPath("users").childByAppendingPath(uid).setValue(user.jsonValue)
                authenticateUser(email, password: password, completion: { (success, user) -> Void in
                    if success {
                        completion(success: true, user: user)
                    } else {
                        completion(success: false, user: nil)
                    }
                })
                print("User created successfully")
            }
            }
        }
    }
    
    static func logoutUser() {
        FirebaseController.base.unauth()
    }
}