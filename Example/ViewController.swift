//
//  ViewController.swift
//  Example
//
//  Created by kofktu on 2017. 8. 31..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import UIKit
import KUIPopOver
import WebKit

class ViewController: UIViewController {

    // MARK: - Action
    @IBAction func onDefaultPopoverShow(_ sender: UIButton) {
        let popOverViewController = DefaultPopOverViewController()
        popOverViewController.preferredContentSize = CGSize(width: 200.0, height: 300.0)
        popOverViewController.popoverPresentationController?.sourceView = sender
        
        let customView = CustomPopOverView(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: 200.0, height: 300.0)))
        popOverViewController.view.addSubview(customView)
        popOverViewController.popoverPresentationController?.sourceRect = sender.bounds
        present(popOverViewController, animated: true, completion: nil)
    }
    
    @IBAction func onBarButtonItem(_ sender: UIBarButtonItem) {
        let customView = CustomPopOverView(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: 150.0, height: 200.0)))
        customView.showPopover(barButtonItem: sender) {
            print("CustomPopOverView.BarButtonItem.show.completion")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            customView.dismissPopover(animated: true, completion: {
                print("CustomPopOverView.BarButtonItem.dismiss.completion")
            })
        }
    }
    
    @IBAction func onCustomPopOverView(_ sender: UIButton) {
        let customView = CustomPopOverView(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: 150.0, height: 200.0)))
        customView.showPopover(sourceView: sender) {
            print("CustomPopOverView.show.completion")
        }
    }
    
    @IBAction func onCustomPopOverViewController(_ sender: UIButton) {
        let customViewController = CustomPopOverViewController()
        customViewController.showPopover(sourceView: sender)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            customViewController.dismissPopover(animated: true, completion: {
                print("CustomPopOverViewController.dismiss.completion")
            })
        }
    }
    
    @IBAction func onPopOverNavigationViewController(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CustomPushViewController") as! CustomPushViewController
        viewController.showPopoverWithNavigationController(sourceView: sender, shouldDismissOnTap: false)
    }
}

class DefaultPopOverViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}

class CustomPopOverView: UIView, KUIPopOverUsable {
 
    var contentSize: CGSize {
        return CGSize(width: 300.0, height: 400.0)
    }
    
    var popOverBackgroundColor: UIColor? {
        return .black
    }
    
    var arrowDirection: UIPopoverArrowDirection {
        return .up
    }
    
    lazy var webView: WKWebView = {
        let webView: WKWebView = WKWebView(frame: self.frame)
        webView.load(URLRequest(url: URL(string: "http://github.com")!))
        return webView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(webView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        webView.frame = self.bounds
    }
    
}

class CustomPopOverViewController: UIViewController, KUIPopOverUsable {
    
    var contentSize: CGSize {
        return CGSize(width: 300.0, height: 400.0)
    }
    
    var popOverBackgroundColor: UIColor? {
        return .blue
    }
    
    lazy var webView: WKWebView = {
        let webView: WKWebView = WKWebView(frame: self.view.frame)
        webView.load(URLRequest(url: URL(string: "http://github.com")!))
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    
}

class CustomPushViewController: UIViewController, KUIPopOverUsable {
    
    private lazy var size: CGSize = {
        return CGSize(width: 250.0, height: 100.0 + CGFloat(arc4random_uniform(200)))
    }()
    
    var contentSize: CGSize {
        return size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = size
        navigationItem.title = size.debugDescription
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onDoneButton(_:)))
    }
    
    @IBAction func onPushViewController(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CustomPushViewController") as! CustomPushViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    private func onDoneButton(_ sender: UIButton) {
        dismissPopover(animated: true)
    }
}
