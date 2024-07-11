//
//  BaseModel.swift
//  HLUIKit_Example
//
//  Created by 屋联-神兽 on 2024/7/11.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import SmartCodable
import HLinUIKit

class BaseModel: NSObject {
        
    required override init() {
        super.init()
    }
}

class ExModel:NSObject, SmartCodable {
    var name: String?
    var text: String?
    var content: String?
    
    required override init() {
        super.init()
    }
}
