//
//  UIImagePickerController+RxCreate.swift
//  RxSwift-Examples
//
//  Created by Ronan on 5/31/18.
//  Copyright © 2018 RonanStudio. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

func dismissViewController(_ viewController: UIViewController, animated: Bool) {
    if viewController.isBeingDismissed || viewController.isBeingPresented {
        DispatchQueue.main.async {
            dismissViewController(viewController, animated: animated)
        }
        return
    }
    
    if viewController.presentingViewController != nil {
        viewController.dismiss(animated: animated)
    }
}

extension Reactive where Base: UIImagePickerController {
    public static func createWithParent(_ parent: UIViewController?,
                                 animated: Bool = true,
                                 configureImagePicker: @escaping (UIImagePickerController) throws -> () = { x in }) -> Observable<UIImagePickerController> {
        
        return Observable.create { [weak parent] observer in
            let imagePicker = UIImagePickerController()
            
            let dismissDisposable = Observable.merge(
                imagePicker.rx.didFinishPickingMediaWithInfo.map { _ in () },
                imagePicker.rx.didCancel
                )
                .subscribe(onNext: { _ in
                    observer.on(.completed)
                })
            
            do {
                try configureImagePicker(imagePicker)
            }
            catch let error {
                observer.on(.error(error))
                return Disposables.create()
            }
            
            guard let parent = parent else {
                observer.on(.completed)
                return Disposables.create()
            }
            
            parent.present(imagePicker, animated: animated, completion: nil)
            
            observer.on(.next(imagePicker))
            
            return Disposables.create(dismissDisposable, Disposables.create {
                dismissViewController(imagePicker, animated: animated)
            })
        }
    }
}

