import SwiftUI

struct MGShadowsocksView: View {
    
    @ObservedObject private var vm: MGConfigurationEditViewModel
    
    init(vm: MGConfigurationEditViewModel) {
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
                ForEach(MGConfiguration.Outbound.ShadowsocksSettings.Method.allCases) { method in
                    Text(method.description)
                }
            }
            .labelsHidden()
            .fixedSize()
        }
        Toggle("UOT", isOn: $vm.model.shadowsocks.uot)
    }
}
