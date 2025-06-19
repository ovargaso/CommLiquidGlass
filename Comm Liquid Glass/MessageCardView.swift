//
//  MessageCardView.swift
//  Comm Liquid Glass
//
//  Created by Oscar Vargas on 6/17/25.
//

import SwiftUI

// Individual message model for the thread
struct ThreadMessage: Identifiable {
  let id = UUID()
  let sender: String
  let initials: String
  let content: String
  let timestamp: String
}

// Individual message row component
struct ThreadMessageRow: View {
  let message: ThreadMessage
  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      // Avatar with initials
      ZStack {
        Circle()
          .fill(.ultraThinMaterial)
          .frame(width: 32, height: 32)
          .overlay(
            Circle()
              .stroke(Color.white.opacity(0.1), lineWidth: 1)
          )
        
        Text(message.initials)
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.white)
      }
      
      // Message content
      VStack(alignment: .leading, spacing: 4) {
        HStack {
          Text(message.sender)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
          
          Spacer()
          
          Text(message.timestamp)
            .font(.caption)
            .foregroundColor(.white.opacity(0.6))
        }
        
        Text(message.content)
          .font(.body)
          .foregroundColor(.white.opacity(0.9))
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }
}

// Custom shape for bottom-only rounded corners
struct BottomRoundedRectangle: Shape {
  var radius: CGFloat
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    // Start at top-left (completely square top)
    path.move(to: CGPoint(x: 0, y: 0))
    // Top edge (straight line, no rounding)
    path.addLine(to: CGPoint(x: rect.maxX, y: 0))
    // Right edge down to bottom corner
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
    // Bottom-right corner (rounded)
    path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                radius: radius,
                startAngle: Angle(degrees: 0),
                endAngle: Angle(degrees: 90),
                clockwise: false)
    // Bottom edge
    path.addLine(to: CGPoint(x: radius, y: rect.maxY))
    // Bottom-left corner (rounded)
    path.addArc(center: CGPoint(x: radius, y: rect.maxY - radius),
                radius: radius,
                startAngle: Angle(degrees: 90),
                endAngle: Angle(degrees: 180),
                clockwise: false)
    // Left edge back to top (straight line, no rounding)
    path.addLine(to: CGPoint(x: 0, y: 0))
    
    return path
  }
}

// Reply interface component
struct ReplyInterface: View {
  @State private var replyText = ""
  
  var body: some View {
    VStack(spacing: 0) {
      // Divider above toolbar
      Divider()
        .background(Color.white.opacity(0.2))
        .padding(.horizontal, 16)
      
      // Formatting toolbar - only 5 specific icons
      HStack(spacing: 20) {
        Button(action: {}) {
          Image(systemName: "bold")
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.7))
        }
        
        Button(action: {}) {
          Image(systemName: "italic")
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.7))
        }
        
        Button(action: {}) {
          Image(systemName: "strikethrough")
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.7))
        }
        
        Button(action: {}) {
          Image(systemName: "list.bullet")
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.7))
        }
        
        Button(action: {}) {
          Image(systemName: "list.number")
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.7))
        }
        
        Spacer()
      }
      .padding(.horizontal, 16)
      .padding(.top, 16)
      .padding(.bottom, 8)
      
      // Text input field with custom placeholder (no focus state)
      VStack(spacing: 8) {
        ZStack(alignment: .topLeading) {
          // Custom placeholder that disappears cleanly
          if replyText.isEmpty {
            Text("Type your reply...")
              .foregroundColor(.white.opacity(0.5))
              .padding(.leading, 10)
              .padding(.top, 10)
              .allowsHitTesting(false) // Allows taps to pass through to TextField
          }
          
          // TextField with no built-in placeholder
          TextField("", text: $replyText, axis: .vertical)
            .textFieldStyle(PlainTextFieldStyle())
            .foregroundColor(.white)
            .padding(10)
            .frame(minHeight: 36)
        }
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(.ultraThinMaterial)
        )
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        
        // Bottom row with AI icon and send button
        HStack {
          // AI Icon (left side)
          Button(action: {}) {
            Image(systemName: "brain.head.profile")
              .font(.system(size: 18))
              .foregroundColor(.white.opacity(0.7))
          }
          
          Spacer()
          
          // Send button (right side)
          Button(action: {}) {
            Image(systemName: "paperplane.fill")
              .font(.system(size: 18))
              .foregroundColor(.white.opacity(0.7))
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.top, 8)
      .padding(.bottom, 16)
      
      // Divider below text input  
      Divider()
        .background(Color.white.opacity(0.2))
        .padding(.horizontal, 16)
    }
  }
}

