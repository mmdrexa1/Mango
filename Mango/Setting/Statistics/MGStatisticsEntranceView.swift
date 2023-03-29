import SwiftUI

struct MGStatisticsEntranceView: View {
    
    var body: some View {
        NavigationLink {
            MGStatisticsView()
        } label: {
            Label("Statistics", systemImage: "chart.xyaxis.line")
        }
    }
}
