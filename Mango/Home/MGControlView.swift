import SwiftUI
import NetworkExtension

struct MGControlView: View {
    
    @EnvironmentObject private var packetTunnelManager: MGPacketTunnelManager
        
    var body: some View {
        LabeledContent {
            MGSwitchButton(state: .constant(packetTunnelManager.status?.switchButtonState ?? .off)) { _ in
                onTap(status: packetTunnelManager.status)
            }
        } label: {
            if let status = packetTunnelManager.status {
                if status == .connected {
                    TimelineView(.periodic(from: Date(), by: 1.0)) { context in
                        Text(connectedDateString(current: context.date))
                            .monospacedDigit()
                    }
                } else {
                    Text(status.displayString)
                }
            } else {
                Text("未连接")
            }
        }
    }
    
    private func connectedDateString(current: Date) -> String {
        guard let connectedDate = packetTunnelManager.connectedDate else {
            return "已连接"
        }
        let duration = Int64(abs(current.distance(to: connectedDate)))
        let hs = duration / 3600
        let ms = duration % 3600 / 60
        let ss = duration % 60
        if hs <= 0 {
            return String(format: "%02d:%02d", ms, ss)
        } else {
            return String(format: "%02d:%02d:%02d", hs, ms, ss)
        }
    }
    
    private func onTap(status: NEVPNStatus?) {
        Task(priority: .high) {
            do {
                if let status = status {
                    switch status {
                    case .connected:
                        packetTunnelManager.stop()
                    case .disconnected:
                        try await packetTunnelManager.start()
                    default:
                        break
                    }
                } else {
                    try await packetTunnelManager.saveToPreferences()
                }
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}

extension NEVPNStatus {
    
    var switchButtonState: MGSwitchButton.State {
        switch self {
        case .connected:
            return .on
        case .connecting, .reasserting, .disconnecting:
            return .processing
        default:
            return .off
        }
    }
    
    var displayString: String {
        switch self {
        case .invalid:
            return "不可用"
        case .disconnected:
            return "未连接"
        case .connecting:
            return "正在连接..."
        case .connected:
            return "已连接"
        case .reasserting:
            return "正在重连..."
        case .disconnecting:
            return "正在断开..."
        @unknown default:
            return "未知"
        }
    }
}
