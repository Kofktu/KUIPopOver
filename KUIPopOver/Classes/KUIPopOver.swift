//
//  KUIPopOver.swift
//  KUIPopOver
//
//  Created by kofktu on 2017. 8. 31..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import Foundation
import UIKit

fileprivate class KUIPopOverUsableDismissHandlerWrapper {
    typealias DismissHandler = ((Bool) -> Void)
    var closure: DismissHandler?
    
    init(_ closure: DismissHandler?) {
        self.closure = closure
    }
}

fileprivate extension UIView {
    
    struct AssociatedKeys {
        static var onDismissHandler = "onDismissHandler"
    }
    
    fileprivate var onDismissHandler: KUIPopOverUsableDismissHandlerWrapper.DismissHandler? {
        get { return (objc_getAssociatedObject(self, &AssociatedKeys.onDismissHandler) as? KUIPopOverUsableDismissHandlerWrapper)?.closure }
        set { objc_setAssociatedObject(self, &AssociatedKeys.onDismissHandler, KUIPopOverUsableDismissHandlerWrapper(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
}

extension KUIPopOverUsable where Self: UIView {

    public var contentView: UIView {
        return self
    }
    
    public var contentSize: CGSize {
        return frame.size
    }
    
    public func showPopover(sourceView: UIView, sourceRect: CGRect) {
        let usableViewController = KUIPopOverUsableViewController(popOverUsable: self)
        usableViewController.showPopover(sourceView: sourceView, sourceRect: sourceRect)
        onDismissHandler = { [weak self] animated in
            usableViewController.dismiss(animated: animated, completion: nil)
            self?.onDismissHandler = nil
        }
    }
    
    public func showPopover(barButtonItem: UIBarButtonItem) {
        let usableViewController = KUIPopOverUsableViewController(popOverUsable: self)
        usableViewController.showPopover(barButtonItem: barButtonItem)
        onDismissHandler = { [weak self] animated in
            usableViewController.dismiss(animated: animated, completion: nil)
            self?.onDismissHandler = nil
        }
    }
    
    public func dismissPopover(animated: Bool) {
        onDismissHandler?(animated)
    }
}

extension KUIPopOverUsable where Self: UIViewController {
    
    public var contentView: UIView {
        return view
    }
    
    private var rootViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController?.topPresentedViewController
    }
    
    private var popOverUsableNavigationController: KUIPopOverUsableNavigationController {
        let naviController = KUIPopOverUsableNavigationController(rootViewController: self)
        naviController.modalPresentationStyle = .popover
        naviController.popoverPresentationController?.permittedArrowDirections = arrowDirection
        naviController.popoverPresentationController?.delegate = KUIPopOverDelegation.shared
        return naviController
    }
    
    private func setup() {
        modalPresentationStyle = .popover
        preferredContentSize = contentSize
        popoverPresentationController?.delegate = KUIPopOverDelegation.shared
        popoverPresentationController?.permittedArrowDirections = arrowDirection
    }
    
    public func setupPopover(sourceView: UIView, sourceRect: CGRect) {
        setup()
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.sourceRect = sourceRect
    }
    
    public func setupPopover(barButtonItem: UIBarButtonItem) {
        setup()
        popoverPresentationController?.barButtonItem = barButtonItem
    }
    
    public func showPopover(sourceView: UIView, sourceRect: CGRect) {
        setupPopover(sourceView: sourceView, sourceRect: sourceRect)
        rootViewController?.present(self, animated: true, completion: nil)
    }
    
    public func showPopover(withNavigationController sourceView: UIView, sourceRect: CGRect) {
        let naviController = popOverUsableNavigationController
        naviController.popoverPresentationController?.sourceView = sourceView
        naviController.popoverPresentationController?.sourceRect = sourceRect
        rootViewController?.present(naviController, animated: true, completion: nil)
    }
    
    public func showPopover(barButtonItem: UIBarButtonItem) {
        setupPopover(barButtonItem: barButtonItem)
        rootViewController?.present(self, animated: true, completion: nil)
    }
    
    public func showPopover(withNavigationController barButtonItem: UIBarButtonItem) {
        let naviController = popOverUsableNavigationController
        naviController.popoverPresentationController?.barButtonItem = barButtonItem
        rootViewController?.present(naviController, animated: true, completion: nil)
    }
    
    public func dismissPopover(animated: Bool) {
        dismiss(animated: true, completion: nil)
    }
}

private final class KUIPopOverUsableNavigationController: UINavigationController {
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let popOverUsable = visibleViewController as? KUIPopOverUsable {
            preferredContentSize = popOverUsable.contentSize
        } else {
            preferredContentSize = visibleViewController?.preferredContentSize ?? preferredContentSize
        }
    }
    
}

private final class KUIPopOverUsableViewController: UIViewController, KUIPopOverUsable {
    
    var contentSize: CGSize {
        return popOverUsable.contentSize
    }
    
    var contentView: UIView {
        return view
    }
    
    var arrowDirection: UIPopoverArrowDirection {
        return popOverUsable.arrowDirection
    }
    
    private var popOverUsable: KUIPopOverUsable!
    
    convenience init(popOverUsable: KUIPopOverUsable) {
        self.init()
        self.popOverUsable = popOverUsable
        preferredContentSize = popOverUsable.contentSize
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
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

private extension UIViewController {
    
    var topPresentedViewController: UIViewController {
        return presentedViewController?.topPresentedViewController ?? self
    }
    
}
