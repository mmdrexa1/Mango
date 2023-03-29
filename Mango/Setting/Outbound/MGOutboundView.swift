import SwiftUI

struct MGOutboundView: View {
    
    var body: some View {
        Form {}
        .onDisappear {}
        .navigationTitle(Text("Outbound"))
        .navigationBarTitleDisplayMode(.large)
        .environment(\.editMode, .constant(.active))
    }
}
