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
    public static var baseColor = UIColor.darkGray
    
    public static func start(style: UIActivityIndicatorView.Style = style,  baseColor: UIColor = baseColor, window: UIImageView) {
            let frame = window.bounds
            spinner = UIActivityIndicatorView(frame: frame)
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
    
