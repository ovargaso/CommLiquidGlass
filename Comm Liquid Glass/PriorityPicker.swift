//
//  PriorityPicker.swift
//  Comm Liquid Glass
//
//  Created by Oscar Vargas on 6/17/25.
//

import SwiftUI

enum Priority: String, CaseIterable {
  case high = "High"
  case medium = "Medium"
  case low = "Low"
  
  var color: Color {
    switch self {
    case .high: return .red
    case .medium: return .orange
    case .low: return .green
    }
  }
}

struct Message: Identifiable {
  let id = UUID()
  let title: String
  let sender: String
  let time: String
  let currentPriority: Priority
}

struct PriorityPicker: View {
  @State private var expandedPriority: Priority? = nil
  @State private var messages: [Message] = [
    Message(title: "Urgent: Server maintenance required", sender: "IT Team", time: "2m ago", currentPriority: .high),
    Message(title: "Project deadline reminder", sender: "PM Sarah", time: "5m ago", currentPriority: .medium),
    Message(title: "Team lunch coordination", sender: "HR", time: "10m ago", currentPriority: .low),
    Message(title: "Budget approval needed", sender: "Finance", time: "15m ago", currentPriority: .high),
    Message(title: "Meeting notes from yesterday", sender: "Team Lead", time: "1h ago", currentPriority: .medium)
  ]
  
  var body: some View {
    VStack(spacing: 16) {
      // Priority Buttons Row
      HStack(spacing: 12) {
        ForEach(Priority.allCases, id: \.self) { priority in
          PriorityButton(
            priority: priority,
            isExpanded: expandedPriority == priority,
            messageCount: messages.filter { $0.currentPriority == priority }.count
          ) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
              if expandedPriority == priority {
                expandedPriority = nil
              } else {
                expandedPriority = priority
              }
            }
          }
        }
        Spacer()
      }
      .padding(.horizontal, 20)
      
      // Expanded List
      if let expandedPriority = expandedPriority {
        ExpandedPriorityView(
          priority: expandedPriority,
          messages: messages.filter { $0.currentPriority == expandedPriority },
          onReclassify: { message, newPriority in
            reclassifyMessage(message: message, to: newPriority)
          },
          onClose: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
              self.expandedPriority = nil
            }
          }
        )
        .padding(.horizontal, 20)
        .transition(.asymmetric(
          insertion: .scale(scale: 0.8, anchor: .top).combined(with: .opacity),
          removal: .scale(scale: 0.8, anchor: .top).combined(with: .opacity)
        ))
      }
    }
  }
  
  private func reclassifyMessage(message: Message, to newPriority: Priority) {
    if let index = messages.firstIndex(where: { $0.id == message.id }) {
      messages[index] = Message(
        title: message.title,
        sender: message.sender,
        time: message.time,
        currentPriority: newPriority
      )
    }
  }
}