// Urgency reclassification menu
struct UrgencyMenu: View {
  let currentUrgency: String
  @Binding var selectedUrgency: String
  @Binding var isPresented: Bool
  
  @State private var hoveredUrgency: String? = nil
  
  private var reclassificationOptions: [(title: String, urgency: String)] {
    switch currentUrgency {
    case "High":
      return [
        ("Reclassify as Medium", "Medium"),
        ("Reclassify as Low", "Low")
      ]
    case "Medium":
      return [
        ("Reclassify as High", "High"),
        ("Reclassify as Low", "Low")
      ]
    case "Low":
      return [
        ("Reclassify as High", "High"),
        ("Reclassify as Medium", "Medium")
      ]
    default:
      return []
    }
  }
  
  var body: some View {
    VStack(spacing: 4) {
      ForEach(reclassificationOptions, id: \.urgency) { option in
        Button(action: {
          withAnimation(.easeInOut(duration: 0.3)) {
            selectedUrgency = option.urgency
            isPresented = false
          }
        }) {
          HStack {
            Text(option.title)
              .font(.body)
              .foregroundColor(.white)
              .lineLimit(1)
              .fixedSize(horizontal: true, vertical: false)
            Spacer()
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(
            Group {
              #if os(macOS)
              hoveredUrgency == option.urgency ? Color.white.opacity(0.12) : Color.clear
              #else
              Color.clear
              #endif
            }
          )
          .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
        #if os(macOS)
        .onHover { hovering in
          hoveredUrgency = hovering ? option.urgency : nil
        }
        #endif
      }
    }
    .padding(8)
    .background(.regularMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(Color.white.opacity(0.1), lineWidth: 1)
    )
    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    .scaleEffect(isPresented ? 1.0 : 0.1, anchor: .topTrailing)
    .opacity(isPresented ? 1.0 : 0.0)
    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPresented)
  }
}

// Shared card content for stackable cards
struct MessageCardContent: View {
    let platformIcon: String
    let senders: String
    let timestamp: String
    let urgency: String
    let summary: String
    let actionItems: [String]
    let isExpanded: Bool
    let isThreadExpanded: Bool
    let selectedUrgency: String
    let showUrgencyMenu: Bool
    let showShadow: Bool
    let onToggleExpand: () -> Void
    let onToggleUrgencyMenu: () -> Void
    let onEllipsis: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: platformIcon)
                    .foregroundColor(.white)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 4) {
                    Text(senders)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Last message received: \(timestamp)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                // Urgency Badge with Menu
                Button(action: onToggleUrgencyMenu) {
                    HStack(spacing: 4) {
                        Text(selectedUrgency)
                            .font(.subheadline)
                            .foregroundColor(selectedUrgency == "High" ? .red : selectedUrgency == "Medium" ? .orange : .yellow)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .rotationEffect(.degrees(showUrgencyMenu ? 180 : 0))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(PlainButtonStyle())
            }
            // Summary Text
            Text(summary)
                .font(.callout)
                .foregroundColor(.white)
                .lineLimit(isThreadExpanded ? nil : 6)
                .truncationMode(.tail)
                .padding(.leading, 44)
            // Separator
            Divider()
                .background(Color.white.opacity(0.3))
                .padding(.leading, 44)
            // Action Items Row
            ZStack(alignment: .leading) {
                Button(action: onToggleExpand) {
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                HStack {
                    Text("Action Items")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.leading, 44)
            }
            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(actionItems, id: \.self) { item in
                        Text("• \(item)")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(.top, 4)
                .padding(.leading, 44)
            }
            // Ellipsis Button
            HStack {
                Spacer()
                Button(action: onEllipsis) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                        .font(.title3)
                }
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: showShadow ? Color.black.opacity(0.3) : Color.clear, radius: showShadow ? 8 : 0, x: 0, y: showShadow ? 4 : 0)
    }
}

// New stackable card view that uses the two-card ZStack approach
struct StackableMessageCardView: View {
    let platformIcon: String
    let senders: String
    let timestamp: String
    let urgency: String
    let summary: String
    let actionItems: [String]
    
    @State private var isExpanded = false
    @State private var isThreadExpanded = false
    @State private var showFullConversation = false
    @State private var selectedUrgency: String
    @State private var showUrgencyMenu = false
    @State private var cardHeight: CGFloat = 0
    
