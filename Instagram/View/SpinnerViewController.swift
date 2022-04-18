//
//  SpinnerViewController.swift
//  Instagram
//
//  Created by Inna Kokorina on 07.04.2022.
//

import UIKit

open class SpinnerViewController {
    
    public static var spinner: UIActivityIndicatorView?
    public static var style: UIActivityIndicatorView.Style = .medium
    public static var baseBackColor = UIColor(white: 0, alpha: 0.1)
    public static var baseColor = UIColor.darkGray
    
    public static func start(style: UIActivityIndicatorView.Style = style, backColor: UIColor = baseBackColor, baseColor: UIColor = baseColor, window: UIImageView) {
            let frame = window.bounds
            spinner = UIActivityIndicatorView(frame: frame)
            spinner!.backgroundColor = backColor
            spinner!.style = style
            spinner?.color = baseColor
            window.addSubview(spinner!)
            spinner!.startAnimating()
            spinner?.isHidden = false 
    }
    
    
    public static func stop() {
          spinner?.isHidden = true
          spinner!.stopAnimating()
    }
}
    
