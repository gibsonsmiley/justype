//
//  DateController.swift
//  justype
//
//  Created by Gibson Smiley on 4/4/16.
//  Copyright © 2016 Gibson Smiley. All rights reserved.
//

import Foundation

extension NSDate {
    func stringValue() -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        return formatter.stringFromDate(self)
    }
}