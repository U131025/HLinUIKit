//
//  UIViewController+Jump.swift
//  IM_XMPP
//
//  Created by mojingyu on 2018/11/5.
//  Copyright © 2018年 mac. All rights reserved.
//
// swiftlint:disable identifier_name

import Foundation
import UIKit

extension UIViewController {

    public var preViewController: UIViewController? {
        guard let count = self.navigationController?.viewControllers.count else { return nil }
        return self.navigationController?.viewControllers[safe: count - 2]
    }
    
    public func pop(filter aClassList: [AnyClass]) {
        
        if let viewcontrollers = self.navigationController?.viewControllers {
            for vc in viewcontrollers.reversed() {
                if vc == self {
                    continue
                }
                
                var isFilter: Bool = false
                for aClass in aClassList {
                    if vc.isKind(of: aClass) == true {
                        isFilter = true
                    }
                }
                if isFilter == false {
                    self.navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
        }

        self.pop()
    }

    public func pop(to aClassList: [AnyClass], _ isToRoot: Bool = false) {

        if let viewcontrollers = self.navigationController?.viewControllers {

            for vc in viewcontrollers {

                for aClass in aClassList {
                    if vc.isKind(of: aClass) {
                        self.navigationController?.popToViewController(vc, animated: true)
                        return
                    }
                }
            }
        }

        self.pop(isToRoot)
    }

    public func pop(_ isToRoot: Bool = false) {

        if isToRoot == true {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    public func pop(animated: Bool) {
        self.navigationController?.popToRootViewController(animated: animated)
    }

    public func push(_ viewController: UIViewController, _ animated: Bool = true) {
        self.navigationController?.pushViewController(viewController, animated: animated)
    }
    
    public func present(_ viewController: UIViewController, animated: Bool, style: UIModalPresentationStyle) {

        viewController.modalPresentationStyle = style
        self.present(viewController, animated: animated, completion: nil)
    }

    public func present(_ viewController: UIViewController, animated: Bool = true) {

        viewController.modalPresentationStyle = .fullScreen        
        self.present(viewController, animated: true, completion: nil)
    }
    
    public func presentWithNav(_ viewController: UIViewController, style: UIModalPresentationStyle = .pageSheet) {
        
        let nav = HLNavigationController(rootViewController: viewController)
        nav.modalPresentationStyle = style
        self.present(nav, animated: true, completion: nil)
    }

    public func dismiss() {
        DispatchQueue.main.async {
            if self.isPresentMode {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.pop()
            }
        }                
    }
    
    public var isPresentMode: Bool {        
        if let array = self.navigationController?.viewControllers, array.count > 1 {
            return false
        }
        return true        
    }
    
    public func removeFromNav() {
        guard let viewControllers = self.navigationController?.viewControllers else {
            return
        }
        
        for (index, vc) in viewControllers.enumerated() {
            if vc.classForCoder == self.classForCoder {
                self.navigationController?.viewControllers.remove(at: index)
                break
            }
        }
        
        
    }
    
    public func removeVCFromNav(_ aClass: AnyClass) {

        guard let viewControllers = self.navigationController?.viewControllers else {
            return
        }

        for (index, vc) in viewControllers.enumerated() {
            if vc.classForCoder == aClass {
                self.navigationController?.viewControllers.remove(at: index)
                break
            }
        }
    }
    
    public func removeVCFromNav(aClasses: [AnyClass]) {
        
        guard var viewControllers = self.navigationController?.viewControllers else {
            return
        }

        for aClass in aClasses {
            for (index, vc) in viewControllers.enumerated() {
                if vc.classForCoder == aClass {
                    viewControllers.remove(at: index)
                    break
                }
            }
        }
        self.navigationController?.viewControllers = viewControllers
    }
}
