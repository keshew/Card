import Foundation

class ClientResponse: Codable {
    var client_id: String
    var response: String?
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case client_id
        case response
    }
}
