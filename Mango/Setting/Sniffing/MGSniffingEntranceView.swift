import SwiftUI

struct MGSniffingEntranceView: View {
        
    @StateObject private var sniffingViewModel = MGSniffingViewModel()
    
    var body: some View {
        NavigationLink {
            MGSniffingSettingView(sniffingViewModel: sniffingViewModel)
        } label: {
            LabeledContent {
                Text(sniffingViewModel.enabled ? "打开" : "关闭")
            } label: {
                Label("流量嗅探", systemImage: "magnifyingglass")
            }
        }
    }
}


struct MGInboundEntranceView: View {
        
    @StateObject private var inboundViewModel = MGInboundViewModel()
    
    var body: some View {
        NavigationLink {
            MGInboundView(inboundViewModel: inboundViewModel)
        } label: {
            Label("入站", systemImage: "square.and.arrow.down")
        }
    }
}
