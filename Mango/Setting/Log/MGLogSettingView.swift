import SwiftUI

struct MGLogSettingView: View {
    
    @StateObject private var logViewModel = MGConfigurationPersistentViewModel<MGConfiguration.Log>()
    
    var body: some View {
        Form {
            Picker(selection: $logViewModel.model.errorLogSeverity) {
                ForEach(MGConfiguration.Log.Severity.allCases) { severity in
                    Text(severity.description)
                }
            } label: {
                Text("错误日志")
            }
            Toggle("访问日志", isOn: $logViewModel.model.accessLogEnabled)
            Toggle("DNS日志", isOn: $logViewModel.model.dnsLogEnabled)
        }
        .navigationTitle(Text("日志"))
        .onDisappear {
            self.logViewModel.save()
        }
    }
}
