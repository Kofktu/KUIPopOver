//
//  KUIPopOverUsable.swift
//  KUIPopOver
//
//  Created by kofktu on 2017. 8. 31..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import Foundation
import UIKit

public protocol KUIPopOverUsable {
    
    var contentSize: CGSize { get }
    var contentView: UIView { get }
    
}

public extension KUIPopOverUsable {
    
    var contentSize: CGSize {
        return CGSize(width: 150.0, height: 200.0)
    }
    
}
