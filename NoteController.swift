//
//  NoteController.swift
//  justype
//
//  Created by Gibson Smiley on 3/15/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import Foundation

class NoteController {
    
    static func createNote(text: String, ownerID: String = UserController.currentUser.identifier!, completion: (note: Note?) -> Void) {
        var note = Note(text: text, ownerID: ownerID)
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
    
    static func orderNotes(notes: [Note]) -> [Note] {
        return notes.sort({$0.0.identifier < $0.1.identifier})
    }
}