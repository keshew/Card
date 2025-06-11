import Foundation

class NetworkManager {
    private let apiURL = URL(string: "https://redcard.space/app.php")!
    
    func checkBonusStatus(completion: @escaping (Result<(canGetBonus: Bool, remainingSeconds: Int, formattedTime: String), Error>) -> Void) {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                let statusError = NSError(domain: "NetworkManager",
                                          code: 0,
                                          userInfo: [NSLocalizedDescriptionKey: "Некорректный ответ от сервера"])
                completion(.failure(statusError))
                return
            }
            
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let canGetBonus = jsonObject["can_get_bonus"] as? Bool,
                   let remainingSeconds = jsonObject["remaining_seconds"] as? Int,
                   let formattedTime = jsonObject["formatted_time"] as? String {
                    completion(.success((canGetBonus, remainingSeconds, formattedTime)))
                } else {
                    let parseError = NSError(domain: "NetworkManager",
                                             code: 0,
                                             userInfo: [NSLocalizedDescriptionKey: "Невозможно распарсить JSON"])
                    completion(.failure(parseError))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func startBonus(completion: @escaping (Result<(success: Bool, message: String, nextAvailableIn: Int?), Error>) -> Void) {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonBody = ["action": "start"]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                let statusError = NSError(domain: "NetworkManager",
                                          code: 0,
                                          userInfo: [NSLocalizedDescriptionKey: "Некорректный ответ от сервера"])
                completion(.failure(statusError))
                return
            }
            
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let success = jsonObject["result"] as? Bool,
                       let message = jsonObject["message"] as? String {
                        let nextAvailableIn = jsonObject["next_available_in"] as? Int
                        completion(.success((success, message, nextAvailableIn)))
                    } else if let errorMessage = jsonObject["error"] as? String {
                        let serverError = NSError(domain: "NetworkManager",
                                                  code: 0,
                                                  userInfo: [NSLocalizedDescriptionKey: errorMessage])
                        completion(.failure(serverError))
                    } else {
                        let parseError = NSError(domain: "NetworkManager",
                                                 code: 0,
                                                 userInfo: [NSLocalizedDescriptionKey: "Невозможно распарсить JSON"])
                        completion(.failure(parseError))
                    }
                } else {
                    let parseError = NSError(domain: "NetworkManager",
                                             code: 0,
                                             userInfo: [NSLocalizedDescriptionKey: "Невозможно распарсить JSON"])
                    completion(.failure(parseError))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
