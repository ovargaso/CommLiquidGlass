//
//  ConversationView.swift
//  Comm Liquid Glass
//
//  Created by Oscar Vargas on 6/17/25.
//

import SwiftUI

// Enhanced message model for full conversation view
struct FullConversationMessage: Identifiable {
  let id = UUID()
  let sender: String
  let initials: String
  let avatar: String?
  let content: String
  let timestamp: String
  let attachments: [MessageAttachment]
  let isCurrentUser: Bool
  
  init(sender: String, initials: String, avatar: String? = nil, content: String, timestamp: String, attachments: [MessageAttachment] = [], isCurrentUser: Bool = false) {
    self.sender = sender
    self.initials = initials
    self.avatar = avatar
    self.content = content
    self.timestamp = timestamp
    self.attachments = attachments
    self.isCurrentUser = isCurrentUser
  }
}

// Message attachment model
struct MessageAttachment: Identifiable {
  let id = UUID()
  let name: String
  let type: AttachmentType
  let size: String
  let url: String?
  
  enum AttachmentType {
    case pdf, image, document, link
    
    var icon: String {
      switch self {
      case .pdf: return "doc.fill"
      case .image: return "photo.fill"
      case .document: return "doc.text.fill"
      case .link: return "link"
      }
    }
    
    var iconColor: Color {
      switch self {
      case .pdf: return .red
      case .image: return .blue
      case .document: return .blue
      case .link: return .blue
      }
    }
  }
}

