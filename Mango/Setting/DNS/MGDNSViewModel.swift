import Foundation

final class MGDNSViewModel: ObservableObject {
    
    @Published var __osLocalDNS__: [String] = ["1.1.1.1"]
    @Published var __enable__: Bool = false
    
    @Published var hosts: [MGDNSModel.Host]
    @Published var servers: [MGDNSModel.Server]
    @Published var clientIp: String
    @Published var queryStrategy: MGDNSModel.QueryStrategy = .useIP
    @Published var disableCache: Bool = false
    @Published var disableFallback: Bool = false
    @Published var disableFallbackIfMatch: Bool = false
    @Published var tag: String = "dns-in"
    
    init() {
        let model = MGDNSModel.current
        self.__osLocalDNS__ = model.__osLocalDNS__
        self.__enable__ = model.__enable__
        self.hosts = model.hosts ?? []
        self.servers = model.servers ?? []
        self.clientIp = model.clientIp ?? ""
        self.queryStrategy = model.queryStrategy
        self.disableCache = model.disableCache
        self.disableFallback = model.disableFallback
        self.disableFallbackIfMatch = model.disableFallbackIfMatch
    }
    
    func save(updated: () -> Void) {
        do {
            let model = MGDNSModel(
                __osLocalDNS__: self.__osLocalDNS__,
                __enable__: self.__enable__,
                hosts: self.hosts.isEmpty ? nil : self.hosts,
                servers: self.servers.isEmpty ? nil : self.servers,
                clientIp: self.clientIp.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : self.clientIp,
                queryStrategy: self.queryStrategy,
                disableCache: self.disableCache,
                disableFallback: self.disableFallback,
                disableFallbackIfMatch: self.disableFallbackIfMatch
            )
            guard model != .current else {
                return
            }
            UserDefaults.shared.set(try JSONEncoder().encode(model), forKey: MGConstant.dns)
            updated()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
