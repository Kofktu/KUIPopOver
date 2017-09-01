//
//  KUIPopOver.swift
//  KUIPopOver
//
//  Created by kofktu on 2017. 8. 31..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import Foundation
import UIKit

extension KUIPopOverUsable where Self: UIView {

    public var contentView: UIView {
        return self
    }
    
    public func showPopover(sourceView: UIView, sourceRect: CGRect) {
        let usableViewController = KUIPopOverUsableViewController(popOverUsable: self)
        usableViewController.showPopover(sourceView: sourceView, sourceRect: sourceRect)
    }
    
    public func showPopover(barButtonItem: UIBarButtonItem) {
        let usableViewController = KUIPopOverUsableViewController(popOverUsable: self)
        usableViewController.showPopover(barButtonItem: barButtonItem)
    }
    
}

extension KUIPopOverUsable where Self: UIViewController {
    
    public var contentView: UIView {
        return view
    }
    
    private var rootViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController?.topPresentedViewController
    }
    
    public func showPopover(sourceView: UIView, sourceRect: CGRect) {
        modalPresentationStyle = .popover
        preferredContentSize = contentSize
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.sourceRect = sourceRect
        popoverPresentationController?.delegate = KUIPopOverDelegation.shared
        rootViewController?.present(self, animated: true, completion: nil)
    }
    
    public func showPopover(barButtonItem: UIBarButtonItem) {
        modalPresentationStyle = .popover
        preferredContentSize = contentSize
        popoverPresentationController?.barButtonItem = barButtonItem
        popoverPresentationController?.delegate = KUIPopOverDelegation.shared
        rootViewController?.present(self, animated: true, completion: nil)
    }
    
}

private final class KUIPopOverUsableViewController: UIViewController, KUIPopOverUsable {
    
    var contentSize: CGSize {
        return popOverUsable.contentSize
    }
    
    var contentView: UIView {
        return view
    }
    
    private var popOverUsable: KUIPopOverUsable!
    
    convenience init(popOverUsable: KUIPopOverUsable) {
        self.init()
        self.popOverUsable = popOverUsable
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(popOverUsable.contentView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        popOverUsable.contentView.frame = view.bounds
    }
    
}

private final class KUIPopOverDelegation: NSObject, UIPopoverPresentationControllerDelegate {
    
    static let shared = KUIPopOverDelegation()
    
    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}

private extension UIViewController {
    
    var topPresentedViewController: UIViewController {
        return presentedViewController?.topPresentedViewController ?? self
    }
    
}
