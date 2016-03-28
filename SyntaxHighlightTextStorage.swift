//
//  SyntaxHighlightTextStorage.swift
//  justype
//
//  Created by Gibson Smiley on 3/25/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import UIKit

class SyntaxHighlightTextStorage: NSTextStorage {
    let backingStore = NSMutableAttributedString()
    var replacements: [String : [NSObject : AnyObject]]!
    
    override init() {
        super.init()
        createHighlightPatterns()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var string: String {
        return backingStore.string
    }
    
    override func attributesAtIndex(index: Int, effectiveRange range: NSRangePointer) -> [String : AnyObject] {
        return backingStore.attributesAtIndex(index, effectiveRange: range)
    }
    
    override func replaceCharactersInRange(range: NSRange, withString str: String) {
        print("replaceCharactersInRange:\(range) withString:\(str)")
        
        beginEditing()
        backingStore.replaceCharactersInRange(range, withString:str)
        edited([.EditedCharacters, .EditedAttributes], range: range, changeInLength: (str as NSString).length - range.length)
        endEditing()
    }
    
    override func setAttributes(attrs: [String : AnyObject]!, range: NSRange) {
        print("setAttributes:\(attrs) range:\(range)")
        
        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited(.EditedAttributes, range: range, changeInLength: 0)
        endEditing()
    }
    
    func applyStylesToRange(searchRange: NSRange) {
        let normalFont = UIFont(name: "AvenirNext-MediumItalic", size: 17.0)!
        let normalAttrs = [NSFontAttributeName: normalFont]
        
        // iterate over each replacement
        for (pattern, attributes) in replacements {
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            regex.enumerateMatchesInString(backingStore.string, options: [], range: searchRange) {
                match, flags, stop in
                // apply the style
                let matchRange = match!.rangeAtIndex(1)
//                self.addAttributes(attributes, range: matchRange)
                
                // reset the style to the original
                let maxRange = matchRange.location + matchRange.length
                if maxRange + 1 < self.length {
                    self.addAttributes(normalAttrs, range: NSMakeRange(maxRange, 1))
                }
            }
        }
    }
    
    func performReplacementsForRange(changedRange: NSRange) {
        var extendedRange = NSUnionRange(changedRange, NSString(string: backingStore.string).lineRangeForRange(NSMakeRange(changedRange.location, 0)))
        extendedRange = NSUnionRange(changedRange, NSString(string: backingStore.string).lineRangeForRange(NSMakeRange(NSMaxRange(changedRange), 0)))
        applyStylesToRange(extendedRange)
    }
    
    override func processEditing() {
        performReplacementsForRange(self.editedRange)
        super.processEditing()
    }
    
    func createHighlightPatterns() {
        
        let boldFont = UIFont(name: "AvenirNext-Heavy", size: 17.0)!
        let italicFont = UIFont(name: "AvenirNext-Medium", size: 17.0)!
        
        let boldAttributes = [NSFontAttributeName: boldFont]
        let italicAttributes = [NSFontAttributeName: italicFont]
        
        // construct a dictionary of replacements based on regexes
        replacements = [
            "(\\*\\w+(\\s\\w+)*\\*)" : boldAttributes,
            "(_\\w+(\\s\\w+)*_)" : italicAttributes,
            "([0-9]+\\.)\\s" : boldAttributes
        ]
    }
    
    func update() {
        // update the highlight patterns
        createHighlightPatterns()
        
        // change the 'global' font
        let normalFont = UIFont(name: "AvenirNext-MediumItalic", size: 17.0)!
        let bodyFont = [NSFontAttributeName: normalFont]
        addAttributes(bodyFont, range: NSMakeRange(0, length))
        
        // re-apply the regex matches
        applyStylesToRange(NSMakeRange(0, length))
    }
    
}












