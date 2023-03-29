import SwiftUI

struct MGSettingsView: View {
            
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    MGNetworkEntranceView()
                } header: {
                    Text("系统")
                }
                Section {
                    MGLogEntranceView()
                    MGDNSEntranceView()
                    MGRouteEntranceView()
                    MGInboundEntranceView()
                    MGOutboundEntranceView()
                    MGStatisticsEntranceView()
                    MGAssetEntranceView()
                } header: {
                    Text("内核")
                }
                Section {
                    LabeledContent {
                        Text(Bundle.appVersion)
                            .monospacedDigit()
                    } label: {
                        Label("应用", systemImage: "app")
                    }
                    LabeledContent {
                        Text("1.8.0")
                            .monospacedDigit()
                    } label: {
                        Label("内核", systemImage: "app.fill")
                    }
                } header: {
                    Text("版本")
                }
                Section {
                    MGVPNResettingView()
                }
            }
            .navigationTitle(Text("设置"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
