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
    var popOverBackgroundColor: UIColor? { get }
    var arrowDirection: UIPopoverArrowDirection { get }
}

extension KUIPopOverUsable {
    
    public var popOverBackgroundColor: UIColor? {
        return nil
    }
    
    public var arrowDirection: UIPopoverArrowDirection {
        return .any
    }
}

public extension UIPopoverArrowDirection {
    static var none: UIPopoverArrowDirection {
        return UIPopoverArrowDirection(rawValue: 0)
    }
}
