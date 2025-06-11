import SwiftUI
import UIKit
@preconcurrency import WebKit

class CreateAccountManagerViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var newPopupWindow: WKWebView?
    
    override func viewDidLoad() {
    }
    
    func showControls() async {
        let content = UserDefaults.standard.string(forKey: "taskLink") ?? ""
        
        if !content.isEmpty, let url = URL(string: content) {
            loadCookie()
            
            await MainActor.run {
                self.webView = WKWebView(frame: view.frame)
                self.webView.navigationDelegate = self
                
                self.loadInfo(with: url)
            }
        }
    }
    
    func loadInfo(with url: URL) {
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        saveCookie()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let response = navigationResponse.response as? HTTPURLResponse {
            let status = response.statusCode
            print("HTTP Status: \(status)")
            
            if (300...399).contains(status) {
                print("Redirect status, allowing navigation")
            }
            else if status == 200 {
                if webView.superview == nil {
                    let whiteBG = UIView(frame: view.frame)
                    whiteBG.tag = 11
                    view.addSubview(whiteBG)
                    view.addSubview(self.webView)
                    
                    self.webView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        self.webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                        self.webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                        self.webView.topAnchor.constraint(equalTo: view.topAnchor),
                        self.webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                    ])
                    
                    let iosVersionRaw = UIDevice.current.systemVersion
                    let iosVersion = iosVersionRaw.replacingOccurrences(of: ".", with: "_")
                    
                    let devicePart: String
                    switch UIDevice.current.userInterfaceIdiom {
                    case .phone:
                        devicePart = "iPhone; CPU iPhone OS \(iosVersion) like Mac OS X"
                    case .pad:
                        devicePart = "iPad; CPU OS \(iosVersion) like Mac OS X"
                    default:
                        devicePart = "iPhone; CPU iPhone OS \(iosVersion) like Mac OS X"
                    }
                    
                    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "15E148"
                    
                    let iosVersionComponents = iosVersionRaw.split(separator: ".")
                    let safariVersion: String
                    if iosVersionComponents.count >= 2 {
                        safariVersion = "\(iosVersionComponents[0]).\(iosVersionComponents[1])"
                    } else {
                        safariVersion = iosVersionRaw
                    }
                    
                    let customUserAgent = "Mozilla/5.0 (\(devicePart)) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(safariVersion) Mobile/\(buildNumber) Safari/604.1"
                    
                    print("Установлен кастомный User-Agent: \(customUserAgent)")
                    UserDefaults.standard.set(customUserAgent, forKey: "customAgent")
                    
                    DispatchQueue.main.async {
                        self.webView.customUserAgent = customUserAgent
                    }
                }
            }
            else if status >= 400 {
                print("Ошибка. Сервер вернул ошибку (\(status)).")
            }
        }
        decisionHandler(.allow)
    }

    func loadCookie() {
        let ud: UserDefaults = UserDefaults.standard
        let data: Data? = ud.object(forKey: "cookie") as? Data
        if let cookie = data {
            do {
                let datas: NSArray? = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: cookie)
                if let cookies = datas {
                    for c in cookies {
                        if let cookieObject = c as? HTTPCookie {
                            HTTPCookieStorage.shared.setCookie(cookieObject)
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveCookie() {
        let cookieJar: HTTPCookieStorage = HTTPCookieStorage.shared
        if let cookies = cookieJar.cookies {
            do {
                let data: Data = try NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false)
                let ud: UserDefaults = UserDefaults.standard
                ud.set(data, forKey: "cookie")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