    // Initialize selectedUrgency with the passed urgency value
    init(platformIcon: String, senders: String, timestamp: String, urgency: String, summary: String, actionItems: [String]) {
        self.platformIcon = platformIcon
        self.senders = senders
        self.timestamp = timestamp
        self.urgency = urgency
        self.summary = summary
        self.actionItems = actionItems
        self._selectedUrgency = State(initialValue: urgency)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // BACK CARD - always rendered, with animated offset, NO SHADOW
            MessageCardContent(
                platformIcon: platformIcon,
                senders: senders,
                timestamp: timestamp,
                urgency: urgency,
                summary: summary,
                actionItems: actionItems,
                isExpanded: isExpanded,
                isThreadExpanded: isThreadExpanded,
                selectedUrgency: selectedUrgency,
                showUrgencyMenu: false, // Back card doesn't show menu
                showShadow: false, // NO SHADOW for back card
                onToggleExpand: {}, // Back card doesn't handle interactions
                onToggleUrgencyMenu: {},
                onEllipsis: {}
            )
            .scaleEffect(0.96)
            .offset(y: isThreadExpanded ? cardHeight : 14)
            .opacity(0.3)
            .mask(
                Rectangle()
                    .offset(y: isThreadExpanded ? 0 : cardHeight - 14) // Hide top when collapsed, show all when expanded
            )
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isThreadExpanded)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: cardHeight)
            
            // FRONT CARD - tappable, with height measurement
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isThreadExpanded.toggle()
                }
            }) {
                MessageCardContent(
                    platformIcon: platformIcon,
                    senders: senders,
                    timestamp: timestamp,
                    urgency: urgency,
                    summary: summary,
                    actionItems: actionItems,
                    isExpanded: isExpanded,
                    isThreadExpanded: isThreadExpanded,
                    selectedUrgency: selectedUrgency,
                    showUrgencyMenu: showUrgencyMenu,
                    showShadow: true, // SHADOW for front card
                    onToggleExpand: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    },
                    onToggleUrgencyMenu: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showUrgencyMenu.toggle()
                        }
                    },
                    onEllipsis: {}
                )
            }
            .buttonStyle(PlainButtonStyle())
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            cardHeight = geo.size.height
                        }
                        .onChange(of: geo.size.height) {
                            cardHeight = geo.size.height
                        }
                        .onChange(of: isExpanded) {
                            // Update height when action items expand/collapse
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                cardHeight = geo.size.height
                            }
                        }
                }
            )
            
            // Thread expansion view (if needed)
            if isThreadExpanded {
                VStack(spacing: 0) {
                    // Spacer shows black app background - creates "tucked under" effect
                    Spacer()
                        .frame(height: cardHeight)
                    
                    // Thread content with material background
                    VStack(spacing: 0) {
                        // Thread messages
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach([
                                ThreadMessage(
                                    sender: "Vincent Chase",
                                    initials: "VC",
                                    content: "Lorem ipsum dolor sit amet consectetur. Venenatis convallis eu semper volutpat. Scelerisque dapibus platea laoreet eget tristique.",
                                    timestamp: "2m ago"
                                ),
                                ThreadMessage(
                                    sender: "Eric Murphy",
                                    initials: "EM",
                                    content: "Lorem ipsum dolor sit amet consectetur. Venenatis convallis eu semper volutpat. Scelerisque dapibus platea laoreet eget tristique.",
                                    timestamp: "2m ago"
                                ),
                                ThreadMessage(
                                    sender: "Vincent Chase",
                                    initials: "VC",
                                    content: "Lorem ipsum dolor sit amet consectetur. Venenatis convallis eu semper volutpat. Scelerisque dapibus platea laoreet eget tristique.",
                                    timestamp: "2m ago"
                                ),
                                ThreadMessage(
                                    sender: "Eric Murphy",
                                    initials: "EM",
                                    content: "Lorem ipsum dolor sit amet consectetur. Venenatis convallis eu semper volutpat. Scelerisque dapibus platea laoreet eget tristique.",
                                    timestamp: "2m ago"
                                )
                            ].prefix(4)) { message in
                                ThreadMessageRow(message: message)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .padding(.top, 16)
                        .background(.regularMaterial)
                        
                        // Reply interface
                        ReplyInterface()
                            .background(.regularMaterial)
                        
                        // See More button
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                showFullConversation = true
                            }) {
                                Text("See more")
                                    .font(.body)
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 16)
                        .background(.regularMaterial)
                    }
                    .clipShape(BottomRoundedRectangle(radius: 16))
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
        .overlay(
            // Floating urgency menu overlay
            Group {
                if showUrgencyMenu {
                    VStack {
                        HStack {
                            Spacer()
                            UrgencyMenu(
                                currentUrgency: selectedUrgency,
                                selectedUrgency: $selectedUrgency,
                                isPresented: $showUrgencyMenu
                            )
                            .fixedSize(horizontal: true, vertical: false)
                            .offset(x: -8, y: 0)
                        }
                        .padding(.top, 48)
                        .padding(.trailing, 16)
                        Spacer()
                    }
                }
            }
        )
        .fullScreenCover(isPresented: $showFullConversation) {
            ConversationView(
                conversationTitle: "Budget Discussion",
                participants: senders.components(separatedBy: ", "),
                isPresented: $showFullConversation
            )
        }
    }
}

