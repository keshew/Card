import SwiftUI
import AdjustSdk
import WebKit

struct CardMenuModel {
    
}

class AdjustHandler: NSObject, AdjustDelegate {
    var adjustJsonResponse: String? = nil
    var lastAttribution: ADJAttribution?
    
    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        guard let attr = attribution else { return }
        lastAttribution = attr
        print("Adjust lastAttribution ready: \(lastAttribution)")
        if let jsonDict = attr.jsonResponse,
           let data = try? JSONSerialization.data(withJSONObject: jsonDict),
           let jsonString = String(data: data, encoding: .utf8) {
            adjustJsonResponse = jsonString
            print("Adjust jsonResponse ready: \(jsonString)")
        } else {
            adjustJsonResponse = nil
            print("Adjust jsonResponse is nil or not a dictionary")
        }
    }
}
