import Foundation

extension MGConstant {
    public static let dns: String = "XRAY_DNS_DATA"
}

public struct MGDNSModel: Codable, Equatable {
    
    public enum QueryStrategy: String, Identifiable, CaseIterable, CustomStringConvertible, Codable {
        public var id: Self { self }
        case useIP      = "UseIP"
        case useIPv4    = "UseIPv4"
        case useIPv6    = "UseIPv6"
        public var description: String {
            return self.rawValue
        }
    }
    
    public enum Server: Codable, Equatable {
        public struct Object: Codable, Equatable {
            public var address: String = ""
            public var port: Int = 0
            public var domains: [String] = []
            public var expectIPs: [String] = []
            public var skipFallback: Bool = false
            public var clientIP: String?
        }
        case string(String)
        case object(Object)
    }
    
    public var __osLocalDNS__: [String] = ["1.1.1.1"]
    public var __enable__: Bool = false
    
    public var hosts: [String: [String]]?
    public var servers: [Server]?
    public var clientIp: String?
    public var queryStrategy: QueryStrategy = .useIP
    public var disableCache: Bool = false
    public var disableFallback: Bool = false
    public var disableFallbackIfMatch: Bool = false
    public var tag: String = "dns-in"
    
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
