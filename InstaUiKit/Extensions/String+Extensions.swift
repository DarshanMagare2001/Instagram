//
//  String+Extensions.swift
//  InstaUiKit
//
//  Created by IPS-161 on 08/01/24.
//

import Foundation

public extension String {
    func isEmailValid() -> Bool {
        let regex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        let pattern = NSPredicate(format: "SELF MATCHES %@", regex)
        return pattern.evaluate(with: self)
    }
}

public extension String {
    func isPasswordValid() -> Bool {
        return self.count >= 6
    }
}
