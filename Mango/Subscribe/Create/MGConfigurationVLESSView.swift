import SwiftUI

struct MGConfigurationVLESSView: View {
    
    @ObservedObject private var vm: MGCreateOrUpdateConfigurationViewModel
    
    init(vm: MGCreateOrUpdateConfigurationViewModel) {
        self._vm = ObservedObject(initialValue: vm)
    }
    
    var body: some View {
        LabeledContent("Address") {
            TextField("", text: $vm.model.vless.address)
        }
        LabeledContent("Port") {
            TextField("", value: $vm.model.vless.port, format: .number)
        }
        LabeledContent("UUID") {
            TextField("", text: $vm.model.vless.users[0].id)
        }
        LabeledContent("Encryption") {
            TextField("", text: $vm.model.vless.users[0].encryption)
        }
        LabeledContent("Flow") {
            Picker("Flow", selection: $vm.model.vless.users[0].flow) {
                ForEach(MGConfiguration.Outbound.VLESS.Flow.allCases) { encryption in
                    Text(encryption.description)
                }
            }
            .labelsHidden()
            .fixedSize()
        }
    }
}
