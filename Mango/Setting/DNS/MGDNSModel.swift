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
        public var domains: [String] = []
        public var expectIPs: [String] = []
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
        
        init() {}
        
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
    
    public struct Host: Codable, Equatable, Identifiable {
        public var id: UUID = UUID()
        public var key: String = ""
        public var values: [String] = []
    }
    
    public var __osLocalDNS__: [String]
    public var __enable__: Bool
    
    public var hosts: [Host]?
    public var servers: [Server]?
    public var clientIp: String?
    public var queryStrategy: QueryStrategy
    public var disableCache: Bool
    public var disableFallback: Bool
    public var disableFallbackIfMatch: Bool
    public var tag: String
    
    
    private enum CodingKeys: String, CodingKey {
        case __osLocalDNS__
        case __enable__
        case hosts
        case servers
        case clientIp
        case queryStrategy
        case disableCache
        case disableFallback
        case disableFallbackIfMatch
        case tag
    }
    
    public init(
        __osLocalDNS__: [String] = ["1.1.1.1"],
        __enable__: Bool = false,
        hosts: [Host]? = nil,
        servers: [Server]? = nil,
        clientIp: String? = nil,
        queryStrategy: QueryStrategy = .useIP,
        disableCache: Bool = false,
        disableFallback: Bool = false,
        disableFallbackIfMatch: Bool = false
    ) {
        self.__osLocalDNS__ = __osLocalDNS__
        self.__enable__ = __enable__
        self.hosts = hosts
        self.servers = servers
        self.clientIp = clientIp
        self.queryStrategy = queryStrategy
        self.disableCache = disableCache
        self.disableFallback = disableFallback
        self.disableFallbackIfMatch = disableFallbackIfMatch
        self.tag = "dns-in"
    }
        
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.__osLocalDNS__ = try container.decode([String].self, forKey: .__osLocalDNS__)
        self.__enable__ = try container.decode(Bool.self, forKey: .__enable__)
        let mapping = try container.decode(Optional<[String: [String]]>.self, forKey: .hosts)
        self.hosts = mapping.flatMap({ mapping in
            mapping.reduce(into: [Host]()) { result, pair in
                result.append(Host(id: UUID(), key: pair.key, values: pair.value))
            }
        })
        self.servers = try container.decode(Optional<[Server]>.self, forKey: .servers)
        self.clientIp = try container.decode(Optional<String>.self, forKey: .clientIp)
        self.queryStrategy = try container.decode(QueryStrategy.self, forKey: .queryStrategy)
        self.disableCache = try container.decode(Bool.self, forKey: .disableCache)
        self.disableFallback = try container.decode(Bool.self, forKey: .disableFallback)
        self.disableFallbackIfMatch = try container.decode(Bool.self, forKey: .disableFallbackIfMatch)
        self.tag = try container.decode(String.self, forKey: .tag)

    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.__osLocalDNS__, forKey: .__osLocalDNS__)
        try container.encode(self.__enable__, forKey: .__enable__)
        let mapping = self.hosts.flatMap { hosts in
            hosts.reduce(into: [String: [String]]()) { result, host in
                result[host.key] = host.values
            }
        }
        try container.encode(mapping, forKey: .hosts)
        try container.encode(self.servers, forKey: .servers)
        try container.encode(self.clientIp, forKey: .clientIp)
        try container.encode(self.queryStrategy, forKey: .queryStrategy)
        try container.encode(self.disableCache, forKey: .disableCache)
        try container.encode(self.disableFallback, forKey: .disableFallback)
        try container.encode(self.disableFallbackIfMatch, forKey: .disableFallbackIfMatch)
        try container.encode(self.tag, forKey: .tag)

    }
    
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
