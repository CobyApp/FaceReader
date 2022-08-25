//
//  ImageLiterals.swift
//  FaceReader
//
//  Created by COBY_PRO on 2022/08/23.
//

import UIKit

enum ImageLiterals {
    
    static var btnBack: UIImage { .load(systemName: "chevron.backward") }
    static var btnCamera: UIImage { .load(name: "camera") }
  
    static var background: UIImage { .load(name: "background") }
}

extension UIImage {
    static func load(name: String) -> UIImage {
        guard let image = UIImage(named: name, in: nil, compatibleWith: nil) else {
            return UIImage()
        }
        image.accessibilityIdentifier = name
        return image
    }
    
    static func load(systemName: String) -> UIImage {
        guard let image = UIImage(systemName: systemName, compatibleWith: nil) else {
            return UIImage()
        }
        image.accessibilityIdentifier = systemName
        return image
    }
    
    func resize(to size: CGSize) -> UIImage {
        let image = UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
        return image
    }
}
