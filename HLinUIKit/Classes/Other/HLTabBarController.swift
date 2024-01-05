//
//  CustomTabBarController.swift
//  Exchange
//
//  Created by mac on 2018/12/5.
//  Copyright © 2018年 mac. All rights reserved.
//

import UIKit

open class HLTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    public static var foregroundColor: UIColor? = nil
    public static var foregroundColorSelected: UIColor? = nil
    
    public var curForegroundColor: UIColor? = nil
    public var curForegroundColorSelected: UIColor? = nil
    
    public typealias TabBarShouldSelectBlock = (UITabBarItem?) -> Bool
     
    public var shouldSelectBlock: TabBarShouldSelectBlock?
    public func setShouldSelectBlock(_ block: TabBarShouldSelectBlock?) -> Self {
        self.shouldSelectBlock = block
        return self
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateForegroundColor()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.recoverForegroundColor()
    }
      
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.        
        tabBar.isTranslucent = false
        tabBar.barTintColor = UIColor.white
        tabBar.backgroundColor = .white

        delegate = self
        
        self.selectedIndex = 0
    }
    
    func updateForegroundColor() {
        
        if let color = curForegroundColor ?? HLTabBarController.foregroundColor {
            updateForegroundColor(color: color, for: .normal)
        }
        
        if let color = curForegroundColorSelected ?? HLTabBarController.foregroundColorSelected {
            updateForegroundColor(color: color, for: .selected)
        }
    }
    
    func recoverForegroundColor() {
        if let color = HLTabBarController.foregroundColor {
            updateForegroundColor(color: color, for: .normal)
        }
        
        if let color = HLTabBarController.foregroundColorSelected {
            updateForegroundColor(color: color, for: .selected)
        }
    }
    
    func updateForegroundColor(color: UIColor, for state: UIControl.State) {
        
        if #available(iOS 13.0, *) {
            if state == .selected {
                tabBar.tintColor = color
            } else {
                tabBar.unselectedItemTintColor = color
            }
            
        } else {
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: color], for: state)
        }
    }
    
    public func updateFont(font: UIFont) {
        updateFont(font: font, for: .normal)
        updateFont(font: font, for: .selected)
    }
    
    public func updateFont(font: UIFont, for state: UIControl.State) {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font], for: state)
    }
    
    public func clearShadow() -> Self {
        // 黑线
        tabBar.backgroundImage = UIImage.init()
        tabBar.shadowImage = UIImage.init()
        return self
    }
    
    public func setTitleColor(color: UIColor, for state: UIControl.State) -> Self {
        
        if state == .normal {
            curForegroundColor = color
        } else if state == .selected {
            curForegroundColorSelected = color
        }
        
        updateForegroundColor(color: color, for: state)
        return self
    }

    public func add(_ viewcontroller: UIViewController, title: String?, normalImage: UIImage? = nil, selImage: UIImage? = nil, tag: Int = 0) -> Self {

        viewcontroller.title = title

        let nav = HLNavigationController.init(rootViewController: viewcontroller)
        let tabItem = UITabBarItem(title: title, image: normalImage, selectedImage: selImage)
        tabItem.tag = tag
        nav.tabBarItem = tabItem

        self.addChild(nav)

        return self
    }

    public func setTabBarBackgroundImage(_ image: UIImage?) -> Self {
        tabBar.backgroundImage = image
        return self
    }
    
    //MARK: Delegate
    // 是否跳转
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let block = self.shouldSelectBlock {
            return block(tabBarController.tabBar.selectedItem)
        }
        
        return true
    }
    
}
