import SwiftUI

struct MGRouteSettingView: View {
    
    @Environment(\.dataSizeFormatter) private var dataSizeFormatter

    @ObservedObject private var routeViewModel: MGConfigurationPersistentViewModel<MGConfiguration.Route>
    @ObservedObject private var assetViewModel: MGAssetViewModel

    init(routeViewModel: MGConfigurationPersistentViewModel<MGConfiguration.Route>, assetViewModel: MGAssetViewModel) {
        self._routeViewModel = ObservedObject(initialValue: routeViewModel)
        self._assetViewModel = ObservedObject(initialValue: assetViewModel)
    }
    
    var body: some View {
        Form {
            Section {
                Picker("Strategy", selection: $routeViewModel.model.domainStrategy) {
                    ForEach(MGConfiguration.Route.DomainStrategy.allCases) { strategy in
                        Text(strategy.description)
                    }
                }
                Picker("Matcher", selection: $routeViewModel.model.domainMatcher) {
                    ForEach(MGConfiguration.Route.DomainMatcher.allCases) { strategy in
                        Text(strategy.description)
                    }
                }
            } header: {
                Text("Domain")
            }
            Section {
                ForEach($routeViewModel.model.rules) { rule in
                    NavigationLink {
                        MGRouteRuleSettingView(rule: rule)
                    } label: {
                        HStack {
                            LabeledContent {
                                Text(rule.outboundTag.wrappedValue.description)
                            } label: {
                                Label {
                                    Text(rule.__name__.wrappedValue)
                                } icon: {
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .frame(width: 8, height: 8)
                                        .foregroundColor(rule.__enabled__.wrappedValue ? .green : .gray)
                                }
                            }
                        }
                    }
                }
                .onMove { from, to in
                    routeViewModel.model.rules.move(fromOffsets: from, toOffset: to)
                }
                .onDelete { offsets in
                    routeViewModel.model.rules.remove(atOffsets: offsets)
                }
                Button("Add New Rule") {
                    withAnimation {
                        var rule = MGConfiguration.Route.Rule()
                        rule.__name__ = rule.__defaultName__
                        routeViewModel.model.rules.append(rule)
                    }
                }
            } header: {
                HStack {
                    Text("Rules")
                    Spacer()
                    EditButton()
                        .font(.callout)
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                        .disabled(routeViewModel.model.rules.isEmpty)
                }
            }
            Section {
                ForEach(assetViewModel.items) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.url.lastPathComponent)
                            TimelineView(.periodic(from: Date(), by: 1)) { _ in
                                Text(item.date.formatted(.relative(presentation: .numeric)))
                                    .lineLimit(1)
                                    .foregroundColor(.secondary)
                                    .font(.callout)
                                    .fontWeight(.light)
                            }
                        }
                        Spacer()
                        Text(dataSizeFormatter.string(from: item.size) ?? "-")
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete", role: .destructive) {
                            do {
                                try assetViewModel.delete(item: item)
                            } catch {
                                debugPrint(error.localizedDescription)
                            }
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Asset")
                    Spacer()
                    Button("Import") {
                        assetViewModel.isFileImporterPresented.toggle()
                    }
                    .font(.callout)
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                }
            }
        }
        .onDisappear {
            self.routeViewModel.save()
        }
        .lineLimit(1)
        .navigationTitle(Text("Route"))
        .navigationBarTitleDisplayMode(.large)
        .fileImporter(isPresented: $assetViewModel.isFileImporterPresented, allowedContentTypes: [.dat], allowsMultipleSelection: true) { result in
            do {
                try assetViewModel.importLocalFiles(urls: try result.get())
                MGNotification.send(title: "", subtitle: "", body: "资源导入成功")
            } catch {
                MGNotification.send(title: "", subtitle: "", body: "资源导入失败, 原因: \(error.localizedDescription)")
            }
        }
    }
}

struct MGRouteRuleSettingView: View {
    
    @Binding var rule: MGConfiguration.Route.Rule
    
