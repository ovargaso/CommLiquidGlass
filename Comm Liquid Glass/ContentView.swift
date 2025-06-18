//
//  ContentView.swift
//  Comm Liquid Glass
//
//  Created by Oscar Vargas on 6/17/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            DashboardView()
        }
    }
}

struct DashboardView: View {
    @State private var isSidebarOpen = false
    @State private var selectedSort = "High Priority to Low"
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Main content
            VStack(spacing: 16) {
                HeaderView(isSidebarOpen: $isSidebarOpen)
                
                PriorityPicker(selectedSort: $selectedSort)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        MessageCardView(
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
                        
                        MessageCardView(
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
                        
                        MessageCardView(
                            platformIcon: "bubble.left.and.bubble.right.fill",
                            senders: "Sarah Johnson",
                            timestamp: "2 hours ago",
                            urgency: "Low",
                            summary: "Quick sync on quarterly goals and budget planning for next quarter.",
                            actionItems: [
                                "Review quarterly metrics",
                                "Plan budget allocation",
                                "Schedule team sync"
                            ]
                        )
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            // Sidebar overlay
            if isSidebarOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { isSidebarOpen = false }
                    }
                
                SidebarView(
                    isSidebarOpen: $isSidebarOpen,
                    pinnedConversations: [
                        "Project Sigma",
                        "Oscar Vargas",
                        "Team Standup",
                        "Client Meeting",
                        "Budget Review",
                        "Product Launch",
                        "Weekly Sync"
                    ]
                )
                .transition(.move(edge: .leading))
                .ignoresSafeArea(.all, edges: .leading)
            }
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

#Preview("Default") {
    DashboardView()
}

#Preview("Sidebar Open") {
    DashboardView()
        .onAppear {
            // Note: Can't directly set @State in preview, but this shows the concept
        }
}
