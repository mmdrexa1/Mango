import Foundation

extension MGConfiguration {
    
    public struct Log: Codable, Equatable, MGConfigurationPersistentModel {
        
        public enum Severity: Int, Codable, Equatable, CaseIterable, Identifiable {
            public var id: Self { self }
            case none       = 0
            case error      = 1
            case warning    = 2
            case info       = 3
            case debug      = 4
        }
        
        public var accessLogEnabled = false
        public var dnsLogEnabled = false
        public var errorLogSeverity = Severity.none
        
        public static let storeKey = "XRAY_LOG_DATA"
        public static let defaultValue = Log()
    }
}
