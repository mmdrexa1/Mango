import SwiftUI

struct MGDNSSettingView: View {
    
    @StateObject private var dnsViewModel = MGConfigurationPersistentViewModel<MGConfiguration.DNS>()
    
    var body: some View {
        Form {
            Section {
                NavigationLink("静态 IP") {
                    MGDNSHostsView(hosts: $dnsViewModel.model.hosts)
                }
                NavigationLink("服务器") {
                    MGDNSServersView(servers: $dnsViewModel.model.servers)
                }
                LabeledContent {
                    Picker("查询策略", selection: $dnsViewModel.model.queryStrategy) {
                        ForEach(MGConfiguration.DNS.QueryStrategy.allCases) { strategy in
                            Text(strategy.description)
                        }
                    }
                    .labelsHidden()
                    .fixedSize()
                } label: {
                    Text("查询策略")
                }
                Toggle("禁用缓存", isOn: $dnsViewModel.model.disableCache)
                Toggle("禁用 Fallback 查询", isOn: $dnsViewModel.model.disableFallback)
                Toggle("禁用 Fallback 查询如果命中", isOn: $dnsViewModel.model.disableFallbackIfMatch)
            }
        }
        .lineLimit(1)
        .multilineTextAlignment(.trailing)
        .navigationTitle(Text("DNS"))
        .toolbar(.hidden, for: .tabBar)
        .onDisappear {
            self.dnsViewModel.save()
        }
    }
}

struct MGDNSHostsView: View {
    
    private struct Cell: View {
        
        @State private var isPresented: Bool = false
        
        @Binding var host: MGConfiguration.DNS.Host
        
        var body: some View {
            Button {
                isPresented.toggle()
            } label: {
                HStack {
                    Text(host.key)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $isPresented) {
                MGDNSHostView(host: host) { host = $0 }
            }
        }
    }
    
    @State private var isPresented: Bool = false
    
    @Binding var hosts: [MGConfiguration.DNS.Host]
    
    var body: some View {
        Form {
            ForEach($hosts) { host in
                Cell(host: host)
            }
            .onDelete { offsets in
                hosts.remove(atOffsets: offsets)
            }
        }
        .navigationTitle(Text("静态 IP"))
        .environment(\.editMode, .constant(.active))
        .toolbar {
            Button {
                isPresented.toggle()
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $isPresented) {
            MGDNSHostView(host: MGConfiguration.DNS.Host()) { value in
                hosts.append(value)
            }
        }
    }
}

struct MGDNSServersView: View {
    
    private struct Cell: View {
        
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
                MGDNSServerView(server: self.server) { value in
                    self.server = value
                }
            }
        }
    }
    
    @State private var isPresented: Bool = false
    
    @Binding var servers: [MGConfiguration.DNS.Server]
    
    var body: some View {
        Form {
            ForEach($servers) { server in
                Cell(server: server)
            }
            .onMove { from, to in
                servers.move(fromOffsets: from, toOffset: to)
            }
            .onDelete { offsets in
                servers.remove(atOffsets: offsets)
            }
        }
        .navigationTitle(Text("服务器"))
        .environment(\.editMode, .constant(.active))
        .toolbar {
            Button {
                isPresented.toggle()
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $isPresented) {
            MGDNSServerView(server: MGConfiguration.DNS.Server()) { value in
                servers.append(value)
            }
        }
    }
}

struct MGDNSHostView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var host: MGConfiguration.DNS.Host
    
    private let onSave: (MGConfiguration.DNS.Host) -> Void
    
    init(host: MGConfiguration.DNS.Host, onSave: @escaping (MGConfiguration.DNS.Host) -> Void) {
        self._host = State(initialValue: host)
        self.onSave = onSave
    }
        
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("", text: $host.key)
                        .multilineTextAlignment(.leading)
                } header: {
                    Text("域名")
                }
                Section {
                    MGStringListEditor(strings: $host.values, placeholder: nil)
                        .moveDisabled(true)
                } header: {
                    Text("地址")
                }
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .environment(\.editMode, .constant(.active))
            .navigationTitle(" ")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消", role: .cancel) {
                        self.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存", role: .none) {
                        self.onSave(self.host)
                        self.dismiss()
                    }
                }
            }
        }
    }
}

struct MGDNSServerView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var server: MGConfiguration.DNS.Server
    
    private let onSave: (MGConfiguration.DNS.Server) -> Void
    
    init(server: MGConfiguration.DNS.Server, onSave: @escaping (MGConfiguration.DNS.Server) -> Void) {
        self._server = State(initialValue: server)
        self.onSave = onSave
    }
        
    var body: some View {
        NavigationStack {
            Form {
                LabeledContent("地址") {
                    TextField("", text: $server.address)
                }
                if server.__object__ {
                    LabeledContent("端口") {
                        TextField("", value: $server.port, format: .number)
                    }
                    NavigationLink("域名") {
                        Form {
                            MGStringListEditor(strings: $server.domains, placeholder: nil)
                        }
                        .navigationTitle(Text("域名"))
                        .environment(\.editMode, .constant(.active))
                    }
                    NavigationLink("IP 范围") {
                        Form {
                            MGStringListEditor(strings: $server.expectIPs, placeholder: nil)
                        }
                        .navigationTitle(Text("IP 范围"))
                        .environment(\.editMode, .constant(.active))
                    }
                    Toggle("Fallback 查询跳过此服务器", isOn: $server.skipFallback)
                }
                Button {
                    withAnimation {
                        server.__object__.toggle()
                    }
                } label: {
                    Text(server.__object__ ? "使用简单配置" : "使用复杂配置")
                }
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .multilineTextAlignment(.trailing)
            .navigationTitle(Text(" "))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消", role: .cancel) {
                        self.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存", role: .none) {
                        self.onSave(self.server)
                        self.dismiss()
                    }
                }
            }
        }
    }
}