// Original MessageCardView for backward compatibility (simplified)
struct MessageCardView: View {
    let platformIcon: String
    let senders: String
    let timestamp: String
    let urgency: String
    let summary: String
    let actionItems: [String]
    
    @State private var isExpanded = false
    @State private var isThreadExpanded = false
    @State private var showFullConversation = false
    @State private var selectedUrgency: String
    @State private var showUrgencyMenu = false
    
    // Initialize selectedUrgency with the passed urgency value
    init(platformIcon: String, senders: String, timestamp: String, urgency: String, summary: String, actionItems: [String]) {
        self.platformIcon = platformIcon
        self.senders = senders
        self.timestamp = timestamp
        self.urgency = urgency
        self.summary = summary
        self.actionItems = actionItems
        self._selectedUrgency = State(initialValue: urgency)
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isThreadExpanded.toggle()
            }
        }) {
            MessageCardContent(
                platformIcon: platformIcon,
                senders: senders,
                timestamp: timestamp,
                urgency: urgency,
                summary: summary,
                actionItems: actionItems,
                isExpanded: isExpanded,
                isThreadExpanded: isThreadExpanded,
                selectedUrgency: selectedUrgency,
                showUrgencyMenu: showUrgencyMenu,
                showShadow: true,
                onToggleExpand: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                },
                onToggleUrgencyMenu: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showUrgencyMenu.toggle()
                    }
                },
                onEllipsis: {}
            )
        }
        .buttonStyle(PlainButtonStyle())
        .overlay(
            // Floating urgency menu overlay
            Group {
                if showUrgencyMenu {
                    VStack {
                        HStack {
                            Spacer()
                            UrgencyMenu(
                                currentUrgency: selectedUrgency,
                                selectedUrgency: $selectedUrgency,
                                isPresented: $showUrgencyMenu
                            )
                            .fixedSize(horizontal: true, vertical: false)
                            .offset(x: -8, y: 0)
                        }
                        .padding(.top, 48)
                        .padding(.trailing, 16)
                        Spacer()
                    }
                }
            }
        )
        .fullScreenCover(isPresented: $showFullConversation) {
            ConversationView(
                conversationTitle: "Budget Discussion",
                participants: senders.components(separatedBy: ", "),
                isPresented: $showFullConversation
            )
        }
    }
}

#Preview {
  VStack(spacing: 20) {
    StackableMessageCardView(
      platformIcon: "bubble.left.and.bubble.right.fill",
      senders: "Vincent Chase, Eric Murphy",
      timestamp: "20 mins ago",
      urgency: "High",
      summary: "Vincent wants the Consumer Segmentation report updated with Q3 data and needs approval from Ari before the client presentation tomorrow.",
      actionItems: [
        "Get Ari's approval",
        "Schedule meeting with Product",
        "Update Q3 segmentation data",
        "Prepare client presentation"
      ]
    )
    
    StackableMessageCardView(
      platformIcon: "bubble.left.and.bubble.right.fill",
      senders: "Team Marketing",
      timestamp: "1 hour ago",
      urgency: "Medium",
      summary: "New campaign assets need review and approval from creative director. Timeline is tight for Friday launch.",
      actionItems: [
        "Review creative assets",
        "Get director approval",
        "Schedule launch meeting"
      ]
    )
  }
  .padding()
  .background(Color.black)
  .preferredColorScheme(.dark)
} 
