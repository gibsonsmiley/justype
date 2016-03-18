//
//  NoteController.swift
//  justype
//
//  Created by Gibson Smiley on 3/15/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import Foundation

class NoteController {
    
    static var notes: [Note] = []
    
    static func createNote(text: String, user: User, completion: (note: Note?) -> Void) {
        
    }
    
    static func deleteNote(note: Note) {
        note.delete()
    }
    
    static func observeNotesForUser(user: User, completion: (notes: [Note]?) -> Void) {
    
    }
    
    static func noteForID(note: String, completion: (note: Note?) -> Void) {
        
    }
    
    static func orderNotes(notes: [Note]) -> [Note] {
        return notes.sort({$0.0.identifier > $0.1.identifier})
    }
    
    static func addTag() {
        // Only necessary if tags are an independant model
    }
    
    static func deleteTag() {
        // Only necessary if tags are an independant model
    }
}