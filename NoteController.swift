//
//  NoteController.swift
//  justype
//
//  Created by Gibson Smiley on 3/15/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import Foundation

class NoteController {
    
    static func createNote(title: String?, text: NSMutableAttributedString, ownerID: String = UserController.currentUser.identifier!, completion: (note: Note?) -> Void) {
        var note = Note(title: title, text: text, ownerID: ownerID)
        note.ownerID = ownerID
        note.save()
        if let identifier = note.identifier {
            UserController.currentUser.noteIDs.append(identifier)
            UserController.currentUser.save()
        }
        completion(note: note)
    }
    
    static func updateNote(note: Note, completion: (success: Bool, note: Note?) -> Void) {
        FirebaseController.base.childByAppendingPath("notes").childByAppendingPath(note.identifier).updateChildValues(note.jsonValue)
        completion(success: true, note: note)
    }
    
    static func deleteNote(note: Note) {
        note.delete()
        removeNoteFromUser(note, user: UserController.currentUser)
    }
    
    static func removeNoteFromUser(note: Note, user: User) {
        guard let noteID = note.identifier else {return}
        var user = user
        user.noteIDs = user.noteIDs.filter({$0 != noteID})
        UserController.currentUser = user
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
        return notes.sort({$0.0.identifier > $0.1.identifier})
    }
}