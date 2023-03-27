import SwiftUI

struct MGDNSSettingView: View {
    
    @EnvironmentObject  private var packetTunnelManager:    MGPacketTunnelManager
    @ObservedObject private var dnsViewModel: MGDNSViewModel
    
    init(dnsViewModel: MGDNSViewModel) {
        self._dnsViewModel = ObservedObject(initialValue: dnsViewModel)
    }
    
    var body: some View {
        Form {
            
        }
        .navigationTitle(Text("DNS 设置"))
        .navigationBarTitleDisplayMode(.large)
    }
}
