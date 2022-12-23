//
//  RxBaseWebViewController.swift
//  Community
//
//  Created by mac on 2019/9/28.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit

open class HLWebViewController: HLViewController, WKUIDelegate {
    
    open var autoGetWebViewTitle: Bool {
        return true
    }

    open lazy var webView = createWebView()
    public lazy var wireframe = DefaultWireframe()
    
    lazy var progressView : UIProgressView = UIProgressView.init(frame: CGRect(origin: .zero, size: CGSize(width: kScreenW, height: 4)))
    let keyPathForProgress : String = "estimatedProgress"
    
    func initProgress() {
        progressView.tintColor = UIColor.systemGreen
        webView.addSubview(progressView)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    open func createWebView() -> WKWebView {
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true // default value is
       
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.userContentController = WKUserContentController()
                
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.backgroundColor = .white
        return webView
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        webView.delegate = self
//        webView.scalesPageToFit = true
                    
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        initProgress()
    }

    override open func bindConfig() {
        super.bindConfig()
        
        webView.rx.observeWeakly(Dictionary<String, Any>.self, keyPathForProgress)
            .take(until: rx.deallocated)
            .subscribe(onNext: {[weak self] change in
                self?.changeProgress()
            }).disposed(by: disposeBag)
    }
    
    func changeProgress() {
        progressView.alpha = 1.0
        progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
        if self.webView.estimatedProgress >= 1.0 {
            UIView.animate(withDuration: 0.25, delay: 0.1, options: .curveEaseOut, animations: {
                self.progressView.alpha = 0
            }, completion: { (finish) in
                self.progressView.setProgress(0.0, animated: false)
            })
        }
    }

    open func loadRequest(localResource: String, type: String = "docx") -> Self {

        guard let filePath = Bundle.main.path(forResource: localResource, ofType: type) else {
            return self
        }
        do {
            let fileData = try Data(contentsOf: URL(fileURLWithPath: filePath))
//            webView.load(fileData,
//                         mimeType: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
//                         textEncodingName: "UTF-8",
//                         baseURL: URL(fileURLWithPath: filePath))
            DispatchQueue.main.async {
                self.webView.load(fileData, mimeType: "application/vnd.openxmlformats-officedocument.wordprocessingml.document", characterEncodingName: "UTF-8", baseURL: URL(fileURLWithPath: filePath))
            }
            
        } catch {
        }

        return self
    }

    open func loadRequest(url: URL) -> Self {
        
        let request = URLRequest(url: url)
        DispatchQueue.main.async {
            self.webView.load(request)
        }
        return self
    }

    public var htmlString: String?
    open func loadRequest(htmlString: String) -> Self {
        self.htmlString = htmlString
        self.webView.loadHTMLString(htmlString, baseURL: nil)
        return self
    }
    
    func getTitle() {
        if autoGetWebViewTitle == false { return }
        self.webView.evaluateJavaScript("document.title") { (result, error) -> Void in
            if error == nil, let string = result as? String {
                DispatchQueue.main.async {
                    self.title = string
                }
            }
        }
    }
}

extension HLWebViewController: WKNavigationDelegate {

    open func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        NSLog("开始加载网页")
    }

    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        NSLog("网页加载完毕")
        getTitle()
    }

    open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        NSLog("网页加载失败: \(error)")
    }
    
    open func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        #if DEBUG
        if let urlString = navigationAction.request.url?.absoluteString {
            print("🥳 === \(urlString)")
        }
        #endif

//        if navigationAction.targetFrame == nil || navigationAction.targetFrame?.isMainFrame != true {
//            if let strRequest = navigationAction.request.url?.absoluteString.removingPercentEncoding, strRequest.contains("about:blank") == false {
//                webView.load(navigationAction.request)
//            }
//        }
        decisionHandler(.allow)
    }
    
    open func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil || navigationAction.targetFrame?.isMainFrame != true {
            webView.load(navigationAction.request)
        }
        return nil
    }
//    webViewWebContentProcessDidTerminate
    open func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
}
