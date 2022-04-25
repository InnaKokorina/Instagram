//
//  ExtensionKeyboard.swift
//  Instagram
//
//  Created by Inna Kokorina on 25.04.2022.
//

import Foundation
import UIKit
// MARK: - keyboardWillShow
//extension UIViewController {
//    @objc func keyboardWillShow(notification: NSNotification, activeTextField: UITextField? ) {
//        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
//        var shouldMoveViewUp = false
//        if let activeTextField = activeTextField {
//            let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
//            let topOfKeyboard = self.view.frame.height - keyboardSize.height
//            if bottomOfTextField > topOfKeyboard {
//                shouldMoveViewUp = true
//            }
//            if shouldMoveViewUp {
//                self.view.frame.origin.y = 0 - keyboardSize.height
//            }
//        }
//    }
//    
//    @objc func keyboardWillHide(notification: NSNotification) {
//        self.view.frame.origin.y = 0
//    }
//}
