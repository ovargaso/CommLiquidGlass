//
//  SearchDataModel.swift
//  Comm Liquid Glass
//
//  Created by Oscar Vargas on 6/17/25.
//

import SwiftUI
import Foundation

// MARK: - Search Data Models

enum ContentType: String, CaseIterable {
    case message = "message"
    case contact = "contact"
    case conversation = "conversation"
    case topic = "topic"
    
    var icon: String {
        switch self {
        case .message: return "bubble.left.and.bubble.right.fill"
        case .contact: return "person.circle.fill"
        case .conversation: return "bubble.left.and.bubble.right"
        case .topic: return "tag.fill"
        }
    }
}

enum Platform: String, CaseIterable {
    case slack = "Slack"
    case gmail = "Gmail"
    case outlook = "Outlook"
    case teams = "Teams"
    case discord = "Discord"
    case zoom = "Zoom"
    
    var icon: String {
        switch self {
        case .slack: return "message.fill"
        case .gmail: return "envelope.fill"
        case .outlook: return "mail.fill"
        case .teams: return "video.fill"
        case .discord: return "mic.fill"
        case .zoom: return "video.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .slack: return .purple
        case .gmail: return .red
        case .outlook: return .blue
        case .teams: return .orange
        case .discord: return .indigo
        case .zoom: return .cyan
        }
    }
}

enum Priority: String, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .yellow
        }
    }
}

struct SearchableContent: Identifiable, Hashable {
    let id = UUID()
    let type: ContentType
    let platform: Platform
    let priority: Priority
    let title: String
    let subtitle: String
    let content: String
    let timestamp: String
    let actionItems: [String]
    let participants: [String]
    let tags: [String]
    
    // Computed properties for search
    var searchableText: String {
        "\(title) \(subtitle) \(content) \(participants.joined(separator: " ")) \(tags.joined(separator: " "))"
    }
    
    var platformIcon: String {
        platform.icon
    }
    
    var senders: String {
        participants.joined(separator: ", ")
    }
    
    var urgency: String {
        priority.rawValue
    }
    
    var summary: String {
        content
    }
}

// MARK: - Search Manager

@MainActor
class SearchManager: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [SearchableContent] = []
    @Published var isSearching: Bool = false
    @Published var selectedFilter: ContentType? = nil
    @Published var selectedPlatform: Platform? = nil
    
    private let allContent: [SearchableContent] = MockSearchData.allContent
    
    func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        let filteredContent = allContent.filter { content in
            // Text search
            let matchesText = content.searchableText.localizedCaseInsensitiveContains(searchText)
            
            // Filter by content type if selected
            let matchesFilter = selectedFilter == nil || content.type == selectedFilter
            
            // Filter by platform if selected
            let matchesPlatform = selectedPlatform == nil || content.platform == selectedPlatform
            
            return matchesText && matchesFilter && matchesPlatform
        }
        
        // Sort by priority (High -> Medium -> Low) and then by recency
        searchResults = filteredContent.sorted { lhs, rhs in
            if lhs.priority != rhs.priority {
                switch (lhs.priority, rhs.priority) {
                case (.high, _): return true
                case (_, .high): return false
                case (.medium, .low): return true
                case (.low, .medium): return false
                default: return false
                }
            }
            return lhs.timestamp > rhs.timestamp // More recent first
        }
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        isSearching = false
        selectedFilter = nil
        selectedPlatform = nil
    }
    
    // Quick search suggestions (limited to 4 each for clean UI)
    var popularSearches: [String] {
        Array(["Vincent Chase", "Budget Review", "Q3 data", "Client Meeting", "Product Launch"].prefix(4))
    }
    
    var recentSearches: [String] {
        Array(["Team Standup", "Project Sigma", "Marketing Campaign", "Weekly Sync"].prefix(4))
    }
}

// MARK: - Mock Data

