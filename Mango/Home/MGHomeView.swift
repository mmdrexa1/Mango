import SwiftUI

struct MGHomeView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var packetTunnelManager: MGPacketTunnelManager
    
    let current: Binding<String>
    
    @State var state : MGSwitchButton.State = .off
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if packetTunnelManager.isProcessing {
                        ProgressView()
                    } else {
                        MGControlView()
                    }
                }
                Section {
                    MGConfigurationView(current: current)
                } header: {
                    Text("当前配置")
                }
            }
            .environmentObject(packetTunnelManager)
            .navigationTitle(Text("Mango"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    MGPresentedButton {
                        MGSettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("VLESS") {
                            
                        }
                        Button("VMess") {
                            
                        }
                        Button("Trojan") {
                            
                        }
                        Button("Shadowsocks") {
                            
                        }
                        Divider()
                        Button {
                            
                        } label: {
                            Label("扫描二维码", systemImage: "qrcode.viewfinder")
                        }
                        Divider()
                        Button {
                            
                        } label: {
                            Label("从 URL 下载", systemImage: "square.and.arrow.down.on.square")
                        }
                        Button {
                            
                        } label: {
                            Label("从文件夹导入", systemImage: "tray.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct MGSwitchButton: View {
    
    enum State: Int, Identifiable {
        var id: Self { self }
        case off = 0
        case processing = 1
        case on = 2
    }
    
    @Binding private var state: State
    
    let action: (State) -> Void
    
    init(state: Binding<State>, action: @escaping (State) -> Void) {
        self._state = state
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: 6) {
            if state == .on {
                Spacer()
                    .frame(width: 12)
            }
            Circle()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
                .overlay {
                    ProgressView()
                        .opacity(state == .processing ? 1.0 : 0.0)
                }
            if state == .off {
                Spacer()
                    .frame(width: 12)
            }
        }
        .padding(2)
        .onTapGesture {
            action(state)
        }
        .background {
            Capsule()
                .foregroundColor(backgroundColor)
        }
        .buttonStyle(.plain)
        .fixedSize()
        .disabled(state == .processing)
        .animation(.easeInOut(duration: 0.15), value: state)
    }
    
    private var backgroundColor: Color {
        switch state {
        case .off:
            return Color(uiColor: .systemGray5)
        case .processing:
            return Color(uiColor: .systemGray5)
        case .on:
            return Color(uiColor: .systemGreen)
        }
    }
}
