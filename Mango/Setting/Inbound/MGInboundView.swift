import SwiftUI

struct MGInboundView: View {
        
    @StateObject private var inboundViewModel = MGConfigurationPersistentViewModel<MGConfiguration.Inbound>()
    
    var body: some View {
        Form {
            Section {
                LabeledContent("地址", value: "[::1]")
                LabeledContent("端口") {
                    TextField("", text: Binding(get: {
                        "\(inboundViewModel.model.port)"
                    }, set: { value in
                        if let int = Int(value) {
                            inboundViewModel.model.port = int
                        } else {
                            inboundViewModel.model.port = 0
                        }
                    }))
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
                }
            } header: {
                Text("SOSCK5")
            }
            Section {
                Toggle("状态", isOn: $inboundViewModel.model.sniffing.enabled)
                VStack(alignment: .leading) {
                    Text("流量类型")
                    HStack {
                        ForEach(MGConfiguration.Inbound.DestinationOverride.allCases, id: \.rawValue) { `override` in
                            MGToggleButton(title: `override`.description, isOn: Binding(get: {
                                inboundViewModel.model.sniffing.destOverride.contains(`override`)
                            }, set: { value in
                                if value {
                                    inboundViewModel.model.sniffing.destOverride.insert(`override`)
                                } else {
                                    inboundViewModel.model.sniffing.destOverride.remove(`override`)
                                }
                            }))
                        }
                    }
                }
                Toggle("使用元数据", isOn: $inboundViewModel.model.sniffing.metadataOnly)
                Toggle("仅用于路由", isOn: $inboundViewModel.model.sniffing.routeOnly)
            } header: {
                Text("流量嗅探")
            }
        }
        .onDisappear {
            inboundViewModel.save()
        }
        .navigationTitle(Text("入站"))
        .toolbar(.hidden, for: .tabBar)
        .environment(\.editMode, .constant(.active))
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
    }
}
