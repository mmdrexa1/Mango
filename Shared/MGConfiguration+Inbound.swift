import Foundation

extension MGConfiguration {
    
    private static let inboundStoreKey = "XRAY_INBOUND_DATA"
    
    public struct Inbound: Codable, Equatable {
        
        public struct DestinationOverride: RawRepresentable, Codable, Equatable {
            
            public let rawValue: String
            
            public init(rawValue: String) {
                self.rawValue = rawValue
            }
            
            public static let http      = DestinationOverride(rawValue: "http")
            public static let tls       = DestinationOverride(rawValue: "tls")
            public static let quic      = DestinationOverride(rawValue: "quic")
            public static let fakedns   = DestinationOverride(rawValue: "fakedns")
        }
        
        public struct Sniffing: Codable, Equatable {
            public var enabled: Bool
            public var destOverride: [DestinationOverride]
            public var metadataOnly: Bool
            public var routeOnly: Bool
            public var excludedDomains: [String]
        }
        
        public enum Tag: String, Codable, Equatable {
            case socks  = "socks-in"
            case dns    = "dns-in"
        }
        
        private struct Settings: Codable, Equatable {
            private var udp = true
            private var auth = "noauth"
        }
        
        private var listen = "[::1]"
        private var `protocol` = "socks"
        private var settings = Settings()
        private var tag = Tag.socks
        
        public var port: Int = 8080
        public var sniffing: Sniffing = Sniffing(
            enabled: true,
            destOverride: [.http, .tls],
            metadataOnly: false,
            routeOnly: false,
            excludedDomains: []
        )
        
        public static let `default` = Inbound()
        
        public static var current: Inbound {
            do {
                guard let data = UserDefaults.shared.data(forKey: MGConfiguration.inboundStoreKey) else {
                    return .default
                }
                return try JSONDecoder().decode(MGConfiguration.Inbound.self, from: data)
            } catch {
                return .default
            }
        }
    }
}
