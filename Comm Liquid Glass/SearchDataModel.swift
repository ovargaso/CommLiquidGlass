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

// Action item with completion state
struct ActionItem: Identifiable, Hashable {
    let id = UUID()
    let text: String
    var isCompleted: Bool = false
}

// Filter preset for quick filter combinations
struct FilterPreset: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let priorities: [Priority]
    let platforms: [Platform]
    let contentTypes: [ContentType]
    let dateRange: DateRange
    let searchTerms: [String]
    
    init(name: String, icon: String, color: Color, 
         priorities: [Priority] = [], 
         platforms: [Platform] = [], 
         contentTypes: [ContentType] = [], 
         dateRange: DateRange = .allTime, 
         searchTerms: [String] = []) {
        self.name = name
        self.icon = icon
        self.color = color
        self.priorities = priorities
        self.platforms = platforms
        self.contentTypes = contentTypes
        self.dateRange = dateRange
        self.searchTerms = searchTerms
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
    var actionItems: [ActionItem]
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

// Filter types for the pill system
enum FilterCategory: String, CaseIterable {
    case priority = "Priority"
    case platform = "Platform"
    case contentType = "Type"
    case dateRange = "Date"
}

enum DateRange: String, CaseIterable {
    case today = "Today"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case thisQuarter = "This Quarter"
    case lastQuarter = "Last Quarter"
    case allTime = "All Time"
    
    var displayName: String { rawValue }
    
    func matches(timestamp: String) -> Bool {
        // For demo purposes, we'll use simple string matching
        // In a real app, you'd parse actual dates
        switch self {
        case .today:
            return timestamp.contains("mins ago") || timestamp.contains("hour ago")
        case .thisWeek:
            return timestamp.contains("mins ago") || timestamp.contains("hour") || timestamp.contains("day ago") || timestamp.contains("days ago")
        case .thisMonth:
            return !timestamp.contains("months ago") && !timestamp.contains("year ago") && !timestamp.contains("quarter ago")
        case .thisQuarter:
            // Current quarter: anything up to 3 months old
            return !timestamp.contains("months ago") || 
                   timestamp.contains("1 month ago") || 
                   timestamp.contains("2 months ago") || 
                   timestamp.contains("3 months ago")
        case .lastQuarter:
            // Previous quarter: 3-6 months ago
            return timestamp.contains("3 months ago") || 
                   timestamp.contains("4 months ago") || 
                   timestamp.contains("5 months ago") || 
                   timestamp.contains("6 months ago") ||
                   timestamp.contains("quarter ago")
        case .allTime:
            return true
        }
    }
    
    var icon: String {
        switch self {
        case .today: return "clock.fill"
        case .thisWeek: return "calendar.day.timeline.leading"
        case .thisMonth: return "calendar"
        case .thisQuarter: return "calendar.badge.clock"
        case .lastQuarter: return "clock.arrow.circlepath"
        case .allTime: return "infinity"
        }
    }
    
    var description: String {
        switch self {
        case .today: return "Last 24 hours"
        case .thisWeek: return "Last 7 days"
        case .thisMonth: return "Last 30 days"
        case .thisQuarter: return "Last 3 months"
        case .lastQuarter: return "3-6 months ago"
        case .allTime: return "No time limit"
        }
    }
}

@MainActor
class SearchManager: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [SearchableContent] = []
    @Published var isSearching: Bool = false
    
    // TESTING: Move selectedPill here for centralized state management
    @Published var selectedPill: String? = nil
    
    // Enhanced filter state
    @Published var selectedPriorities: Set<Priority> = []
    @Published var selectedPlatforms: Set<Platform> = []
    @Published var selectedContentTypes: Set<ContentType> = []
    @Published var selectedDateRange: DateRange = .allTime
    
    // Legacy filters for backward compatibility
    @Published var selectedFilter: ContentType? = nil
    @Published var selectedPlatform: Platform? = nil
    
    private let allContent: [SearchableContent] = MockSearchData.allContent
    
    // Computed property to check if any filters are active
    var hasActiveFilters: Bool {
        !selectedPriorities.isEmpty || 
        !selectedPlatforms.isEmpty || 
        !selectedContentTypes.isEmpty || 
        selectedDateRange != .allTime
    }
    
    // Count of active filters for UI display
    var activeFilterCount: Int {
        var count = 0
        if !selectedPriorities.isEmpty { count += 1 }
        if !selectedPlatforms.isEmpty { count += 1 }
        if !selectedContentTypes.isEmpty { count += 1 }
        if selectedDateRange != .allTime { count += 1 }
        return count
    }
    
    func performSearch() {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If no search text and no filters, clear results
        guard !trimmedText.isEmpty || hasActiveFilters else {
            searchResults = []
            isSearching = false
            return
        }
        
        isSearching = true
        
        let filteredContent = allContent.filter { content in
            // Text search (only apply if there's search text)
            let matchesText = trimmedText.isEmpty || content.searchableText.localizedCaseInsensitiveContains(trimmedText)
            
            // Priority filter
            let matchesPriority = selectedPriorities.isEmpty || selectedPriorities.contains(content.priority)
            
            // Platform filter
            let matchesPlatform = selectedPlatforms.isEmpty || selectedPlatforms.contains(content.platform)
            
            // Content type filter
            let matchesContentType = selectedContentTypes.isEmpty || selectedContentTypes.contains(content.type)
            
            // Date range filter
            let matchesDateRange = selectedDateRange.matches(timestamp: content.timestamp)
            
            // Legacy filter compatibility
            let matchesLegacyFilter = selectedFilter == nil || content.type == selectedFilter
            let matchesLegacyPlatform = selectedPlatform == nil || content.platform == selectedPlatform
            
            return matchesText && matchesPriority && matchesPlatform && 
                   matchesContentType && matchesDateRange && 
                   matchesLegacyFilter && matchesLegacyPlatform
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
    
    // MARK: - Filter Actions
    
    func togglePriority(_ priority: Priority) {
        if selectedPriorities.contains(priority) {
            selectedPriorities.remove(priority)
        } else {
            selectedPriorities.insert(priority)
        }
        performSearch()
    }
    
    func togglePlatform(_ platform: Platform) {
        if selectedPlatforms.contains(platform) {
            selectedPlatforms.remove(platform)
        } else {
            selectedPlatforms.insert(platform)
        }
        performSearch()
    }
    
    func toggleContentType(_ contentType: ContentType) {
        if selectedContentTypes.contains(contentType) {
            selectedContentTypes.remove(contentType)
        } else {
            selectedContentTypes.insert(contentType)
        }
        performSearch()
    }
    
    func setDateRange(_ dateRange: DateRange) {
        selectedDateRange = dateRange
        performSearch()
    }
    
    func clearAllFilters() {
        selectedPriorities.removeAll()
        selectedPlatforms.removeAll()
        selectedContentTypes.removeAll()
        selectedDateRange = .allTime
        selectedFilter = nil
        selectedPlatform = nil
        performSearch()
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        isSearching = false
        clearAllFilters()
        // Also clear any search-related state
        selectedFilter = nil
        selectedPlatform = nil
        selectedPill = nil // Clear pill when clearing search
    }
    

    
    // MARK: - Smart Search Suggestions
    
    // Filter-aware search suggestions that adapt based on active filters
    var smartSearchSuggestions: [String] {
        var suggestions: [String] = []
        
        // Priority-based suggestions
        if selectedPriorities.contains(.high) {
            suggestions.append(contentsOf: ["Critical Issues", "Urgent Reviews", "Immediate Actions"])
        }
        if selectedPriorities.contains(.medium) {
            suggestions.append(contentsOf: ["Weekly Sync", "Progress Update", "Team Meeting"])
        }
        if selectedPriorities.contains(.low) {
            suggestions.append(contentsOf: ["Documentation", "Best Practices", "Process Improvements"])
        }
        
        // Platform-specific suggestions
        if selectedPlatforms.contains(.slack) {
            suggestions.append(contentsOf: ["Team Chat", "Quick Updates", "Notifications"])
        }
        if selectedPlatforms.contains(.gmail) || selectedPlatforms.contains(.outlook) {
            suggestions.append(contentsOf: ["Email Thread", "Stakeholder Update", "External Communication"])
        }
        if selectedPlatforms.contains(.teams) || selectedPlatforms.contains(.zoom) {
            suggestions.append(contentsOf: ["Meeting Notes", "Video Call", "Collaboration Session"])
        }
        
        // Content type suggestions
        if selectedContentTypes.contains(.message) {
            suggestions.append(contentsOf: ["Discussion", "Announcement", "Update"])
        }
        if selectedContentTypes.contains(.conversation) {
            suggestions.append(contentsOf: ["Thread", "Dialogue", "Exchange"])
        }
        if selectedContentTypes.contains(.contact) {
            suggestions.append(contentsOf: ["Team Member", "Stakeholder", "Expert"])
        }
        
        // Date range suggestions
        switch selectedDateRange {
        case .today:
            suggestions.append(contentsOf: ["Today's Updates", "Recent Changes", "Latest News"])
        case .thisWeek:
            suggestions.append(contentsOf: ["This Week", "Weekly Report", "Current Sprint"])
        case .thisQuarter:
            suggestions.append(contentsOf: ["Quarterly Review", "Q1 Goals", "Strategic Planning"])
        case .lastQuarter:
            suggestions.append(contentsOf: ["Previous Quarter", "Historical Data", "Past Results"])
        default:
            break
        }
        
        // Remove duplicates and return first 6
        return Array(Set(suggestions)).prefix(6).map { $0 }
    }
    
    // Quick filter combinations - popular filter presets
    var quickFilterPresets: [FilterPreset] {
        [
            FilterPreset(
                name: "High Priority Today",
                icon: "exclamationmark.triangle.fill",
                color: .red,
                priorities: [.high],
                dateRange: .today
            ),
            FilterPreset(
                name: "Team Discussions",
                icon: "bubble.left.and.bubble.right.fill",
                color: .blue,
                platforms: [.slack, .teams],
                contentTypes: [.message, .conversation]
            ),
            FilterPreset(
                name: "This Week's Work",
                icon: "calendar.badge.clock",
                color: .green,
                priorities: [.high, .medium],
                dateRange: .thisWeek
            ),
            FilterPreset(
                name: "Email Communications",
                icon: "envelope.fill",
                color: .orange,
                platforms: [.gmail, .outlook],
                contentTypes: [.message, .conversation]
            ),
            FilterPreset(
                name: "Research & Discovery",
                icon: "magnifyingglass.circle.fill",
                color: .purple,
                searchTerms: ["research", "discovery", "user", "analysis"]
            ),
            FilterPreset(
                name: "Design & UX",
                icon: "paintbrush.fill",
                color: .pink,
                searchTerms: ["design", "UX", "UI", "wireframe", "prototype"]
            )
        ]
    }
    
    // Dynamic placeholder text based on active filters
    var smartPlaceholder: String {
        var context: [String] = []
        
        if !selectedPriorities.isEmpty {
            let priorities = selectedPriorities.map { $0.rawValue.lowercased() }.joined(separator: ", ")
            context.append("\(priorities) priority")
        }
        
        if !selectedPlatforms.isEmpty {
            let platforms = selectedPlatforms.map { $0.rawValue }.joined(separator: ", ")
            context.append("in \(platforms)")
        }
        
        if !selectedContentTypes.isEmpty {
            let types = selectedContentTypes.map { $0.rawValue }.joined(separator: ", ")
            context.append("\(types) content")
        }
        
        if selectedDateRange != .allTime {
            context.append("from \(selectedDateRange.displayName.lowercased())")
        }
        
        if context.isEmpty {
            return "Search by name, topic, or keyword"
        } else {
            return "Search \(context.joined(separator: " "))..."
        }
    }
    
    // Legacy search suggestions for when no filters are active
    var popularSearches: [String] {
        Array(["User Research", "Design System", "Product Roadmap", "A/B Testing"].prefix(4))
    }
    
    var recentSearches: [String] {
        Array(["UX Research", "Design Review", "Product Sprint", "User Journey"].prefix(4))
    }
    
    // MARK: - Quick Filter Actions
    
    func applyFilterPreset(_ preset: FilterPreset) {
        // Clear existing filters
        clearAllFilters()
        
        // Apply preset filters
        selectedPriorities = Set(preset.priorities)
        selectedPlatforms = Set(preset.platforms)
        selectedContentTypes = Set(preset.contentTypes)
        selectedDateRange = preset.dateRange
        
        // Apply search terms if any
        if !preset.searchTerms.isEmpty {
            searchText = preset.searchTerms.joined(separator: " ")
        }
        
        performSearch()
    }
}

// MARK: - Mock Data

struct MockSearchData {
    static let allContent: [SearchableContent] = [
        // Product Manager focused content
        SearchableContent(
            type: .message,
            platform: .slack,
            priority: .high,
            title: "User Research Findings",
            subtitle: "Emily Chen, Product Research",
            content: "Latest user interviews reveal 73% of users struggle with our onboarding flow. Need to prioritize UX improvements before Q4 launch.",
            timestamp: "20 mins ago",
            actionItems: [
                ActionItem(text: "Review user interview recordings"),
                ActionItem(text: "Update onboarding wireframes"),
                ActionItem(text: "Schedule design sprint"),
                ActionItem(text: "Validate solutions with PM team")
            ],
            participants: ["Emily Chen", "Product Research"],
            tags: ["user research", "onboarding", "UX", "interviews", "Q4"]
        ),
        
        SearchableContent(
            type: .message,
            platform: .teams,
            priority: .medium,
            title: "Design System Updates",
            subtitle: "Design Team",
            content: "New component library ready for review. Updated button styles, form elements, and navigation patterns based on accessibility guidelines.",
            timestamp: "1 hour ago",
            actionItems: [
                ActionItem(text: "Review component library"),
                ActionItem(text: "Test accessibility compliance"),
                ActionItem(text: "Update design documentation"),
                ActionItem(text: "Schedule implementation with dev team")
            ],
            participants: ["Design Team", "UI/UX Lead"],
            tags: ["design system", "components", "accessibility", "documentation"]
        ),
        
        SearchableContent(
            type: .conversation,
            platform: .outlook,
            priority: .low,
            title: "Product Roadmap Planning",
            subtitle: "Sarah Martinez - Senior PM",
            content: "Quarterly roadmap review focusing on feature prioritization, user impact metrics, and resource allocation for next quarter.",
            timestamp: "2 hours ago",
            actionItems: [
                ActionItem(text: "Analyze feature impact scores"),
                ActionItem(text: "Review resource capacity"),
                ActionItem(text: "Update roadmap timeline"),
                ActionItem(text: "Prepare stakeholder presentation")
            ],
            participants: ["Sarah Martinez"],
            tags: ["product roadmap", "feature prioritization", "metrics", "planning"]
        ),
        
        // Product Research focused content
        SearchableContent(
            type: .contact,
            platform: .slack,
            priority: .high,
            title: "Dr. Alex Rivera - Head of Product Research",
            subtitle: "Leading user research and product discovery",
            content: "Senior Product Researcher specializing in user behavior analysis, usability testing, and product discovery methodologies.",
            timestamp: "5 mins ago",
            actionItems: [ActionItem(text: "Schedule research planning session"), ActionItem(text: "Review user testing protocols")],
            participants: ["Dr. Alex Rivera"],
            tags: ["product research", "user behavior", "usability testing", "discovery"]
        ),
        
        SearchableContent(
            type: .message,
            platform: .gmail,
            priority: .high,
            title: "A/B Test Results Critical",
            subtitle: "Product Analytics Team",
            content: "Checkout flow experiment shows 15% conversion drop. Need immediate product decision on whether to rollback or iterate based on user feedback data.",
            timestamp: "15 mins ago",
            actionItems: [
                ActionItem(text: "Analyze user behavior data"),
                ActionItem(text: "Review heatmap recordings"),
                ActionItem(text: "Consult with UX research team"),
                ActionItem(text: "Make rollback decision by EOD")
            ],
            participants: ["Product Analytics Team", "Data Science"],
            tags: ["A/B testing", "conversion", "checkout", "user feedback", "analytics"]
        ),
        
        SearchableContent(
            type: .conversation,
            platform: .teams,
            priority: .medium,
            title: "Weekly Product Discovery",
            subtitle: "Product Research Team",
            content: "User interview insights, competitor analysis findings, and market research updates for upcoming feature development sprint.",
            timestamp: "45 mins ago",
            actionItems: [
                ActionItem(text: "Synthesize user interview data"),
                ActionItem(text: "Update competitor feature matrix"),
                ActionItem(text: "Prepare research insights report"),
                ActionItem(text: "Plan next week's user sessions")
            ],
            participants: ["Product Research Team", "UX Researchers"],
            tags: ["product discovery", "user interviews", "competitor analysis", "market research"]
        ),
        
        // Product Design focused content
        SearchableContent(
            type: .topic,
            platform: .discord,
            priority: .low,
            title: "Design Critique Guidelines",
            subtitle: "Design Team & Product",
            content: "Updated design review process, feedback frameworks, and collaboration protocols between design and product management teams.",
            timestamp: "1 day ago",
            actionItems: [
                ActionItem(text: "Review critique framework"),
                ActionItem(text: "Schedule design review sessions"),
                ActionItem(text: "Update feedback templates")
            ],
            participants: ["Design Team", "Product Team"],
            tags: ["design critique", "feedback", "collaboration", "review process"]
        ),
        
        SearchableContent(
            type: .message,
            platform: .zoom,
            priority: .high,
            title: "User Journey Mapping Session",
            subtitle: "UX Design & Product Team",
            content: "Critical mapping session for new user onboarding experience. Need product requirements, design wireframes, and user research insights.",
            timestamp: "30 mins ago",
            actionItems: [
                ActionItem(text: "Complete user journey maps"),
                ActionItem(text: "Define key user touchpoints"),
                ActionItem(text: "Create wireframe prototypes"),
                ActionItem(text: "Validate with user research data")
            ],
            participants: ["UX Designer", "Product Manager", "User Researcher"],
            tags: ["user journey", "onboarding", "wireframes", "touchpoints"]
        ),
        
        SearchableContent(
            type: .contact,
            platform: .outlook,
            priority: .medium,
            title: "Maria Santos - Lead Product Designer",
            subtitle: "Senior designer focused on user experience",
            content: "Lead Product Designer responsible for end-to-end user experience, design system maintenance, and cross-functional product collaboration.",
            timestamp: "2 hours ago",
            actionItems: [ActionItem(text: "Schedule design system review"), ActionItem(text: "Plan user testing sessions")],
            participants: ["Maria Santos"],
            tags: ["product design", "user experience", "design system", "collaboration"]
        ),
        
        SearchableContent(
            type: .message,
            platform: .slack,
            priority: .medium,
            title: "Prototype Testing Results",
            subtitle: "UX Research & Design",
            content: "Interactive prototype testing reveals navigation confusion in 60% of users. Need design iterations before development handoff next week.",
            timestamp: "3 hours ago",
            actionItems: [
                ActionItem(text: "Analyze prototype test recordings"),
                ActionItem(text: "Redesign navigation flow"),
                ActionItem(text: "Create updated interactive prototype"),
                ActionItem(text: "Schedule follow-up user testing")
            ],
            participants: ["UX Research", "Product Design Team"],
            tags: ["prototype testing", "navigation", "user testing", "design iteration"]
        ),
        
        SearchableContent(
            type: .conversation,
            platform: .teams,
            priority: .low,
            title: "Product Design All-Hands",
            subtitle: "All Product & Design Teams",
            content: "Monthly sync covering design system updates, research insights, product feature prioritization, and cross-team collaboration.",
            timestamp: "1 day ago",
            actionItems: [
                ActionItem(text: "Review design system changelog"),
                ActionItem(text: "Share research findings"),
                ActionItem(text: "Align on feature priorities")
            ],
            participants: ["Product Team", "Design Team", "Research Team"],
            tags: ["design all-hands", "design system", "research insights", "collaboration"]
        ),
        
        SearchableContent(
            type: .topic,
            platform: .gmail,
            priority: .high,
            title: "Product Discovery Workshop",
            subtitle: "Product Management & Research",
            content: "Intensive 2-day workshop on user needs identification, problem validation methodologies, and product opportunity assessment.",
            timestamp: "4 hours ago",
            actionItems: [
                ActionItem(text: "Prepare user persona research"),
                ActionItem(text: "Define problem hypotheses"),
                ActionItem(text: "Create opportunity scoring framework"),
                ActionItem(text: "Schedule stakeholder interviews")
            ],
            participants: ["Product Managers", "Product Researchers"],
            tags: ["product discovery", "user needs", "problem validation", "opportunity assessment"]
        ),
        
        // Quarter-relevant content for testing new filters
        SearchableContent(
            type: .message,
            platform: .slack,
            priority: .high,
            title: "Q1 Performance Review",
            subtitle: "Product Team Quarterly Review",
            content: "Comprehensive review of Q1 goals, metrics achieved, and strategic learnings for upcoming quarter planning.",
            timestamp: "1 month ago",
            actionItems: [
                ActionItem(text: "Analyze Q1 metrics"),
                ActionItem(text: "Document key learnings"),
                ActionItem(text: "Prepare Q2 strategic plan")
            ],
            participants: ["Product Team", "Leadership"],
            tags: ["quarterly review", "performance", "metrics", "strategy"]
        ),
        
        SearchableContent(
            type: .conversation,
            platform: .teams,
            priority: .medium,
            title: "Design System Migration",
            subtitle: "Design & Engineering Teams",
            content: "Major design system overhaul completed, migrating legacy components to new design tokens and component architecture.",
            timestamp: "2 months ago",
            actionItems: [
                ActionItem(text: "Complete component audit"),
                ActionItem(text: "Update design documentation"),
                ActionItem(text: "Train teams on new system")
            ],
            participants: ["Design System Team", "Engineering"],
            tags: ["design system", "migration", "components", "design tokens"]
        ),
        
        SearchableContent(
            type: .topic,
            platform: .outlook,
            priority: .low,
            title: "Annual Product Strategy",
            subtitle: "Strategic Planning Session",
            content: "Annual product roadmap and strategic direction setting for the upcoming year based on market research and user feedback.",
            timestamp: "4 months ago",
            actionItems: [
                ActionItem(text: "Conduct market analysis"),
                ActionItem(text: "Review user feedback"),
                ActionItem(text: "Define strategic priorities")
            ],
            participants: ["Product Leadership", "Strategy Team"],
            tags: ["annual planning", "product strategy", "roadmap", "market analysis"]
        ),
        
        SearchableContent(
            type: .message,
            platform: .discord,
            priority: .medium,
            title: "User Research Initiative",
            subtitle: "Research Team Retrospective",
            content: "Last quarter's user research initiative results, methodology improvements, and recommendations for ongoing research programs.",
            timestamp: "5 months ago",
            actionItems: [
                ActionItem(text: "Analyze research outcomes"),
                ActionItem(text: "Improve research methodology"),
                ActionItem(text: "Plan ongoing research program")
            ],
            participants: ["Research Team", "Product Team"],
            tags: ["user research", "retrospective", "methodology", "research program"]
        ),
        
        SearchableContent(
            type: .contact,
            platform: .zoom,
            priority: .high,
            title: "Product Leadership Sync",
            subtitle: "Executive Team Alignment",
            content: "Strategic alignment session between product leadership and executive team on company direction and product priorities.",
            timestamp: "3 months ago",
            actionItems: [
                ActionItem(text: "Align on strategic direction"),
                ActionItem(text: "Review product priorities"),
                ActionItem(text: "Plan resource allocation")
            ],
            participants: ["Product Leadership", "Executive Team"],
            tags: ["leadership", "strategy", "alignment", "priorities"]
        )
    ]
} 
