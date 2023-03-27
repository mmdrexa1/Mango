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
    
    public struct Server: Codable, Equatable, Identifiable {
        
        public var __object__ = false
        public var __uuid__ = UUID()
        public var id: UUID {
            self.__uuid__
        }
        
        public var address: String = ""
        public var port: Int = 0
        public var domains: [String] = ["a", "c", "c"]
        public var expectIPs: [String] = ["da", "d", "e"]
        public var skipFallback: Bool = false
        public var clientIP: String?
        
        private enum CodingKeys: CodingKey {
            case address
            case port
            case domains
            case expectIPs
            case skipFallback
            case clientIP
        }
        
        init() {
            self.__object__ = .random()
        }
        
        public init(from decoder: Decoder) throws {
            do {
                let container = try decoder.singleValueContainer()
                self.address = try container.decode(String.self)
                self.__object__ = false
            } catch {
                let container = try decoder.container(keyedBy: MGDNSModel.Server.CodingKeys.self)
                self.__object__ = true
                self.__uuid__ = UUID()
                self.address = try container.decode(String.self, forKey: MGDNSModel.Server.CodingKeys.address)
                self.port = try container.decode(Int.self, forKey: MGDNSModel.Server.CodingKeys.port)
                self.domains = try container.decode([String].self, forKey: MGDNSModel.Server.CodingKeys.domains)
                self.expectIPs = try container.decode([String].self, forKey: MGDNSModel.Server.CodingKeys.expectIPs)
                self.skipFallback = try container.decode(Bool.self, forKey: MGDNSModel.Server.CodingKeys.skipFallback)
                self.clientIP = try container.decodeIfPresent(String.self, forKey: MGDNSModel.Server.CodingKeys.clientIP)
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            if self.__object__ {
                var container = encoder.container(keyedBy: MGDNSModel.Server.CodingKeys.self)
                try container.encode(self.address, forKey: MGDNSModel.Server.CodingKeys.address)
                try container.encode(self.port, forKey: MGDNSModel.Server.CodingKeys.port)
                try container.encode(self.domains, forKey: MGDNSModel.Server.CodingKeys.domains)
                try container.encode(self.expectIPs, forKey: MGDNSModel.Server.CodingKeys.expectIPs)
                try container.encode(self.skipFallback, forKey: MGDNSModel.Server.CodingKeys.skipFallback)
                try container.encodeIfPresent(self.clientIP, forKey: MGDNSModel.Server.CodingKeys.clientIP)
            } else {
                var container = encoder.singleValueContainer()
                try container.encode(self.address)
            }
        }
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
