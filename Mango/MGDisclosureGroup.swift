import SwiftUI

struct MGDisclosureGroup<Label: View, Content: View>: View {
    
    @State private var isExpanded: Bool = false
    
    private let label: Label
    private let content: Content
    
    init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
        self.content = content()
        self.label = label()
    }
    
    var body: some View {
        Group {
            LabeledContent {
                Button {
                    withAnimation {
                        self.isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .fixedSize()
                        .font(.caption2)
                        .fontWeight(.bold)
                        .rotationEffect(self.isExpanded ? Angle(degrees: 90) : Angle(degrees: 0), anchor: .center)
                }
            } label: {
                self.label
            }
            if self.isExpanded {
                self.content
            }
        }
    }
}
