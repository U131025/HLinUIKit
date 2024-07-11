//
//  ListViewModel.swift
//  HLUIKit_Example
//
//  Created by 屋联-神兽 on 2020/9/16.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import HLinUIKit

class ListViewModel: HLViewModel {
    
    override func initConfig() {
        super.initConfig()
        
        let model = ExModel()
        model.name = "123456"
        model.text = "1223"
        model.content = "dafsdf"
        
        let string = model.toJSONString()
        print("\(string)")
        
        let jsonString = "{\"text\":\"1223\",\"name\":\"123456\"}"
        let newModel = ExModel.deserialize(from: jsonString)

        _ = jsonString
            .mapModel(ExModel.self)
            .subscribe(onNext: { newMode in
                
                print("\(newMode)")
            })
        
        return
    }
    
    override func refresh() {
        var items = [HLCellType]()
        for index in 0..<10 {
            items.append("item_\(index)")
        }
        
        _ = setItems(items)
    }
}
