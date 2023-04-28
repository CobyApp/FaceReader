//
//  NSObject+Extension.swift
//  FaceReader
//
//  Created by COBY_PRO on 2023/04/29.
//

import Foundation

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}