    var body: some View {
        Form {
            Section {
                Picker("Matcher", selection: $rule.domainMatcher) {
                    ForEach(MGConfiguration.Route.DomainMatcher.allCases) { strategy in
                        Text(strategy.description)
                    }
                }
                MGDisclosureGroup {
                    MGStringListEditor(strings: Binding(get: {
                        rule.domain ?? []
                    }, set: { newValue in
                        rule.domain = newValue.isEmpty ? nil : newValue
                    }), placeholder: nil)
                } label: {
                    LabeledContent("Domain", value: "\(rule.domain?.count ?? 0)")
                }
                MGDisclosureGroup {
                    MGStringListEditor(strings: Binding(get: {
                        rule.ip ?? []
                    }, set: { newValue in
                        rule.ip = newValue.isEmpty ? nil : newValue
                    }), placeholder: nil)
                } label: {
                    LabeledContent("IP", value: "\(rule.ip?.count ?? 0)")
                }
                MGDisclosureGroup {
                    MGStringListEditor(strings:  Binding {
                        let reval = rule.port ?? ""
                        return reval.components(separatedBy: ",").filter { !$0.isEmpty }
                    } set: { newValue in
                        let reval = newValue.joined(separator: ",")
                        rule.port = reval.isEmpty ? nil : reval
                    }, placeholder: nil)
                } label: {
                    LabeledContent("Port", value: rule.port ?? "")
                }
                MGDisclosureGroup {
                    MGStringListEditor(strings:  Binding {
                        let reval = rule.sourcePort ?? ""
                        return reval.components(separatedBy: ",").filter { !$0.isEmpty }
                    } set: { newValue in
                        let reval = newValue.joined(separator: ",")
                        rule.sourcePort = reval.isEmpty ? nil : reval
                    }, placeholder: nil)
                } label: {
                    LabeledContent("Source Port", value: rule.sourcePort ?? "")
                }
                LabeledContent("Network") {
                    HStack {
                        ForEach(MGConfiguration.Route.Network.allCases) { network in
                            MGToggleButton(title: network.description, isOn: Binding(get: {
                                return rule.network.flatMap { $0.contains(network) } ?? false
                            }, set: { value in
                                var reval = rule.network ?? []
                                if value {
                                    reval.insert(network)
                                } else {
                                    reval.remove(network)
                                }
                                rule.network = reval.isEmpty ? nil : reval
                            }))
                        }
                    }
                }
                LabeledContent("Protocol") {
                    HStack {
                        ForEach(MGConfiguration.Route.Protocol_.allCases) { protocol_ in
                            MGToggleButton(title: protocol_.description, isOn: Binding(get: {
                                return rule.protocol.flatMap { $0.contains(protocol_) } ?? false
                            }, set: { value in
                                var reval = rule.protocol ?? []
                                if value {
                                    reval.insert(protocol_)
                                } else {
                                    reval.remove(protocol_)
                                }
                                rule.protocol = reval.isEmpty ? nil : reval
                            }))
                        }
                    }
                }
                LabeledContent("Inbound") {
                    HStack {
                        ForEach(MGConfiguration.Route.Inbound.allCases) { inbound in
                            MGToggleButton(title: inbound.description, isOn: Binding(get: {
                                return rule.inboundTag.flatMap { $0.contains(inbound) } ?? false
                            }, set: { value in
                                var reval = rule.inboundTag ?? []
                                if value {
                                    reval.insert(inbound)
                                } else {
                                    reval.remove(inbound)
                                }
                                rule.inboundTag = reval.isEmpty ? nil : reval
                            }))
                        }
                    }
                }
                Picker("Outbound", selection: $rule.outboundTag) {
                    ForEach(MGConfiguration.Route.Outbound.allCases) { outbound in
                        Text(outbound.description)
                    }
                }
            } header: {
                Text("Settings")
            }
            Section {
                LabeledContent("Name") {
                    TextField("", text: $rule.__name__)
                        .onSubmit {
                            if rule.__name__.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                rule.__name__ = rule.__defaultName__
                            }
                        }
                }
                Toggle("Enable", isOn: $rule.__enabled__)
            } header: {
                Text("Other")
            }
        }
        .lineLimit(1)
        .multilineTextAlignment(.trailing)
        .environment(\.editMode, .constant(.active))
        .navigationTitle(Text(rule.__name__))
        .navigationBarTitleDisplayMode(.large)
    }
}
