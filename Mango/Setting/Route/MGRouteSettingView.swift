import SwiftUI

struct MGRouteSettingView: View {
    
    @StateObject private var routeViewModel = MGConfigurationPersistentViewModel<MGConfiguration.Route>()

    @State private var isAddRulePresented: Bool = false
    
    var body: some View {
        Form {
            Section {
                Picker("解析策略", selection: $routeViewModel.model.domainStrategy) {
                    ForEach(MGConfiguration.Route.DomainStrategy.allCases) { strategy in
                        Text(strategy.description)
                    }
                }
                Picker("匹配算法", selection: $routeViewModel.model.domainMatcher) {
                    ForEach(MGConfiguration.Route.DomainMatcher.allCases) { strategy in
                        Text(strategy.description)
                    }
                }
                NavigationLink("规则") {
                    MGRouteRulesView(rules: $routeViewModel.model.rules)
                }
            }
        }
        .onDisappear {
            self.routeViewModel.save()
        }
        .lineLimit(1)
        .navigationTitle(Text("路由"))
        .toolbar(.hidden, for: .tabBar)
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $isAddRulePresented) {
            MGRouteRuleSettingView(rule: MGConfiguration.Route.Rule()) { value in
                routeViewModel.model.rules.append(value)
            }
        }
    }
}

struct MGRouteRulesView: View {
    
    @Binding var rules: [MGConfiguration.Route.Rule]
    
    var body: some View {
        Form {
            ForEach($rules) { rule in
                MGPresentedButton {
                    MGRouteRuleSettingView(rule: rule.wrappedValue) { value in
                        rule.wrappedValue = value
                    }
                } label: {
                    HStack {
                        LabeledContent {
                            Text(rule.outboundTag.wrappedValue.description)
                        } label: {
                            HStack {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .frame(width: 8, height: 8)
                                    .foregroundColor(rule.__enabled__.wrappedValue ? .green : .red.opacity(0.5))
                                Text(rule.__name__.wrappedValue)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            .onMove { from, to in
                rules.move(fromOffsets: from, toOffset: to)
            }
            .onDelete { offsets in
                rules.remove(atOffsets: offsets)
            }
        }
        .navigationTitle(Text("规则"))
        .environment(\.editMode, .constant(.active))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                MGPresentedButton {
                    MGRouteRuleSettingView(rule: MGConfiguration.Route.Rule()) { value in
                        rules.append(value)
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct MGRouteRuleSettingView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var rule: MGConfiguration.Route.Rule
    
    private let onSave: (MGConfiguration.Route.Rule) -> Void
    
    init(rule: MGConfiguration.Route.Rule, onSave: @escaping (MGConfiguration.Route.Rule) -> Void) {
        self._rule = State(initialValue: rule)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Group {
                    LabeledContent("名称") {
                        TextField("", text: $rule.__name__)
                            .onSubmit {
                                if rule.__name__.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    rule.__name__ = rule.__defaultName__
                                }
                            }
                    }
                    Toggle("状态", isOn: $rule.__enabled__)
                }
                Group {
                    Picker("匹配算法", selection: $rule.domainMatcher) {
                        ForEach(MGConfiguration.Route.DomainMatcher.allCases) { strategy in
                            Text(strategy.description)
                        }
                    }
                    NavigationLink("域名") {
                        Form {
                            MGStringListEditor(strings: Binding(get: {
                                rule.domain ?? []
                            }, set: { newValue in
                                rule.domain = newValue.isEmpty ? nil : newValue
                            }), placeholder: nil)
                        }
                        .environment(\.editMode, .constant(.active))
                        .navigationBarTitle(Text("域名"))
                    }
                    NavigationLink("目标 IP") {
                        Form {
                            MGStringListEditor(strings: Binding(get: {
                                rule.ip ?? []
                            }, set: { newValue in
                                rule.ip = newValue.isEmpty ? nil : newValue
                            }), placeholder: nil)
                        }
                        .environment(\.editMode, .constant(.active))
                        .navigationBarTitle(Text("目标 IP"))
                    }
                    NavigationLink("目标端口") {
                        Form {
                            MGStringListEditor(strings:  Binding {
                                let reval = rule.port ?? ""
                                return reval.components(separatedBy: ",").filter { !$0.isEmpty }
                            } set: { newValue in
                                let reval = newValue.joined(separator: ",")
                                rule.port = reval.isEmpty ? nil : reval
                            }, placeholder: nil)
                        }
                        .environment(\.editMode, .constant(.active))
                        .navigationBarTitle(Text("目标端口"))
                    }
                    NavigationLink("源端口") {
                        Form {
                            MGStringListEditor(strings:  Binding {
                                let reval = rule.sourcePort ?? ""
                                return reval.components(separatedBy: ",").filter { !$0.isEmpty }
                            } set: { newValue in
                                let reval = newValue.joined(separator: ",")
                                rule.sourcePort = reval.isEmpty ? nil : reval
                            }, placeholder: nil)
                        }
                        .environment(\.editMode, .constant(.active))
                        .navigationBarTitle(Text("源端口"))
                    }
                    Group {
                        LabeledContent("连接方式") {
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
                        LabeledContent("协议") {
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
                        LabeledContent("入站") {
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
                    }
                    Picker("出站", selection: $rule.outboundTag) {
                        ForEach(MGConfiguration.Outbound.Tag.allCases) { tag in
                            Text(tag.description)
                        }
                    }
                }
            }
            .lineLimit(1)
            .multilineTextAlignment(.trailing)
            .navigationTitle(Text("规则"))
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消", role: .cancel) {
                        self.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        self.onSave(self.rule)
                        self.dismiss()
                    }
                }
            }
        }
    }
}
