import SwiftUI

struct MGVMessView: View {
    
    @ObservedObject private var vm: MGConfigurationEditViewModel
    
    init(vm: MGConfigurationEditViewModel) {
        self._vm = ObservedObject(initialValue: vm)
    }
    
    var body: some View {
        LabeledContent("Address") {
            TextField("", text: $vm.model.vmess.address)
        }
        LabeledContent("Port") {
            TextField("", value: $vm.model.vmess.port, format: .number)
        }
        LabeledContent("ID") {
            TextField("", text: $vm.model.vmess.user.id)
        }
        LabeledContent("Alert ID") {
            TextField("", value: $vm.model.vmess.user.alterId, format: .number)
        }
        Picker("Security", selection: $vm.model.vmess.user.security) {
            ForEach(MGConfiguration.Outbound.Encryption.vmess) { encryption in
                Text(encryption.description)
            }
        }
    }
}
