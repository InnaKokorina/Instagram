//
//  BaseLabel.swift
//  Instagram
//
//  Created by Inna Kokorina on 22.06.2022.
//

import Foundation
import UIKit
import FirebaseAuth

class BaseLabel: UILabel {
    convenience init(textColor: UIColor, textAlignment: NSTextAlignment, text: String) {
        self.init(frame: CGRect.zero)
        self.numberOfLines = 0
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.text = text
    }
    convenience init(textColor: UIColor, textAlignment: NSTextAlignment) {
        self.init(frame: CGRect.zero)
        self.numberOfLines = 0
        self.textColor = textColor
        self.textAlignment = textAlignment
    }
}
extension UILabel {
    func setLabelFont(with size: CGFloat) {
        self.font = UIFont(name: Constants.Font.font, size: size)
    }
}
class BaseTextField: UITextField {
    convenience init(placeholder: String, textContentType: UITextContentType, keyboardType: UIKeyboardType   ) {
        self.init(frame: CGRect.zero)
        self.placeholder = placeholder
        self.textContentType = textContentType
        self.keyboardType = keyboardType
        self.textAlignment = .left
        self.borderStyle = .roundedRect
        self.autocorrectionType = .yes
        self.font = UIFont(name: Constants.Font.font, size: 17)
    }
}
class BaseButton: UIButton {
    convenience init(backgroundColor: UIColor) {
        self.init(frame: CGRect.zero)
        self.backgroundColor = backgroundColor
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.black.cgColor
        if #available(iOS 15.0, *) {
            self.configuration?.cornerStyle = .dynamic
            self.layer.cornerRadius = 5
        }
    }
}
class BaseUserImage: UIImageView {
    convenience init(cornerRadius: CGFloat) {
        self.init(frame: CGRect.zero)
        self.contentMode = .scaleAspectFill
        self.image = UIImage(systemName: "person")
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
    }
}
class BasePostImage: UIImageView {
    convenience init() {
        self.init(frame: CGRect.zero)
        self.contentMode = .scaleAspectFill
        self.clipsToBounds = true
        self.layer.cornerRadius = 15
        self.isUserInteractionEnabled = true
    }
}
