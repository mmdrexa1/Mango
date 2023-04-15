import SwiftUI

struct MGOutboundView: View {
    
    @StateObject private var outboundViewModel = MGConfigurationPersistentViewModel<MGConfiguration.OutboundSettings>()
    
    var body: some View {
        Form {
            Section("Freedom") {
                LabeledContent("策略") {
                    Picker("", selection: $outboundViewModel.model.freedom.freedomSettings.domainStrategy) {
                        ForEach(MGConfiguration.Outbound.FreedomSettings.DomainStrategy.allCases) { ds in
                            Text(ds.description)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                }
                LabeledContent("重定向") {
                    TextField("", text: Binding(get: {
                        outboundViewModel.model.freedom.freedomSettings.redirect ?? ""
                    }, set: { value in
                        let reval = value.trimmingCharacters(in: .whitespacesAndNewlines)
                        outboundViewModel.model.freedom.freedomSettings.redirect = reval.isEmpty ? nil : reval
                    }))
                }
            }
            Section("Blackhole") {
                LabeledContent("响应类型") {
                    Picker("", selection: $outboundViewModel.model.blackhole.blackholeSettings.response.type) {
                        ForEach(MGConfiguration.Outbound.BlackholeSettings.ResponseType.allCases) { rt in
                            Text(rt.description)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                }
            }
            Section("DNS") {
                LabeledContent("协议") {
                    Picker("", selection: $outboundViewModel.model.dns.dnsSettings.network) {
                        ForEach(MGConfiguration.Outbound.DNSSettings.Network.allCases) { nw in
                            Text(nw.description)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                }
                LabeledContent("地址") {
                    TextField("", text: Binding(get: {
                        outboundViewModel.model.dns.dnsSettings.address ?? ""
                    }, set: { value in
                        let reval = value.trimmingCharacters(in: .whitespacesAndNewlines)
                        outboundViewModel.model.dns.dnsSettings.address = reval.isEmpty ? nil : reval
                    }))
                }
                LabeledContent("端口") {
                    TextField("", text: Binding(get: {
                        outboundViewModel.model.dns.dnsSettings.port.flatMap({ "\($0)" }) ?? ""
                    }, set: { value in
                        let reval = value.trimmingCharacters(in: .whitespacesAndNewlines)
                        outboundViewModel.model.dns.dnsSettings.port = Int(reval)
                    }))
                    .keyboardType(.numberPad)
                }
            }
            Section("排序") {
                ForEach(outboundViewModel.model.order) { tag in
                    if tag == .dns {
                        EmptyView()
                    } else {
                        Text(tag.description)
                    }
                }
                .onMove { from, to in
                    outboundViewModel.model.order.move(fromOffsets: from, toOffset: to)
                }
            }
        }
        .onDisappear {
            outboundViewModel.save()
        }
        .lineLimit(1)
        .multilineTextAlignment(.trailing)
        .navigationTitle(Text("出站"))
        .environment(\.editMode, .constant(.active))
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
    }
}
