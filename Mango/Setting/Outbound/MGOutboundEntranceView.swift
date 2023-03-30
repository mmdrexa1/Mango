import SwiftUI

struct MGOutboundEntranceView: View {
    
    @StateObject private var outboundViewModel = MGConfigurationPersistentViewModel<MGConfiguration.Outbounds>()

    
    var body: some View {
        NavigationLink {
            MGOutboundView(outboundViewModel: outboundViewModel)
        } label: {
            Label("Outbound", systemImage: "square.and.arrow.up")
        }
    }
}