struct MockSearchData {
    static let allContent: [SearchableContent] = [
        // Existing cards from your app
        SearchableContent(
            type: .message,
            platform: .slack,
            priority: .high,
            title: "Consumer Segmentation Report",
            subtitle: "Vincent Chase, Eric Murphy",
            content: "Vincent wants the Consumer Segmentation report updated with Q3 data and needs approval from Ari before the client presentation tomorrow.",
            timestamp: "20 mins ago",
            actionItems: [
                "Get Ari's approval",
                "Schedule meeting with Product",
                "Update Q3 segmentation data",
                "Prepare client presentation"
            ],
            participants: ["Vincent Chase", "Eric Murphy"],
            tags: ["segmentation", "Q3", "client", "presentation", "urgent"]
        ),
        
        SearchableContent(
            type: .message,
            platform: .teams,
            priority: .medium,
            title: "Campaign Asset Review",
            subtitle: "Team Marketing",
            content: "New campaign assets need review and approval from creative director. Timeline is tight for Friday launch.",
            timestamp: "1 hour ago",
            actionItems: [
                "Review creative assets",
                "Get director approval",
                "Schedule launch meeting"
            ],
            participants: ["Team Marketing", "Creative Director"],
            tags: ["campaign", "assets", "review", "launch", "friday"]
        ),
        
        SearchableContent(
            type: .conversation,
            platform: .outlook,
            priority: .low,
            title: "Quarterly Planning",
            subtitle: "Sarah Johnson",
            content: "Quick sync on quarterly goals and budget planning for next quarter.",
            timestamp: "2 hours ago",
            actionItems: [
                "Review quarterly metrics",
                "Plan budget allocation",
                "Schedule team sync"
            ],
            participants: ["Sarah Johnson"],
            tags: ["quarterly", "budget", "planning", "goals", "metrics"]
        ),
        
        // Additional mock content for richer search results
        SearchableContent(
            type: .contact,
            platform: .slack,
            priority: .high,
            title: "Alex Rivera - Product Manager",
            subtitle: "Available for urgent product decisions",
            content: "Lead Product Manager overseeing iOS app development, feature roadmap, and user experience optimization.",
            timestamp: "5 mins ago",
            actionItems: ["Schedule product review", "Discuss feature priorities"],
            participants: ["Alex Rivera"],
            tags: ["product", "manager", "iOS", "roadmap", "UX"]
        ),
        
        SearchableContent(
            type: .message,
            platform: .gmail,
            priority: .high,
            title: "Client Onboarding Issues",
            subtitle: "Customer Success Team",
            content: "Three new enterprise clients are experiencing onboarding delays. Need immediate technical support and account management intervention.",
            timestamp: "15 mins ago",
            actionItems: [
                "Contact technical support",
                "Assign dedicated account manager",
                "Schedule client calls",
                "Prepare compensation plan"
            ],
            participants: ["Customer Success Team", "Technical Support"],
            tags: ["client", "onboarding", "enterprise", "delays", "support"]
        ),
        
        SearchableContent(
            type: .conversation,
            platform: .teams,
            priority: .medium,
            title: "Weekly Engineering Standup",
            subtitle: "Engineering Team",
            content: "Sprint review, blockers discussion, and next iteration planning for the mobile app development team.",
            timestamp: "45 mins ago",
            actionItems: [
                "Review sprint progress",
                "Address technical blockers",
                "Plan next iteration",
                "Update project timeline"
            ],
            participants: ["Engineering Team", "Scrum Master", "Tech Lead"],
            tags: ["engineering", "standup", "sprint", "mobile", "blockers"]
        ),
        
        SearchableContent(
            type: .topic,
            platform: .discord,
            priority: .low,
            title: "Remote Work Guidelines",
            subtitle: "HR & Operations",
            content: "Updated remote work policies, home office stipends, and team collaboration best practices for distributed teams.",
            timestamp: "1 day ago",
            actionItems: [
                "Review new policies",
                "Submit home office requests",
                "Update team calendars"
            ],
            participants: ["HR Team", "Operations"],
            tags: ["remote", "guidelines", "policies", "home office", "collaboration"]
        ),
        
        SearchableContent(
            type: .message,
            platform: .zoom,
            priority: .high,
            title: "Investor Meeting Prep",
            subtitle: "Executive Team",
            content: "Final preparation for Series B investor presentations. Need updated financial models, product demo, and growth projections.",
            timestamp: "30 mins ago",
            actionItems: [
                "Finalize financial models",
                "Prepare product demo",
                "Review growth projections",
                "Schedule practice run"
            ],
            participants: ["CEO", "CFO", "VP Sales"],
            tags: ["investor", "series B", "financial", "demo", "growth"]
        ),
        
        SearchableContent(
            type: .contact,
            platform: .outlook,
            priority: .medium,
            title: "Maria Gonzalez - Design Lead",
            subtitle: "Leading UI/UX design initiatives",
            content: "Senior Design Lead responsible for design system, user research, and cross-platform experience consistency.",
            timestamp: "2 hours ago",
            actionItems: ["Schedule design review", "Discuss design system updates"],
            participants: ["Maria Gonzalez"],
            tags: ["design", "UI", "UX", "research", "design system"]
        ),
        
        SearchableContent(
            type: .message,
            platform: .slack,
            priority: .medium,
            title: "API Performance Issues",
            subtitle: "Backend Team",
            content: "Response times have increased by 40% over the past week. Need to investigate database queries and optimize critical endpoints.",
            timestamp: "3 hours ago",
            actionItems: [
                "Analyze database performance",
                "Optimize slow queries",
                "Review API endpoints",
                "Implement caching strategy"
            ],
            participants: ["Backend Team", "DevOps", "Database Admin"],
            tags: ["API", "performance", "database", "optimization", "caching"]
        ),
        
        SearchableContent(
            type: .conversation,
            platform: .teams,
            priority: .low,
            title: "Company All-Hands Meeting",
            subtitle: "All Employees",
            content: "Monthly company update covering quarterly results, new hires, product updates, and upcoming company events.",
            timestamp: "1 day ago",
            actionItems: [
                "Review quarterly results",
                "Welcome new team members",
                "Share product updates"
            ],
            participants: ["All Employees", "Leadership Team"],
            tags: ["all hands", "company", "quarterly", "updates", "team"]
        ),
        
        SearchableContent(
            type: .topic,
            platform: .gmail,
            priority: .high,
            title: "Security Compliance Audit",
            subtitle: "Security & Compliance Team",
            content: "Annual SOC 2 audit requirements, security policy updates, and employee security training mandatory completion.",
            timestamp: "4 hours ago",
            actionItems: [
                "Complete security training",
                "Update access permissions",
                "Review compliance policies",
                "Submit audit documentation"
            ],
            participants: ["Security Team", "Compliance Officer"],
            tags: ["security", "compliance", "SOC 2", "audit", "training"]
        )
    ]
} 