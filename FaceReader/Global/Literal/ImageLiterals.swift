//
//  ImageLiterals.swift
//  FaceReader
//
//  Created by COBY_PRO on 2022/08/23.
//

import UIKit

enum ImageLiterals {
    static var logo: UIImage { .load(name: "logo")}
    
    static var btnBack: UIImage { .load(systemName: "chevron.backward") }
    static var btnHelp: UIImage { .load(systemName: "exclamationmark.circle") }
    static var btnEdit: UIImage { .load(systemName: "pencil") }
    static var btnCamera: UIImage { .load(name: "camera") }
    static var btnRefresh: UIImage { .load(name: "refresh") }
    
    static var background: UIImage { .load(name: "background") }
    
    static var wolf: UIImage { .load(name: "wolf") }
    static var tiger: UIImage { .load(name: "tiger") }
    static var demon: UIImage { .load(name: "demon") }
    static var dragon: UIImage { .load(name: "dragon") }
    static var god: UIImage { .load(name: "god") }
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
