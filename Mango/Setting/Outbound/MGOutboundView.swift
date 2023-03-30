import SwiftUI

struct MGOutboundView: View {
    
    @ObservedObject private var outboundViewModel: MGConfigurationPersistentViewModel<MGConfiguration.OutboundSettings>
    
    init(outboundViewModel: MGConfigurationPersistentViewModel<MGConfiguration.OutboundSettings>) {
        self._outboundViewModel = ObservedObject(initialValue: outboundViewModel)
    }
    
    var body: some View {
        Form {
            Section("Freedom") {
                LabeledContent("Domain Strategy") {
                    Picker("", selection: $outboundViewModel.model.freedom.freedom.domainStrategy) {
                        ForEach(MGConfiguration.Outbound.FreedomSettings.DomainStrategy.allCases) { ds in
                            Text(ds.description)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                }
                LabeledContent("Redirect") {
                    TextField("", text: Binding(get: {
                        outboundViewModel.model.freedom.freedom.redirect ?? ""
                    }, set: { value in
                        let reval = value.trimmingCharacters(in: .whitespacesAndNewlines)
                        outboundViewModel.model.freedom.freedom.redirect = reval.isEmpty ? nil : reval
                    }))
                }
            }
            Section("Blackhole") {
                LabeledContent("Response Type") {
                    Picker("", selection: $outboundViewModel.model.blackhole.blackhole.response.type) {
                        ForEach(MGConfiguration.Outbound.BlackholeSettings.ResponseType.allCases) { rt in
                            Text(rt.description)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                }
            }
            Section("DNS") {
                LabeledContent("Network") {
                    Picker("", selection: $outboundViewModel.model.dns.dns.network) {
                        ForEach(MGConfiguration.Outbound.DNSSettings.Network.allCases) { nw in
                            Text(nw.description)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                }
                LabeledContent("Address") {
                    TextField("", text: Binding(get: {
                        outboundViewModel.model.dns.dns.address ?? ""
                    }, set: { value in
                        let reval = value.trimmingCharacters(in: .whitespacesAndNewlines)
                        outboundViewModel.model.dns.dns.address = reval.isEmpty ? nil : reval
                    }))
                }
                LabeledContent("Port") {
                    TextField("", text: Binding(get: {
                        outboundViewModel.model.dns.dns.port.flatMap({ "\($0)" }) ?? ""
                    }, set: { value in
                        let reval = value.trimmingCharacters(in: .whitespacesAndNewlines)
                        outboundViewModel.model.dns.dns.port = Int(reval)
                    }))
                    .keyboardType(.numberPad)
                }
            }
            Section("Order") {
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
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(Text("Outbound"))
        .navigationBarTitleDisplayMode(.large)
        .environment(\.editMode, .constant(.active))
    }
}
