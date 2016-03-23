//
//  NoteController.swift
//  justype
//
//  Created by Gibson Smiley on 3/15/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import Foundation

class NoteController {
    
//    static var notes: [Note] = []
    
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
    
    static func deleteNote(note: Note) {
        note.delete()
    }
    
//    static func observeNotesForUser(user: User, completion: () -> Void) {
//        guard let identifier = user.identifier else {completion(); return}
//        FirebaseController.base.childByAppendingPath("notes").queryOrderedByChild("users").queryEqualToValue("\(identifier)").observeEventType(.Value, withBlock: { (snapshot) -> Void in
//            if let noteDictionaries = snapshot.value as? [String: AnyObject] {
//                let notes = noteDictionaries.flatMap({Note(json: $0.1 as! [String: AnyObject], identifier: $0.0)})
//                self.notes = notes
//                completion()
//            }
//        })
//    }
    
    static func noteForID(noteID: String, completion: (note: Note?) -> Void) {
        FirebaseController.dataAtEndpoint("notes/\(noteID)") { (data) -> Void in
            if let data = data as? [String:AnyObject] {
                let note = Note(json: data, identifier: noteID)
                completion(note: note)
            } else {
                completion(note: nil)
            }
        }
        
//        guard let identifier = note.identifier else { completion(note: nil); return }
//        FirebaseController.dataAtEndpoint("users/\(UserController.currentUser?.identifier)/notes/\(identifier)") { (data) -> Void in
//            if let data = data as? [String: AnyObject] {
//                let note = Note(json: data, identifier: identifier)
//                completion(note: note)
//            } else {
//                completion(note: nil)
//            }
//        }
    }
    
    static func orderNotes(notes: [Note]) -> [Note] {
        return notes.sort({$0.0.identifier < $0.1.identifier})
    }
    
    static func addTag() {
        // Only necessary if tags are an independant model
    }
    
    static func deleteTag() {
        // Only necessary if tags are an independant model
    }
}