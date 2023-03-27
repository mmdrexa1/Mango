import SwiftUI

struct MGDNSEntranceView: View {
    
    @StateObject private var dnsViewModel = MGDNSViewModel()
    
    var body: some View {
        NavigationLink {
            
        } label: {
            Label("DNS", systemImage: "network")
        }
    }
}
