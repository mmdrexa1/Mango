import SwiftUI

struct MGStatisticsView: View {
    
    var body: some View {
        Form {}
        .onDisappear {}
        .navigationTitle(Text("Statistics"))
        .navigationBarTitleDisplayMode(.large)
        .environment(\.editMode, .constant(.active))
    }
}
