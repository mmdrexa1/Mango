import SwiftUI

struct MGConfigurationTrojanView: View {
    
    @ObservedObject private var vm: MGCreateOrUpdateConfigurationViewModel
    
    init(vm: MGCreateOrUpdateConfigurationViewModel) {
        self._vm = ObservedObject(initialValue: vm)
    }
    
    var body: some View {
        LabeledContent("Address") {
            TextField("", text: $vm.model.trojan.address)
        }
        LabeledContent("Port") {
            TextField("", value: $vm.model.trojan.port, format: .number)
        }
        LabeledContent("Password") {
            TextField("", text: $vm.model.trojan.password)
        }
        LabeledContent("Email") {
            TextField("", text: $vm.model.trojan.email)
        }
    }
}
