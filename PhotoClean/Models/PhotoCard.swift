//
//  PhotoCard.swift
//  PhotoClean
//
//  Created by Vedant Bhatt on 5/31/25.
//

import Foundation
import UIKit
import Photos

class PhotoCard: Card {
    var image: UIImage?
    
    init(decision: Decision = .UNDECIDED, asset: PHAsset? = nil, image: UIImage? = nil) {
        self.image = image
        super.init(asset: asset, decision: decision)
    }
}


