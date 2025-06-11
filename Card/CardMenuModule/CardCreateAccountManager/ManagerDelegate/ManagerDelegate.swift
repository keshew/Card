import SwiftUI
@preconcurrency import WebKit

extension CreateAccountManagerViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        newPopupWindow = WKWebView(frame: view.bounds, configuration: configuration)
        newPopupWindow!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        newPopupWindow!.navigationDelegate = self
        newPopupWindow?.uiDelegate = self
        view.addSubview(newPopupWindow!)
        return newPopupWindow!
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        webView.removeFromSuperview()
        newPopupWindow = nil
    }
}
