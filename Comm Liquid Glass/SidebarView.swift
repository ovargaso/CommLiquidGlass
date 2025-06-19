//
//  SidebarView.swift
//  Comm Liquid Glass
//
//  Created by Oscar Vargas on 6/17/25.
//

import SwiftUI

// MARK: - Original Inner Shadow Modifier (Restored)
struct InnerShadow: ViewModifier {
  let color: Color
  
  func body(content: Content) -> some View {
    content
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(color, lineWidth: 0.5)
          .blur(radius: 1.5)
          .offset(x: 0, y: 1)
          .mask(
            RoundedRectangle(cornerRadius: 16)
              .fill(LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
              ))
          )
      )
  }
}

// MARK: - Interactive Glass Button (Preserved)
struct LiquidGlassButton<Content: View>: View {
    let action: () -> Void
    let isSelected: Bool
    let content: Content
    
    @State private var isPressed = false
    
    init(isSelected: Bool = false, action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.isSelected = isSelected
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: action) {
            content
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .padding(.leading, 8)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.regularMaterial.opacity(0.8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                )
                        } else {
                            // Subtle hover/press feedback
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(isPressed ? 0.08 : 0.02))
                        }
                    }
                )
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            isPressed = pressing
        } perform: {
            action()
        }
    }
}

// MARK: - Main Sidebar View
struct SidebarView: View {
    @Binding var isSidebarOpen: Bool
    let pinnedConversations: [String]
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedConversation: String? = nil
    @State private var selectedPlatform: String? = nil
    
    private let platforms = ["Slack", "Gmail", "Outlook", "Teams"]
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                sidebarContent(geometry: geometry)
                Spacer()
            }
        }
    }
    
    // MARK: - Sidebar Content
    @ViewBuilder
    private func sidebarContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Close Button Header (Simplified for better gesture handling)
            HStack {
                Spacer()
                Button {
        
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isSidebarOpen = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 36, height: 36) // Even larger tap target
                        .background(.regularMaterial)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .zIndex(999) // Ensure button is on top of all other elements
            }
            .padding(.top, 16)
            .padding(.trailing, 24)
            .padding(.bottom, 12)
            .zIndex(999) // Ensure entire header is on top
            
            // Scrollable Content
            ScrollView {
                VStack(spacing: 16) { // Back to original spacing
                    // Pinned Conversations Section
                    glassSection(
                        title: "Pinned Conversations",
                        items: Array(pinnedConversations.prefix(7))
                    ) { conversation in
                        LiquidGlassButton(
                            isSelected: selectedConversation == conversation,
                            action: {
                                selectedConversation = conversation
                                selectedPlatform = nil
                            }
                        ) {
                            HStack {
                                // Conversation Icon (New)
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(width: 20)
                                
                                Text(conversation)
                                    .font(.body)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    // Platform Filters Section
                    glassSection(
                        title: "Platforms",
                        items: platforms
                    ) { platform in
                        LiquidGlassButton(
                            isSelected: selectedPlatform == platform,
                            action: {
                                selectedPlatform = platform
                                selectedConversation = nil
                            }
                        ) {
                            HStack {
                                // Platform Icon (New)
                                Image(systemName: platformIcon(for: platform))
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(width: 20)
                                
                                Text(platform)
                                    .font(.body)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .frame(width: geometry.size.width * (horizontalSizeClass == .compact ? 0.75 : 0.40))
        // ORIGINAL BACKGROUND EFFECT (Restored)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        .modifier(InnerShadow(color: .black.opacity(0.1)))
        .overlay(
            LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.06), .clear]),
                startPoint: .top,
                endPoint: .center
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .allowsHitTesting(false) // Prevent gradient overlay from blocking gestures
        )
        .allowsHitTesting(true) // Ensure main container allows hit testing
    }
    
    // MARK: - Glass Section Builder (Enhanced typography preserved)
    @ViewBuilder
    private func glassSection<T, Content: View>(
        title: String,
        items: [T],
        @ViewBuilder itemBuilder: @escaping (T) -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Title (Enhanced typography preserved)
            Text(title)
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundColor(.white)
                .padding(.top, 8)
            
            // Section Items
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                itemBuilder(item)
            }
        }
    }
    
    // MARK: - Helper Methods (New icons preserved)
    private func platformIcon(for platform: String) -> String {
        switch platform {
        case "Slack": return "message.fill"
        case "Gmail": return "envelope.fill"
        case "Outlook": return "mail.fill"
        case "Teams": return "video.fill"
        default: return "app.fill"
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        SidebarView(
            isSidebarOpen: .constant(true),
            pinnedConversations: [
                "Project Sigma",
                "Oscar Vargas",
                "Team Standup",
                "Client Meeting",
                "Budget Review",
                "Product Launch",
                "Weekly Sync",
                "Additional Item"
            ]
        )
    }
    .preferredColorScheme(.dark)
} 