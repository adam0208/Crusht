//
//  DateExtension.swift
//  Crusht
//
//  Created by Santiago Goycoechea on 10/21/19.
//  Copyright © 2019 William Kelly. All rights reserved.
//

import Foundation

extension Date {
    var daysInMonth: Int {
        let calendar = Calendar.current

        let dateComponents = DateComponents(year: calendar.component(.year, from: self), month: calendar.component(.month, from: self))
        let date = calendar.date(from: dateComponents)!
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        let numDays = range.count
        
        return numDays
    }
}
