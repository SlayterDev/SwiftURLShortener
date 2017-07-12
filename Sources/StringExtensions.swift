//
//  StringExtensions.swift
//  MyFirstBackend
//
//  Created by bslayter on 7/12/17.
//
//

import Foundation

extension String {
    func isURL() -> Bool {
        if self.hasPrefix("https://") || self.hasPrefix("http://") {
            return true
        }
        
        return self.range(of: "^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$", options: .regularExpression) != nil
    }
}