// Full conversation message row
struct FullConversationMessageRow: View {
  let message: FullConversationMessage
  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      // Avatar
      if let avatar = message.avatar {
        AsyncImage(url: URL(string: avatar)) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
        } placeholder: {
          ZStack {
            Circle()
              .fill(.ultraThinMaterial)
            Text(message.initials)
              .font(.caption)
              .fontWeight(.medium)
              .foregroundColor(.white)
          }
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
        .overlay(
          Circle()
            .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
      } else {
        ZStack {
          Circle()
            .fill(.ultraThinMaterial)
            .frame(width: 40, height: 40)
            .overlay(
              Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
          
          Text(message.initials)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
        }
      }
      
      // Message content
      VStack(alignment: .leading, spacing: 8) {
        // Header with name and timestamp
        HStack {
          Text(message.sender)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
          
          Spacer()
          
          Text(message.timestamp)
            .font(.caption)
            .foregroundColor(.white.opacity(0.6))
        }
        
        // Message text
        if !message.content.isEmpty {
          Text(message.content)
            .font(.body)
            .foregroundColor(.white.opacity(0.9))
            .fixedSize(horizontal: false, vertical: true)
        }
        
        // Attachments
        if !message.attachments.isEmpty {
          VStack(spacing: 8) {
            ForEach(message.attachments) { attachment in
              AttachmentView(attachment: attachment)
            }
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
  }
}

// Attachment view component
struct AttachmentView: View {
  let attachment: MessageAttachment
  
  var body: some View {
    HStack(spacing: 12) {
      // File icon with type-specific styling
      ZStack {
        RoundedRectangle(cornerRadius: 8)
          .fill(.ultraThinMaterial)
          .frame(width: 40, height: 40)
        
        if attachment.type == .pdf {
          VStack(spacing: 2) {
            Text("PDF")
              .font(.system(size: 8, weight: .bold))
              .foregroundColor(.white)
            Image(systemName: attachment.type.icon)
              .font(.system(size: 14))
              .foregroundColor(attachment.type.iconColor)
          }
        } else {
          Image(systemName: attachment.type.icon)
            .font(.system(size: 18))
            .foregroundColor(attachment.type.iconColor)
        }
      }
      
      // File details
      VStack(alignment: .leading, spacing: 2) {
        Text(attachment.name)
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundColor(.white)
        
        HStack(spacing: 4) {
          Text(attachment.type == .pdf ? "PDF" : "FILE")
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.white.opacity(0.6))
          
          Text("•")
            .font(.caption2)
            .foregroundColor(.white.opacity(0.6))
          
          Text(attachment.size)
            .font(.caption2)
            .foregroundColor(.white.opacity(0.6))
        }
      }
      
      Spacer()
      
      // Download button
      Button(action: {
        // Handle download action
      }) {
        ZStack {
          Circle()
            .fill(.ultraThinMaterial)
            .frame(width: 32, height: 32)
          
          Image(systemName: "arrow.down.circle.fill")
            .font(.system(size: 20))
            .foregroundColor(.white.opacity(0.8))
        }
      }
      .buttonStyle(PlainButtonStyle())
    }
    .padding(12)
    .background(.ultraThinMaterial.opacity(0.5))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(Color.white.opacity(0.1), lineWidth: 1)
    )
  }
}

// Enhanced reply interface for full conversation - floating pill style
struct FullConversationReplyInterface: View {
  @State private var replyText = ""
  @FocusState private var isTextFieldFocused: Bool
  
  var body: some View {
    HStack(spacing: 12) {
      // Text input area
      HStack(spacing: 12) {
        // Custom placeholder and TextField
        ZStack(alignment: .leading) {
          if replyText.isEmpty {
            Text("Type a message...")
              .foregroundColor(.white.opacity(0.5))
              .allowsHitTesting(false)
          }
          
          TextField("", text: $replyText, axis: .vertical)
            .textFieldStyle(PlainTextFieldStyle())
            .foregroundColor(.white)
            .focused($isTextFieldFocused)
        }
        
        // Left side buttons
        HStack(spacing: 16) {
          // Attachment button
          Button(action: {}) {
            Image(systemName: "paperclip")
              .font(.system(size: 18))
              .foregroundColor(.white.opacity(0.7))
          }
          
          // AI assistant button
          Button(action: {}) {
            Image(systemName: "brain.head.profile")
              .font(.system(size: 18))
              .foregroundColor(.white.opacity(0.7))
          }
        }
      }
      
      // Send button
      Button(action: {
        // Handle send action
        replyText = ""
      }) {
        ZStack {
          Circle()
            .fill(.ultraThinMaterial)
            .frame(width: 36, height: 36)
            .overlay(
              Circle()
                .fill(replyText.isEmpty ? Color.clear : Color.blue)
                .frame(width: 36, height: 36)
            )
          
          Image(systemName: "paperplane.fill")
            .font(.system(size: 16))
            .foregroundColor(replyText.isEmpty ? .white.opacity(0.5) : .white)
        }
      }
      .buttonStyle(PlainButtonStyle())
      .disabled(replyText.isEmpty)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .background(
      Capsule()
        .fill(.ultraThinMaterial)
        .overlay(
          Capsule()
            .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    )
  }
}

// Main conversation view
struct ConversationView: View {
  let conversationTitle: String
  let participants: [String]
  @Binding var isPresented: Bool
  
  @State private var messages: [FullConversationMessage] = []
  
  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        // Custom header
        VStack(spacing: 8) {
          HStack {
            // Back button
            Button(action: {
              isPresented = false
            }) {
              HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                  .font(.system(size: 16, weight: .medium))
                Text("Back")
                  .font(.body)
              }
              .foregroundColor(.blue)
            }
            
            Spacer()
            
            // More options
            Button(action: {}) {
              Image(systemName: "ellipsis.circle")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.7))
            }
          }
          .padding(.horizontal, 16)
          .padding(.top, 8)
          
          // Conversation title and participants
          VStack(spacing: 4) {
            Text(conversationTitle)
              .font(.headline)
              .fontWeight(.semibold)
              .foregroundColor(.white)
            
            Text(participants.joined(separator: ", "))
              .font(.subheadline)
              .foregroundColor(.white.opacity(0.7))
          }
          .padding(.horizontal, 16)
          .padding(.bottom, 12)
        }
        .background(.regularMaterial)
        
        // Messages list with floating reply interface
        ZStack(alignment: .bottom) {
          ScrollView {
            LazyVStack(spacing: 0) {
              ForEach(messages) { message in
                FullConversationMessageRow(message: message)
              }
            }
            .padding(.top, 16)
            .padding(.bottom, 80) // Add bottom padding to prevent content hiding behind floating interface
          }
          .background(Color.black.opacity(0.3))
          
          // Floating reply interface
          VStack {
            Spacer()
            FullConversationReplyInterface()
              .padding(.horizontal, 16)
              .padding(.bottom, 16)
          }
        }
      }
      .background(Color.black)
      .navigationBarHidden(true)
    }
    .onAppear {
      loadConversationData()
    }
  }
  
  private func loadConversationData() {
    // Sample conversation data based on your image
    messages = [
      FullConversationMessage(
        sender: "David McCare",
        initials: "DM",
        content: "Great, Charlie! I've been working on the budget estimates. Are there any specific figures we need to hit?",
        timestamp: "Today, 10:04 AM"
      ),
      FullConversationMessage(
        sender: "Charlie Michelle",
        initials: "CM",
        content: "David, could you send a draft over for review?",
        timestamp: "Today, 10:14 AM"
      ),
      FullConversationMessage(
        sender: "David McCare",
        initials: "DM",
        content: "Here's the rough draft. Do you guys have any concerns?",
        timestamp: "Today, 11:23 AM",
        attachments: [
          MessageAttachment(
            name: "Budget-Draft",
            type: .pdf,
            size: "2.35Mb",
            url: nil
          )
        ]
      ),
      FullConversationMessage(
        sender: "Bob Marco",
        initials: "BM",
        content: "I've noticed a potential risk in the timeline. We might need a contingency plan.",
        timestamp: "Today, 12:59 PM"
      ),
      FullConversationMessage(
        sender: "Charlie Michelle",
        initials: "CM",
        content: "Good point, Bob. Let's schedule a meeting to discuss the contingency plan and review the budget in detail. I can set up a call for tomorrow morning if everyone is available.",
        timestamp: "Today, 1:15 PM"
      ),
      FullConversationMessage(
        sender: "David McCare",
        initials: "DM",
        content: "That works for me. I'll have the revised budget ready by then with some alternative scenarios included.",
        timestamp: "Today, 1:22 PM"
      )
    ]
  }
}

#Preview {
  ConversationView(
    conversationTitle: "Budget Discussion",
    participants: ["David McCare", "Charlie Michelle", "Bob Marco"],
    isPresented: .constant(true)
  )
  .preferredColorScheme(.dark)
} 