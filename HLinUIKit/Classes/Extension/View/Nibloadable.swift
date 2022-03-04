//
//  File.swift
//  LightSW
//
//  Created by mojingyu on 2018/3/26.
//  Copyright © 2018年 Mojy. All rights reserved.
//

import Foundation
import UIKit

protocol Nibloadable {
    
}

extension Nibloadable where Self : UIView {
    /*
     static func loadNib(_ nibNmae :String = "") -> Self{
     let nib = nibNmae == "" ? "\(self)" : nibNmae
     return Bundle.main.loadNibNamed(nib, owner: nil, options: nil)?.first as! Self
     }
     */
    static func loadNib(_ nibNmae :String? = nil) -> Self {
        return Bundle.main.loadNibNamed(nibNmae ?? "\(self)", owner: nil, options: nil)?.first as! Self
    }
}

extension UIView {

    func loadNib() -> UIView? {

        let className = type(of: self)
        let name = NSStringFromClass(className).components(separatedBy: ".").last
        
        return Bundle.main.loadNibNamed(name!, owner: self, options: nil)?.first as? UIView
    }
}
