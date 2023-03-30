import SwiftUI

struct MGDNSSettingView: View {
    
    @ObservedObject private var dnsViewModel: MGConfigurationPersistentViewModel<MGConfiguration.DNS>
    
    @State private var localDNS: String = ""
    
    init(dnsViewModel: MGConfigurationPersistentViewModel<MGConfiguration.DNS>) {
        self._dnsViewModel = ObservedObject(initialValue: dnsViewModel)
    }
    
    var body: some View {
        Form {
            Section {
                MGDisclosureGroup {
                    ForEach(Binding(get: {
                        dnsViewModel.model.hosts ?? []
                    }, set: { value in
                        dnsViewModel.model.hosts = value
                    })) { host in
                        MGDNSHostItemView(host: host)
                    }
                    .onMove { from, to in
                        dnsViewModel.model.hosts?.move(fromOffsets: from, toOffset: to)
                    }
                    .onDelete { offsets in
                        dnsViewModel.model.hosts?.remove(atOffsets: offsets)
                    }
                    Button("Add") {
                        withAnimation {
                            if dnsViewModel.model.hosts == nil {
                                dnsViewModel.model.hosts = [MGConfiguration.DNS.Host()]

                            } else {
                                dnsViewModel.model.hosts?.append(MGConfiguration.DNS.Host())
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 52, bottom: 0, trailing: 16))
                } label: {
                    LabeledContent("Hosts", value: "\(dnsViewModel.model.hosts?.count ?? 0)")
                }
                MGDisclosureGroup {
                    ForEach(Binding(get: {
                        dnsViewModel.model.servers ?? []
                    }, set: { value in
                        dnsViewModel.model.servers = value
                    })) { server in
                        MGDNSServerItemView(server: server)
                    }
                    .onMove { from, to in
                        dnsViewModel.model.servers?.move(fromOffsets: from, toOffset: to)
                    }
                    .onDelete { offsets in
                        dnsViewModel.model.servers?.remove(atOffsets: offsets)
                    }
                    Button("Add") {
                        withAnimation {
                            if dnsViewModel.model.servers == nil {
                                dnsViewModel.model.servers = [MGConfiguration.DNS.Server()]

                            } else {
                                dnsViewModel.model.servers?.append(MGConfiguration.DNS.Server())
                            }
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 52, bottom: 0, trailing: 16))
                } label: {
                    LabeledContent("Servers", value: "\(dnsViewModel.model.servers?.count ?? 0)")
                }
                LabeledContent {
                    TextField("", text: Binding(get: {
                        dnsViewModel.model.clientIp ?? ""
                    }, set: { value in
                        let reval = value.trimmingCharacters(in: .whitespacesAndNewlines)
                        dnsViewModel.model.clientIp = reval.isEmpty ? nil : reval
                    }))
                } label: {
                    Text("Client IP")
                }
                LabeledContent {
                    Picker("Query Strategy", selection: $dnsViewModel.model.queryStrategy) {
                        ForEach(MGConfiguration.DNS.QueryStrategy.allCases) { strategy in
                            Text(strategy.description)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                } label: {
                    Text("Query Strategy")
                }
                Toggle("Cache", isOn: $dnsViewModel.model.disableCache)
                Toggle("Fallback", isOn: $dnsViewModel.model.disableFallback)
                Toggle("Fallback If Match", isOn: $dnsViewModel.model.disableFallbackIfMatch)
            } header: {
                Text("Settings")
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
    
    @Binding var host: MGConfiguration.DNS.Host
    
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
    
    @Binding var host: MGConfiguration.DNS.Host
        
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
    
    @Binding var server: MGConfiguration.DNS.Server
    
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
    
    @Binding var server: MGConfiguration.DNS.Server
        
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
