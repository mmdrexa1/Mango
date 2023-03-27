import Foundation

extension MGConstant {
    public static let dns: String = "XRAY_DNS_DATA"
}

public struct MGDNSModel: Codable, Equatable {
    
    public static let `default` = MGDNSModel()
    
    public static var current: MGDNSModel {
        do {
            guard let data = UserDefaults.shared.data(forKey: MGConstant.dns) else {
                return .default
            }
            return try JSONDecoder().decode(MGDNSModel.self, from: data)
        } catch {
            return .default
        }
    }
}
