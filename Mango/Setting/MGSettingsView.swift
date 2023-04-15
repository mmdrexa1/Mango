import SwiftUI

struct MGSettingsView: View {
    
    enum Destination: String, Identifiable, Hashable, Codable, CaseIterable {
        var id: Self { self }
        case log
        case asset
        case dns
        case route
        case inbound
        case outbound
        var title: String {
            switch self {
            case .log:      return "日志"
            case .asset:    return "资源"
            case .dns:      return "DNS"
            case .route:    return "路由"
            case .inbound:  return "入站"
            case .outbound: return "出站"
            }
        }
        var systemImage: String {
            switch self {
            case .log:      return "doc"
            case .asset:    return "folder"
            case .dns:      return "network"
            case .route:    return "arrow.triangle.branch"
            case .inbound:  return "square.and.arrow.down"
            case .outbound: return "square.and.arrow.up"
            }
        }
    }
                
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(Destination.allCases) { destination in
                        NavigationLink(value: destination) {
                            Label(destination.title, systemImage: destination.systemImage)
                        }
                    }
                }
                Section {
                    MGVPNResettingView()
                }
            }
            .navigationTitle(Text("设置"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .log:
                    MGLogSettingView()
                case .asset:
                    MGAssetView()
                case .dns:
                    MGDNSSettingView()
                case .route:
                    MGRouteSettingView()
                case .inbound:
                    MGInboundView()
                case .outbound:
                    MGOutboundView()
                }
            }
        }
    }
}
