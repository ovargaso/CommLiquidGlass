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
    @State private var expandedCardIndex: Int? = nil
    @State private var isSearchFieldFocused = false
    @StateObject private var searchManager = SearchManager()
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background tap to dismiss search
            if isSearchFieldFocused {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSearchFieldFocused = false
                        }
                    }
                    .zIndex(-1) // Behind everything
            }
            
            // Main content
            VStack(spacing: 16) {
                HeaderView(isSidebarOpen: $isSidebarOpen, searchManager: searchManager, isSearchFieldFocused: $isSearchFieldFocused)
                
                // Show priority picker only when not searching
                if !searchManager.isSearching && searchManager.searchText.isEmpty {
                    PriorityPicker(selectedSort: $selectedSort)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                }
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Show search results when searching
                        if searchManager.isSearching || !searchManager.searchText.isEmpty {
                            SearchResultsView(
                                results: searchManager.searchResults,
                                isSearching: searchManager.isSearching || !searchManager.searchText.isEmpty,
                                searchManager: searchManager
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                        } else {
                            // Show default message cards when not searching
                            Group {
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
                                
                                StackableMessageCardView(
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
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            ))
                        }
                    }
                }
            }
            
            // Sidebar overlay
            if isSidebarOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { 
                            isSidebarOpen = false 
                        }
                    }
                    .transition(.opacity)
                
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
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isSidebarOpen)
                .zIndex(1) // Ensure sidebar receives gestures properly
            }
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: searchManager.isSearching)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: searchManager.searchText.isEmpty)
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
