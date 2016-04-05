//
//  NoteController.swift
//  justype
//
//  Created by Gibson Smiley on 3/15/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import Foundation
import UIKit

class NoteController {
    
    static func createNote(title: String?, text: NSMutableAttributedString, timestamp: NSDate = NSDate(), image: UIImage?, ownerID: String = UserController.sharedController.currentUser.identifier!, completion: (note: Note?) -> Void) {
        if let image = image {
            ImageController.uploadImage(image, completion: { (imageID) in
                if let imageID = imageID {
                    var note = Note(title: title, text: text, timestamp: timestamp, imageEndpoint: imageID, ownerID: ownerID)
                    note.ownerID = ownerID
                    note.save()
                    if let identifier = note.identifier {
                        UserController.sharedController.currentUser.noteIDs.append(identifier)
                        UserController.sharedController.currentUser.save()
                    }
                    completion(note: note)
                }
            })
        }
        var note = Note(title: title, text: text, timestamp: timestamp, imageEndpoint: nil, ownerID: ownerID)
        note.ownerID = ownerID
        note.save()
        if let identifier = note.identifier {
            UserController.sharedController.currentUser.noteIDs.append(identifier)
            UserController.sharedController.currentUser.save()
        }
        completion(note: note)
    }
    
    static func updateNote(note: Note, completion: (success: Bool, note: Note?) -> Void) {
        note.timestamp = NSDate()
        var note = note
        note.save()
//        FirebaseController.base.childByAppendingPath("notes").childByAppendingPath(note.identifier).updateChildValues(note.jsonValue)
        completion(success: true, note: note)
    }
    
    static func deleteNote(note: Note) {
        note.delete()
        removeNoteFromUser(note, user: UserController.sharedController.currentUser)
    }
    
    static func removeNoteFromUser(note: Note, user: User) {
        guard let noteID = note.identifier else {return}
        var user = user
        user.noteIDs = user.noteIDs.filter({$0 != noteID})
        UserController.sharedController.currentUser = user
        user.save()
    }
    
    static func noteForID(noteID: String, completion: (note: Note?) -> Void) {
        FirebaseController.dataAtEndpoint("notes/\(noteID)") { (data) -> Void in
            if let data = data as? [String:AnyObject] {
                let note = Note(json: data, identifier: noteID)
                completion(note: note)
            } else {
                completion(note: nil)
            }
        }
    }
    
    static func observeNote(note: Note, completion: () -> Void) {
        guard let noteID = note.identifier else {return}
        FirebaseController.base.childByAppendingPath("notes/\(noteID)").removeAllObservers()
        FirebaseController.observeDataAtEndpoint("notes/\(noteID)") { (data) -> Void in
            if let data = data as? [String:AnyObject] {
                var note = note
                if let newNote = Note(json: data, identifier: noteID) {
                    note = newNote
                }
                completion()
            } else {
                completion()
            }
        }
    }
    
    static func orderNotes(notes: [Note]) -> [Note] {
        return notes.sort({$0.0.timestamp.hashValue > $0.1.timestamp.hashValue})
    }
}