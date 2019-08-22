//
//  KUIPopOver.swift
//  KUIPopOver
//
//  Created by kofktu on 2017. 8. 31..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import Foundation
import UIKit

public typealias ShowPopoverCompletion = () -> Void
public typealias DismissPopoverCompletion = () -> Void

fileprivate class KUIPopOverUsableDismissHandlerWrapper {
    typealias DismissHandler = ((Bool, DismissPopoverCompletion?) -> Void)
    var closure: DismissHandler?
    
    init(_ closure: DismissHandler?) {
        self.closure = closure
    }
}

fileprivate extension UIView {
    
    struct AssociatedKeys {
        static var onDismissHandler = "onDismissHandler"
    }
    
    var onDismissHandler: KUIPopOverUsableDismissHandlerWrapper.DismissHandler? {
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
    
    public func showPopover(sourceView: UIView, sourceRect: CGRect? = nil, shouldDismissOnTap: Bool = true, completion: ShowPopoverCompletion? = nil) {
        let usableViewController = KUIPopOverUsableViewController(popOverUsable: self)
        usableViewController.showPopover(sourceView: sourceView,
                                         sourceRect: sourceRect,
                                         shouldDismissOnTap: shouldDismissOnTap,
                                         completion: completion)
        onDismissHandler = { [weak self] (animated, completion) in
            self?.dismiss(usableViewController: usableViewController, animated: animated, completion: completion)
        }
    }
    
    public func showPopover(barButtonItem: UIBarButtonItem, shouldDismissOnTap: Bool = true, completion: ShowPopoverCompletion? = nil) {
        let usableViewController = KUIPopOverUsableViewController(popOverUsable: self)
        usableViewController.showPopover(barButtonItem: barButtonItem,
                                         shouldDismissOnTap: shouldDismissOnTap,
                                         completion: completion)
        onDismissHandler = { [weak self] (animated, completion) in
            self?.dismiss(usableViewController: usableViewController, animated: animated, completion: completion)
        }
    }
    
    public func dismissPopover(animated: Bool, completion: DismissPopoverCompletion? = nil) {
        onDismissHandler?(animated, completion)
    }
    
    
    // MARK: - Private
    private func dismiss(usableViewController: KUIPopOverUsableViewController, animated: Bool, completion: DismissPopoverCompletion? = nil) {
        if let completion = completion {
            usableViewController.dismiss(animated: animated, completion: { [weak self] in
                self?.onDismissHandler = nil
                completion()
            })
        } else {
            usableViewController.dismiss(animated: animated, completion: nil)
            onDismissHandler = nil
        }
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
        naviController.popoverPresentationController?.delegate = KUIPopOverDelegation.shared
        naviController.popoverPresentationController?.backgroundColor = popOverBackgroundColor
        naviController.popoverPresentationController?.permittedArrowDirections = arrowDirection
        return naviController
    }
    
    private func setup() {
        modalPresentationStyle = .popover
        preferredContentSize = contentSize
        popoverPresentationController?.delegate = KUIPopOverDelegation.shared
        popoverPresentationController?.backgroundColor = popOverBackgroundColor
        popoverPresentationController?.permittedArrowDirections = arrowDirection
    }
    
    public func setupPopover(sourceView: UIView, sourceRect: CGRect? = nil) {
        setup()
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.sourceRect = sourceRect ?? sourceView.bounds
    }
    
    public func setupPopover(barButtonItem: UIBarButtonItem) {
        setup()
        popoverPresentationController?.barButtonItem = barButtonItem
    }
    
    public func showPopover(sourceView: UIView, sourceRect: CGRect? = nil, shouldDismissOnTap: Bool = true, completion: ShowPopoverCompletion? = nil) {
        setupPopover(sourceView: sourceView, sourceRect: sourceRect)
        KUIPopOverDelegation.shared.shouldDismissOnOutsideTap = shouldDismissOnTap
        rootViewController?.present(self, animated: true, completion: completion)
    }
    
    public func showPopoverWithNavigationController(sourceView: UIView, sourceRect: CGRect? = nil, shouldDismissOnTap: Bool = true, completion: ShowPopoverCompletion? = nil) {
        let naviController = popOverUsableNavigationController
        naviController.popoverPresentationController?.sourceView = sourceView
        naviController.popoverPresentationController?.sourceRect = sourceRect ?? sourceView.bounds
        KUIPopOverDelegation.shared.shouldDismissOnOutsideTap = shouldDismissOnTap
        rootViewController?.present(naviController, animated: true, completion: completion)
    }
    
    public func showPopover(barButtonItem: UIBarButtonItem, shouldDismissOnTap: Bool = true, completion: ShowPopoverCompletion? = nil) {
        setupPopover(barButtonItem: barButtonItem)
        KUIPopOverDelegation.shared.shouldDismissOnOutsideTap = shouldDismissOnTap
        rootViewController?.present(self, animated: true, completion: completion)
    }
    
    public func showPopoverWithNavigationController(barButtonItem: UIBarButtonItem, shouldDismissOnTap: Bool = true, completion: ShowPopoverCompletion? = nil) {
        let naviController = popOverUsableNavigationController
        naviController.popoverPresentationController?.barButtonItem = barButtonItem
        KUIPopOverDelegation.shared.shouldDismissOnOutsideTap = shouldDismissOnTap
        rootViewController?.present(naviController, animated: true, completion: completion)
    }
    
    public func dismissPopover(animated: Bool, completion: DismissPopoverCompletion? = nil) {
        dismiss(animated: animated, completion: completion)
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
    
    var popOverBackgroundColor: UIColor? {
        return popOverUsable.popOverBackgroundColor
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
    var shouldDismissOnOutsideTap: Bool = false
    
    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return shouldDismissOnOutsideTap
    }
}

private extension UIViewController {
    
    var topPresentedViewController: UIViewController {
        return presentedViewController?.topPresentedViewController ?? self
    }
    
}
