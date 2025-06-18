//
//  SidebarView.swift
//  Comm Liquid Glass
//
//  Created by Oscar Vargas on 6/17/25.
//

import SwiftUI

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

struct SidebarView: View {
  @Binding var isSidebarOpen: Bool
  let pinnedConversations: [String]
  
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var selectedConversation: String? = nil
  @State private var selectedPlatform: String? = nil
  
  private let platforms = ["Slack", "Gmail", "Outlook", "Teams"]
  
  var body: some View {
    GeometryReader { geometry in
      ZStack {
        if isSidebarOpen {
          // Semi-transparent overlay
          Color.black.opacity(0.4)
            .ignoresSafeArea()
            .onTapGesture {
              withAnimation(.easeInOut(duration: 0.3)) {
                isSidebarOpen = false
              }
            }
            .transition(.opacity)
        }
        
        // Sidebar panel
        HStack {
          if isSidebarOpen {
            VStack(spacing: 0) {
              // Close Button Header
              HStack {
                Spacer()
                Button(action: {
                  print("X button tapped") // Debug
                  withAnimation(.easeInOut(duration: 0.3)) {
                    isSidebarOpen = false
                  }
                }) {
                  Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 28, height: 28)
                    .background(.regularMaterial)
                    .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
              }
              .padding(.top, 12)
              .padding(.trailing, 28)
              .padding(.bottom, 8)
              
              // Scrollable Content
              ScrollView {
                VStack(spacing: 16) {
                  // Pinned Conversations Section
                  VStack(alignment: .leading, spacing: 16) {
                    Text("Pinned Conversations")
                      .font(.system(.title3, design: .rounded, weight: .semibold))
                      .foregroundColor(.white)
                      .padding(.top, 8)
                    
                    ForEach(Array(pinnedConversations.prefix(7)), id: \.self) { pin in
                      Button(action: {
                        selectedConversation = pin
                        selectedPlatform = nil
                      }) {
                        HStack {
                          Text(pin)
                            .font(.body)
                            .foregroundColor(.white)
                          Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .padding(.leading, 16)
                        .background(
                          selectedConversation == pin ? 
                          RoundedRectangle(cornerRadius: 12)
                            .fill(.regularMaterial.opacity(0.8))
                            .overlay(
                              RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                            ) : nil
                        )
                      }
                      .buttonStyle(PlainButtonStyle())
                    }
                  }
                  
                  // Platform Filters Section
                  VStack(alignment: .leading, spacing: 16) {
                    Text("Platforms")
                      .font(.system(.title3, design: .rounded, weight: .semibold))
                      .foregroundColor(.white)
                      .padding(.top, 16)
                    
                    ForEach(platforms, id: \.self) { platform in
                      Button(action: {
                        selectedPlatform = platform
                        selectedConversation = nil
                      }) {
                        HStack {
                          Text(platform)
                            .font(.body)
                            .foregroundColor(.white)
                          Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .padding(.leading, 16)
                        .background(
                          selectedPlatform == platform ? 
                          RoundedRectangle(cornerRadius: 12)
                            .fill(.regularMaterial.opacity(0.8))
                            .overlay(
                              RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                            ) : nil
                        )
                      }
                      .buttonStyle(PlainButtonStyle())
                    }
                  }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
              }
            }
            .frame(width: geometry.size.width * (horizontalSizeClass == .compact ? 0.75 : 0.40))
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
            )
            .transition(.move(edge: .leading))
          }
          
          Spacer()
        }
      }
    }
  }
}

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