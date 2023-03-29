import SwiftUI

struct MGRouteEntranceView: View {
    
    @StateObject private var routeViewModel = MGConfigurationPersistentViewModel<MGConfiguration.Route>()
    @StateObject private var assetViewModel = MGAssetViewModel()
    
    var body: some View {
        NavigationLink {
            MGRouteSettingView(routeViewModel: routeViewModel, assetViewModel: assetViewModel)
        } label: {
            Label("Route", systemImage: "arrow.triangle.branch")
        }
        .onAppear {
            assetViewModel.reload()
        }
    }
}
