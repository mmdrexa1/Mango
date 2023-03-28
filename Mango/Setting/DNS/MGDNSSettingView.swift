import SwiftUI

struct MGDNSSettingView: View {
    
    @EnvironmentObject  private var packetTunnelManager: MGPacketTunnelManager
    @ObservedObject private var dnsViewModel: MGDNSViewModel
    
    @State private var localDNS: String = ""
    
    init(dnsViewModel: MGDNSViewModel) {
        self._dnsViewModel = ObservedObject(initialValue: dnsViewModel)
    }
    
    var body: some View {
        Form {
            Section {
                MGStringListEditor(strings: $dnsViewModel.__osLocalDNS__, placeholder: nil)
            } header: {
                Text("SYSTEM")
            }
            Section {
                MGDisclosureGroup {
                    ForEach($dnsViewModel.hosts) { host in
                        MGDNSHostItemView(host: host)
                    }
                    .onMove { from, to in
                        dnsViewModel.hosts.move(fromOffsets: from, toOffset: to)
                    }
                    .onDelete { offsets in
                        dnsViewModel.hosts.remove(atOffsets: offsets)
                    }
                    Button("Add") {
                        withAnimation {
                            dnsViewModel.hosts.append(MGDNSModel.Host())
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 52, bottom: 0, trailing: 16))
                } label: {
                    LabeledContent("Hosts", value: "\(dnsViewModel.hosts.count)")
                }
                MGDisclosureGroup {
                    ForEach($dnsViewModel.servers) { server in
                        MGDNSServerItemView(server: server)
                    }
                    .onMove { from, to in
                        dnsViewModel.servers.move(fromOffsets: from, toOffset: to)
                    }
                    .onDelete { offsets in
                        dnsViewModel.servers.remove(atOffsets: offsets)
                    }
                    Button("Add") {
                        withAnimation {
                            dnsViewModel.servers.append(MGDNSModel.Server())
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 52, bottom: 0, trailing: 16))
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
        .navigationTitle(Text("DNS"))
        .navigationBarTitleDisplayMode(.large)
    }
}

struct MGDNSHostItemView: View {
    
    @Binding var host: MGDNSModel.Host
    
    @State private var isPresented: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            Text(host.key)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isPresented.toggle()
        }
        .sheet(isPresented: $isPresented) {
            MGDNSHostView(host: $host)
        }
    }
}

struct MGDNSHostView: View {
    
    @Binding var host: MGDNSModel.Host
        
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("", text: $host.key)
                        .multilineTextAlignment(.leading)
                } header: {
                    Text("Key")
                }
                Section {
                    MGStringListEditor(strings: $host.values, placeholder: nil)
                        .moveDisabled(true)
                } header: {
                    Text("Values")
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Host")
            .toolbar(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
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
        NavigationStack {
            Form {
                Section {
                    Picker(selection: $server.__object__) {
                        ForEach([false, true], id: \.self) { bool in
                            Text(bool ? "OBJECT" : "STRING")
                        }
                    } label: {
                        EmptyView()
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                }
                if server.__object__ {
                    Section {
                        LabeledContent("Address") {
                            TextField("", text: $server.address)
                        }
                        LabeledContent("Port") {
                            TextField("", value: $server.port, format: .number)
                        }
                        MGDisclosureGroup {
                            MGStringListEditor(strings: $server.domains, placeholder: nil)
                        } label: {
                            LabeledContent("Domain", value: "\(server.domains.count)")
                        }
                        MGDisclosureGroup {
                            MGStringListEditor(strings: $server.expectIPs, placeholder: nil)
                        } label: {
                            LabeledContent("Expect IP", value: "\(server.expectIPs.count)")
                        }
                        Toggle("Skip Fallback", isOn: $server.skipFallback)
                        LabeledContent("Client IP") {
                            TextField("", text: Binding(get: {
                                server.clientIP ?? ""
                            }, set: { newValue in
                                let reval = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                                server.clientIP = reval.isEmpty ? nil : reval
                            }))
                        }
                    }
                    .multilineTextAlignment(.trailing)
                } else {
                    Section {
                        TextField("", text: $server.address)
                    }
                    .multilineTextAlignment(.leading)
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle(Text("Server"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
