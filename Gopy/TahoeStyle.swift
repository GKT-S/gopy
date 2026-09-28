import SwiftUI
import AppKit

/// Liquid Glass container — macOS Tahoe 26 inspired frosted panel.
struct TahoeWindowContainer<Content: View>: View {
    private let cornerRadius: CGFloat
    private let content: Content

    init(cornerRadius: CGFloat = 26, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        ZStack {
            // Deep blur layer — actual desktop blur-through
            VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))

            // Tinted glass overlay
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.18),
                            Color(nsColor: NSColor(calibratedRed: 0.85, green: 0.88, blue: 0.98, alpha: 0.12))
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Inner highlight — liquid glass top edge glow
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.55),
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.08)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.0
                )

            // Content
            content
                .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: Color.black.opacity(0.25), radius: 40, x: 0, y: 20)
        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

/// Blur helper for macOS Tahoe glass materials.
struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var emphasized: Bool = true

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = emphasized ? .active : .followsWindowActiveState
        view.wantsLayer = true
        view.layer?.cornerCurve = .continuous
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = emphasized ? .active : .followsWindowActiveState
    }
}

/// Liquid glass pill button.
struct TahoePillStyle: ButtonStyle {
    var isProminent: Bool = false
    var tint: Color = .accentColor
    var fillOpacity: Double = 0.22

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        let fill: LinearGradient = {
            if isProminent {
                return LinearGradient(
                    colors: [
                        tint.opacity(pressed ? fillOpacity + 0.18 : fillOpacity + 0.12),
                        tint.opacity(pressed ? fillOpacity + 0.08 : fillOpacity)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                return LinearGradient(
                    colors: [
                        Color.white.opacity(pressed ? 0.35 : 0.22),
                        Color.white.opacity(pressed ? 0.18 : 0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }()

        configuration.label
            .font(.system(size: 12, weight: isProminent ? .semibold : .medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .focusable(false)
            .background(
                Capsule()
                    .fill(fill)
            )
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isProminent ? 0.55 : 0.35),
                                Color.white.opacity(isProminent ? 0.20 : 0.12)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.8
                    )
            )
            .foregroundStyle(isProminent ? tint : Color.primary.opacity(0.85))
            .scaleEffect(pressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: pressed)
    }
}

/// Liquid glass sidebar card.
struct TahoeSidebarBackground<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.10))

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.30),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.8
                    )
            }
        )
    }
}

extension View {
    func tahoeSmoothList() -> some View {
        self
            .padding(.horizontal, 6)
            .padding(.top, 4)
            .scrollIndicators(.hidden)
    }
}
