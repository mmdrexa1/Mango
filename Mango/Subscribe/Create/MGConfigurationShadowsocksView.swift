import SwiftUI

struct MGConfigurationShadowsocksView: View {
    
    @ObservedObject private var vm: MGCreateOrUpdateConfigurationViewModel
    
    init(vm: MGCreateOrUpdateConfigurationViewModel) {
        self._vm = ObservedObject(initialValue: vm)
    }
    
    var body: some View {
        LabeledContent("Address") {
            TextField("", text: $vm.model.shadowsocks.address)
        }
        LabeledContent("Port") {
            TextField("", value: $vm.model.shadowsocks.port, format: .number)
        }
        LabeledContent("Email") {
            TextField("", text: $vm.model.shadowsocks.email)
        }
        LabeledContent("Password") {
            TextField("", text: $vm.model.shadowsocks.password)
        }
        LabeledContent("Method") {
            Picker("Method", selection: $vm.model.shadowsocks.method) {
                ForEach(MGConfiguration.Outbound.Shadowsocks.Method.allCases) { method in
                    Text(method.description)
                }
            }
            .labelsHidden()
            .fixedSize()
        }
        Toggle("UOT", isOn: $vm.model.shadowsocks.uot)
    }
}
