//
//  Card.swift
//  PhotoClean
//
//  Created by Vedant Bhatt on 5/30/25.
//

import Foundation
import Photos

class Card: Identifiable {
    let id = UUID()
    var asset: PHAsset?
    @Published var decision: Decision = .undecided
    
    enum Decision {
        case undecided
        case later
        case keep
        case delete
    }
    
    init(asset: PHAsset? = nil, decision: Decision) {
        self.asset = asset
        self.decision = decision
    }
    
}
