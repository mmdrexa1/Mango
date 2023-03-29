import SwiftUI

struct MGOutboundEntranceView: View {
    
    var body: some View {
        NavigationLink {
            MGOutboundView()
        } label: {
            Label("Outbound", systemImage: "square.and.arrow.up")
        }
    }
}
