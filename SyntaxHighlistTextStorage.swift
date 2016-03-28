//
//  SyntaxHighlistTextStorage.swift
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
//        createHighlightPatterns()
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
        let boldFont = UIFont(name: "AvenirNext-Heavy", size: 17.0)!
        let italicFont = UIFont(name: "AvenirNext-Medium", size: 17.0)!
        let normalFont = UIFont(name: "AvenirNext-MediumItalic", size: 17.0)!
        
        let boldAttributes = [NSFontAttributeName: boldFont]
        let italicAttributes = [NSFontAttributeName: italicFont]
        let normalAttributes = [NSFontAttributeName: normalFont]
        
        // 2. match items surrounded by asterisks
        let regexStr = "(\\*\\w+(\\s\\w+)*\\*)"
        let regex = try! NSRegularExpression(pattern: regexStr, options: [])

        
        // 3. iterate over each match, making the text bold
        regex.enumerateMatchesInString(backingStore.string, options: [], range: searchRange) {
            match, flags, stop in
            let matchRange = match!.rangeAtIndex(1)
            self.addAttributes(boldAttributes, range: matchRange)
            
            // 4. reset the style to the original
            let maxRange = matchRange.location + matchRange.length
            if maxRange + 1 < self.length {
                self.addAttributes(normalAttributes, range: NSMakeRange(maxRange, 1))
            }
        }
    }
//        let normalAttrs = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
//
//        // iterate over each replacement
//        for (pattern, attributes) in replacements {
//            let regex = try! NSRegularExpression(pattern: pattern, options: [])
//            regex.enumerateMatchesInString(backingStore.string, options: [], range: searchRange) {
//                match, flags, stop in
//                // apply the style
//                let matchRange = match!.rangeAtIndex(1)
//                self.addAttributes(attributes, range: matchRange)
//                
//                // reset the style to the original
//                let maxRange = matchRange.location + matchRange.length
//                if maxRange + 1 < self.length {
//                    self.addAttributes(normalAttrs, range: NSMakeRange(maxRange, 1))
//                }
//            }
//        }
//    }
//    
//    func performReplacementsForRange(changedRange: NSRange) {
//        var extendedRange = NSUnionRange(changedRange, NSString(string: backingStore.string).lineRangeForRange(NSMakeRange(changedRange.location, 0)))
//        extendedRange = NSUnionRange(changedRange, NSString(string: backingStore.string).lineRangeForRange(NSMakeRange(NSMaxRange(changedRange), 0)))
//        applyStylesToRange(extendedRange)
//    }
//    
//    override func processEditing() {
//        performReplacementsForRange(self.editedRange)
//        super.processEditing()
//    }
//
//    func createAttributesForFontStyle(style: String, withTrait trait: UIFontDescriptorSymbolicTraits) -> [NSObject : AnyObject] {
//        let fontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
//        let descriptorWithTrait = fontDescriptor.fontDescriptorWithSymbolicTraits(trait)
//        let font = UIFont(descriptor: descriptorWithTrait, size: 0)
//        return [NSFontAttributeName : font]
//    }
//    
//    func createHighlightPatterns() {
//        let scriptFontDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptorFamilyAttribute : "Zapfino"])
//        
//        // 1. base our script font on the preferred body font size
//        let bodyFontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
//        let bodyFontSize = bodyFontDescriptor.fontAttributes()[UIFontDescriptorSizeAttribute] as! NSNumber
//        let scriptFont = UIFont(descriptor: scriptFontDescriptor, size: CGFloat(bodyFontSize.floatValue))
//        
//        // 2. create the attributes
//        let boldAttributes = createAttributesForFontStyle(UIFontTextStyleBody, withTrait:.TraitBold)
//        let italicAttributes = createAttributesForFontStyle(UIFontTextStyleBody, withTrait:.TraitItalic)
//        let strikeThroughAttributes = [NSStrikethroughStyleAttributeName : 1]
//        let scriptAttributes = [NSFontAttributeName : scriptFont]
//        let redTextAttributes = [NSForegroundColorAttributeName : UIColor.redColor()]
//        
//        // construct a dictionary of replacements based on regexes
//        replacements = [
//            "(\\*\\w+(\\s\\w+)*\\*)" : boldAttributes,
//            "(_\\w+(\\s\\w+)*_)" : italicAttributes,
//            "([0-9]+\\.)\\s" : boldAttributes,
//            "(-\\w+(\\s\\w+)*-)" : strikeThroughAttributes,
//            "(~\\w+(\\s\\w+)*~)" : scriptAttributes,
//            "\\s([A-Z]{2,})\\s" : redTextAttributes
//        ]
//    }
//    
//    func update() {
//        // update the highlight patterns
//        createHighlightPatterns()
//        
//        // change the 'global' font
//        let bodyFont = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
//        addAttributes(bodyFont, range: NSMakeRange(0, length))
//        
//        // re-apply the regex matches
//        applyStylesToRange(NSMakeRange(0, length))
//    }
    
}