struct PriorityButton: View {
  let priority: Priority
  let isExpanded: Bool
  let messageCount: Int
  let onTap: () -> Void
  
  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 8) {
        // Priority Indicator Circle
        Circle()
          .fill(priority.color)
          .frame(width: 12, height: 12)
        
        // Priority Text
        Text(priority.rawValue)
          .font(.system(size: 14, weight: .semibold))
          .foregroundColor(.white)
        
        // Message Count Badge
        Text("\(messageCount)")
          .font(.system(size: 12, weight: .bold))
          .foregroundColor(.white)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(
            Capsule()
              .fill(Color.white.opacity(0.2))
          )
        
        // Expansion Arrow
        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
          .font(.system(size: 10, weight: .semibold))
          .foregroundColor(.white.opacity(0.7))
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(
        RoundedRectangle(cornerRadius: 20)
          .fill(isExpanded ? .regularMaterial : .ultraThinMaterial)
          .overlay(
            RoundedRectangle(cornerRadius: 20)
              .stroke(
                isExpanded ? 
                Color.white.opacity(0.3) : 
                Color.white.opacity(0.1), 
                lineWidth: 1
              )
          )
          .shadow(
            color: isExpanded ? 
            Color.black.opacity(0.3) : 
            Color.clear, 
            radius: 8, x: 0, y: 4
          )
      )
      .overlay(
        isExpanded ?
        RoundedRectangle(cornerRadius: 20)
          .fill(
            LinearGradient(
              gradient: Gradient(colors: [Color.white.opacity(0.1), .clear]),
              startPoint: .top,
              endPoint: .bottom
            )
          ) : nil
      )
      .scaleEffect(isExpanded ? 1.05 : 1.0)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

struct ExpandedPriorityView: View {
  let priority: Priority
  let messages: [Message]
  let onReclassify: (Message, Priority) -> Void
  let onClose: () -> Void
  
  var body: some View {
    VStack(spacing: 0) {
      // Header
      HStack {
        HStack(spacing: 8) {
          Circle()
            .fill(priority.color)
            .frame(width: 16, height: 16)
          
          Text("\(priority.rawValue) Priority Messages")
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
        }
        
        Spacer()
        
        Button(action: onClose) {
          Image(systemName: "xmark")
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white.opacity(0.7))
        }
        .buttonStyle(PlainButtonStyle())
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 16)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(.ultraThinMaterial)
          .overlay(
            RoundedRectangle(cornerRadius: 16)
              .stroke(Color.white.opacity(0.1), lineWidth: 1)
          )
      )
      
      // Messages List
      if messages.isEmpty {
        VStack(spacing: 12) {
          Image(systemName: "tray")
            .font(.system(size: 32, weight: .light))
            .foregroundColor(.white.opacity(0.5))
          
          Text("No \(priority.rawValue.lowercased()) priority messages")
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .overlay(
              RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
        )
        .padding(.top, 8)
      } else {
        LazyVStack(spacing: 8) {
          ForEach(messages) { message in
            MessageReclassifyRow(
              message: message,
              onReclassify: { newPriority in
                onReclassify(message, newPriority)
              }
            )
          }
        }
        .padding(.vertical, 12)
        .background(
          RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .overlay(
              RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
        )
        .padding(.top, 8)
      }
    }
  }
}

struct MessageReclassifyRow: View {
  let message: Message
  let onReclassify: (Priority) -> Void
  @State private var showingReclassifyOptions = false
  
  var body: some View {
    HStack(spacing: 12) {
      // Message Info
      VStack(alignment: .leading, spacing: 4) {
        Text(message.title)
          .font(.subheadline)
          .fontWeight(.medium)
          .foregroundColor(.white)
          .lineLimit(1)
        
        HStack(spacing: 8) {
          Text(message.sender)
            .font(.caption)
            .foregroundColor(.white.opacity(0.7))
          
          Text("•")
            .font(.caption)
            .foregroundColor(.white.opacity(0.5))
          
          Text(message.time)
            .font(.caption)
            .foregroundColor(.white.opacity(0.7))
        }
      }
      
      Spacer()
      
      // Reclassify Button
      Menu {
        ForEach(Priority.allCases, id: \.self) { priority in
          if priority != message.currentPriority {
            Button(action: {
              onReclassify(priority)
            }) {
              HStack {
                Circle()
                  .fill(priority.color)
                  .frame(width: 8, height: 8)
                Text("Move to \(priority.rawValue)")
              }
            }
          }
        }
      } label: {
        HStack(spacing: 4) {
          Text("Reclassify")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white.opacity(0.8))
          
          Image(systemName: "chevron.down")
            .font(.system(size: 8, weight: .semibold))
            .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
          Capsule()
            .fill(Color.white.opacity(0.1))
            .overlay(
              Capsule()
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
        )
      }
      .buttonStyle(PlainButtonStyle())
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.white.opacity(0.02))
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
        )
    )
    .padding(.horizontal, 8)
  }
}

#Preview {
  VStack(spacing: 30) {
    PriorityPicker()
  }
  .padding()
  .background(Color.black)
  .preferredColorScheme(.dark)
} 