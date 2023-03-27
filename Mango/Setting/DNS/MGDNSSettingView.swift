import SwiftUI

struct MGDNSSettingView: View {
    
    @EnvironmentObject  private var packetTunnelManager:    MGPacketTunnelManager
    @ObservedObject private var dnsViewModel: MGDNSViewModel
    
    @State private var localDNS: String = ""
    
    init(dnsViewModel: MGDNSViewModel) {
        self._dnsViewModel = ObservedObject(initialValue: dnsViewModel)
    }
    
    var body: some View {
        Form {
            Section {
                ForEach(dnsViewModel.__osLocalDNS__, id: \.self) { dns in
                    Text(dns)
                }
                .onDelete { offsets in
                    dnsViewModel.__osLocalDNS__.remove(atOffsets: offsets)
                }
                HStack(spacing: 18) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.green)
                        .offset(CGSize(width: 2, height: 0))
                    TextField("", text: $localDNS)
                        .onSubmit {
                            let temp = self.localDNS.trimmingCharacters(in: .whitespacesAndNewlines)
                            DispatchQueue.main.async {
                                self.localDNS = ""
                            }
                            guard !temp.isEmpty else {
                                return
                            }
                            guard !self.dnsViewModel.__osLocalDNS__.contains(where: { $0 == temp }) else {
                                return
                            }
                            self.dnsViewModel.__osLocalDNS__.append(temp)
                        }
                        .multilineTextAlignment(.leading)
                }
            } header: {
                Text("SYSTEM")
            }
            Section {
                DisclosureGroup {
                    
                } label: {
                    LabeledContent("Hosts", value: "\(dnsViewModel.hosts.count)")
                }
                DisclosureGroup {
                    ForEach($dnsViewModel.servers) { server in
                        MGDNSServerItemView(server: server)
                    }
                    .onMove { from, to in
                        dnsViewModel.servers.move(fromOffsets: from, toOffset: to)
                    }
                    .onDelete { offsets in
                        dnsViewModel.servers.remove(atOffsets: offsets)
                    }
                } label: {
                    LabeledContent("Servers", value: "\(dnsViewModel.servers.count)")
                }
                LabeledContent {
                    TextField("", text: $dnsViewModel.clientIp)
                } label: {
                    Text("Client IP")
                }
                LabeledContent {
                    Picker("Query Strategy", selection: $dnsViewModel.queryStrategy) {
                        ForEach(MGDNSModel.QueryStrategy.allCases) { strategy in
                            Text(strategy.description)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                } label: {
                    Text("Query Strategy")
                }
                Toggle("Cache", isOn: $dnsViewModel.disableCache)
                Toggle("Fallback", isOn: $dnsViewModel.disableFallback)
                Toggle("Fallback If Match", isOn: $dnsViewModel.disableFallbackIfMatch)
            } header: {
                Text("XRAY")
            }
        }
        .lineLimit(1)
        .multilineTextAlignment(.trailing)
        .environment(\.editMode, .constant(.active))
        .navigationTitle(Text("DNS 设置"))
        .navigationBarTitleDisplayMode(.large)
    }
}

struct MGDNSServerItemView: View {
    
    @Binding var server: MGDNSModel.Server
    
    @State private var isPresented: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            Text(server.address)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isPresented.toggle()
        }
        .sheet(isPresented: $isPresented) {
            MGDNSServerView(server: $server)
        }
    }
}

struct MGDNSServerView: View {
    
    @Binding var server: MGDNSModel.Server
        
    var body: some View {
        EmptyView()
    }
}

struct MGDNSServerEditView: View {
    
    @Binding var server: MGDNSModel.Server
    
    var body: some View {
        if server.__object__ {
            DisclosureGroup(server.address) {
                LabeledContent("Address") {
                    TextField("", text: $server.address)
                }
                .deleteDisabled(true)
                .moveDisabled(true)
                
                LabeledContent("Port") {
                    TextField("", value: $server.port, format: .number)
                }
                .deleteDisabled(true)
                .moveDisabled(true)
                
                DisclosureGroup("Domain") {
                    ForEach(server.domains, id: \.self) { domain in
                        Text(domain)
                            .deleteDisabled(false)
                            .moveDisabled(false)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    .onMove { from, to in
                        server.domains.move(fromOffsets: from, toOffset: to)
                    }
                    .onDelete { offsets in
                        server.domains.remove(atOffsets: offsets)
                    }
                }
                .deleteDisabled(true)
                .moveDisabled(true)

                DisclosureGroup("Expect IP") {
                    ForEach(server.expectIPs, id: \.self) { ip in
                        Text(ip)
                            .deleteDisabled(false)
                            .moveDisabled(false)
                    }
                    .onMove { from, to in
                        server.expectIPs.move(fromOffsets: from, toOffset: to)
                    }
                    .onDelete { offsets in
                        server.expectIPs.remove(atOffsets: offsets)
                    }
                }
                .deleteDisabled(true)
                .moveDisabled(true)

                Toggle("Skip Fallback", isOn: $server.skipFallback)
                    .deleteDisabled(true)
                    .moveDisabled(true)

                LabeledContent("Client IP") {
                    TextField("", text: Binding(get: {
                        server.clientIP ?? ""
                    }, set: { newValue in
                        let reval = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        server.clientIP = reval.isEmpty ? nil : reval
                    }))
                }
                .deleteDisabled(true)
                .moveDisabled(true)
            }
            .multilineTextAlignment(.trailing)
        } else {
            TextField("", text: $server.address)
                .multilineTextAlignment(.leading)
        }
    }
}
