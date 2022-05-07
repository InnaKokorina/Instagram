//
//  YPImagePickerView.swift
//  Instagram
//
//  Created by Inna Kokorina on 07.05.2022.
//

import Foundation
import YPImagePicker

class YPImagePickerView {

    func setConfig() -> YPImagePickerConfiguration {
    var config = YPImagePickerConfiguration()
    config.library.onlySquare = true
    config.onlySquareImagesFromCamera = true
    config.library.mediaType = .photo
    config.library.itemOverlayType = .grid
    config.shouldSaveNewPicturesToAlbum = false
    config.startOnScreen = .library
    config.screens = [.library, .photo]
    config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8
    config.showsCrop = .rectangle(ratio: 1)
    config.wordings.libraryTitle = "Альбом"
    config.hidesStatusBar = false
    config.hidesBottomBar = false
    config.maxCameraZoomFactor = 2.0
    config.library.maxNumberOfItems = 1
    config.gallery.hidesRemoveButton = false
        return config
    }
}
