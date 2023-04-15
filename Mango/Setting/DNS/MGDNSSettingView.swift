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
    
    struct Cell: View {
        
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
    
    @Environment(\.editMode) private var editMode
    @State private var isPresented: Bool = false
    
    @Binding var hosts: [MGConfiguration.DNS.Host]
    
    var body: some View {
        Form {
            ForEach($hosts) { host in
                Cell(host: host)
                    .disabled(!isAddButtonEnabled)
            }
            .onMove { from, to in
                hosts.move(fromOffsets: from, toOffset: to)
            }
            .onDelete { offsets in
                hosts.remove(atOffsets: offsets)
            }
            Button {
                isPresented.toggle()
            } label: {
                Text("添加")
            }
            .disabled(!isAddButtonEnabled)
        }
        .navigationTitle(Text("Hosts"))
        .toolbar {
            EditButton()
        }
        .sheet(isPresented: $isPresented) {
            MGDNSHostView(host: MGConfiguration.DNS.Host()) { value in
                hosts.append(value)
            }
        }
    }
    
    private var isAddButtonEnabled: Bool {
        guard let mode = editMode else {
            return true
        }
        return mode.wrappedValue == .inactive
    }
}

struct MGDNSServersView: View {
    
    struct Cell: View {
        
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
    
    @Environment(\.editMode) private var editMode
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
            Button {
                isPresented.toggle()
            } label: {
                Text("添加")
            }
            .disabled(!isAddButtonEnabled)
        }
        .navigationTitle(Text("Servers"))
        .toolbar {
            EditButton()
        }
        .sheet(isPresented: $isPresented) {
            MGDNSServerView(server: MGConfiguration.DNS.Server()) { value in
                servers.append(value)
            }
        }
    }
    
    private var isAddButtonEnabled: Bool {
        guard let mode = editMode else {
            return true
        }
        return mode.wrappedValue == .inactive
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
                    Text("Key")
                }
                Section {
                    MGStringListEditor(strings: $host.values, placeholder: nil)
                        .moveDisabled(true)
                } header: {
                    Text("Values")
                }
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Host")
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
                LabeledContent("Address") {
                    TextField("", text: $server.address)
                }
                if server.__object__ {
                    LabeledContent("Port") {
                        TextField("", value: $server.port, format: .number)
                    }
                    Group {
                        Text("Domain")
                        MGStringListEditor(strings: $server.domains, placeholder: nil)
                    }
                    Group {
                        Text("Expect IP")
                        MGStringListEditor(strings: $server.expectIPs, placeholder: nil)
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
                Button {
                    withAnimation {
                        server.__object__.toggle()
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text(server.__object__ ? "Less" : "More")
                        Spacer()
                    }
                }
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .multilineTextAlignment(.trailing)
            .environment(\.editMode, .constant(.active))
            .navigationTitle(Text("Server"))
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
