//
//  SearchResultsView.swift
//  Comm Liquid Glass
//
//  Created by Oscar Vargas on 6/17/25.
//

import SwiftUI

// MARK: - Search Result Card Component
struct SearchResultCard: View {
    @State var content: SearchableContent // Made @State to allow mutation for action item completion
    @State private var isExpanded = false
    @State private var isPressed = false
    @State private var isHovered = false
    @State private var showFullConversation = false
    @State private var cardOffset: CGSize = .zero
    @State private var cardRotation: Double = 0.0
    @State private var glowOpacity: Double = 0.0
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        Button(action: {
            // Enhanced haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Fluid card tap animation sequence
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                cardOffset = CGSize(width: 0, height: -3)
                cardRotation = Double.random(in: -0.5...0.5)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    cardOffset = .zero
                    cardRotation = 0.0
                }
                showFullConversation = true
            }
        }) {
            cardContent
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.96 : (isHovered ? 1.01 : 1.0))
        .offset(cardOffset)
        .rotationEffect(.degrees(cardRotation))
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = pressing
            }
        }, perform: {})
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.3)) {
                isHovered = hovering
                glowOpacity = hovering ? 0.4 : 0.0
            }
            
            // Trigger shimmer effect on hover
            if hovering {
                triggerShimmerEffect()
            }
        }
        .overlay(
            // Enhanced hover glow with gradient
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(glowOpacity * 0.8),
                            Color.cyan.opacity(glowOpacity * 0.6),
                            Color.blue.opacity(glowOpacity * 0.4),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .opacity(glowOpacity)
                .scaleEffect(isHovered ? 1.02 : 1.0)
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPressed)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isHovered)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: cardOffset)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: cardRotation)
        .animation(.easeInOut(duration: 0.3), value: glowOpacity)
        .fullScreenCover(isPresented: $showFullConversation) {
            ConversationView(
                conversationTitle: content.title,
                participants: content.participants,
                isPresented: $showFullConversation
            )
        }
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            contentPreview
            actionItemsSection
            tagsSection
        }
        .padding(16)
        .background(cardBackground)
        .overlay(cardBorder)
        .overlay(
            // Shimmer effect overlay
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .offset(x: shimmerOffset)
                .opacity(isHovered ? 0.8 : 0.0)
                .animation(.easeInOut(duration: 0.8), value: shimmerOffset)
        )
        .shadow(
            color: isPressed ? Color.blue.opacity(0.4) : (isHovered ? Color.black.opacity(0.3) : Color.black.opacity(0.2)), 
            radius: isPressed ? 16 : (isHovered ? 12 : 8), 
            x: 0, 
            y: isPressed ? 8 : (isHovered ? 6 : 4)
        )
    }
    
    private var headerSection: some View {
        HStack(alignment: .top, spacing: 12) {
            // Platform Icon with glass background
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                
                Image(systemName: content.platformIcon)
                    .foregroundColor(content.platform.color)
                    .font(.system(size: 16, weight: .medium))
            }
            
            // Content info
            VStack(alignment: .leading, spacing: 4) {
                Text(content.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(content.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
                
                Text(content.timestamp)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Priority Badge
            Text(content.priority.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(content.priority.color)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private var contentPreview: some View {
        Text(content.content)
            .font(.callout)
            .foregroundColor(.white.opacity(0.9))
            .lineLimit(isExpanded ? nil : 3)
            .truncationMode(.tail)
            .padding(.leading, 48)
    }
    
    private var actionItemsSection: some View {
        Group {
            if !content.actionItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    // Separator
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.leading, 48)
                    
                    actionItemsHeader
                    
                    if isExpanded {
                        actionItemsList
                    }
                }
            }
        }
    }
    
    private var actionItemsHeader: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded.toggle()
            }
        }) {
            HStack(spacing: 12) {
                // Arrow perfectly centered with platform icon above
                ZStack {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                
                Text("Action Items (\(content.actionItems.count))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var actionItemsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(content.actionItems.indices, id: \.self) { index in
                actionItemRow(at: index)
            }
        }
        .padding(.top, 8)
        .padding(.leading, 48)
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
            removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
        ))
    }
    
    private var tagsSection: some View {
        Group {
            if !content.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(content.tags.prefix(5)), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.leading, 48)
                }
            }
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isPressed ? Color.white.opacity(0.1) : 
                        isHovered ? Color.white.opacity(0.05) : 
                        Color.clear
                    )
            )
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                isPressed ? Color.blue.opacity(0.3) :
                isHovered ? Color.white.opacity(0.2) :
                Color.white.opacity(0.1), 
                lineWidth: isPressed || isHovered ? 1.5 : 1
            )

    }
    
    // MARK: - Action Item Row with Checkbox
    private func actionItemRow(at index: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                content.actionItems[index].isCompleted.toggle()
            }
        }) {
            HStack(spacing: 12) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 18, height: 18)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(content.actionItems[index].isCompleted ? Color.blue : Color.clear)
                        )
                    
                    if content.actionItems[index].isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Action item text with strikethrough when completed
                Text(content.actionItems[index].text)
                    .font(.body)
                    .foregroundColor(
                        content.actionItems[index].isCompleted ? 
                        .white.opacity(0.5) : 
                        .white.opacity(0.8)
                    )
                    .strikethrough(content.actionItems[index].isCompleted)
                
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Animation Functions
    private func triggerShimmerEffect() {
        shimmerOffset = -200
        withAnimation(.easeInOut(duration: 0.8)) {
            shimmerOffset = 200
        }
    }
}

// MARK: - Search Results Container
struct SearchResultsView: View {
    let results: [SearchableContent]
    let isSearching: Bool
    @ObservedObject var searchManager: SearchManager
    
    var body: some View {
        if isSearching && !results.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                // Smart Results Header with organization info
                searchResultsHeader
                
                // Organized Search Results
                if shouldGroupResults {
                    groupedResultsView
                } else {
                    ungroupedResultsView
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            ))
        } else if isSearching && results.isEmpty {
            // No results state
            VStack(spacing: 16) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundColor(.white.opacity(0.3))
                
                Text("No results found")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Try adjusting your search terms or filters")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
            .transition(.opacity)
        }
    }
    
    // MARK: - Smart Organization Logic
    
    private var shouldGroupResults: Bool {
        // Group results when multiple filters are active and we have enough results
        searchManager.activeFilterCount > 1 && results.count > 4
    }
    
    private var groupedResults: [(String, [SearchableContent])] {
        if searchManager.selectedPriorities.count > 1 {
            // Group by priority
            return Priority.allCases.compactMap { priority in
                let filtered = results.filter { $0.priority == priority }
                return filtered.isEmpty ? nil : (priority.rawValue, filtered)
            }
        } else if searchManager.selectedPlatforms.count > 1 {
            // Group by platform
            return Platform.allCases.compactMap { platform in
                let filtered = results.filter { $0.platform == platform }
                return filtered.isEmpty ? nil : (platform.rawValue, filtered)
            }
        } else {
            // Group by content type
            return ContentType.allCases.compactMap { contentType in
                let filtered = results.filter { $0.type == contentType }
                return filtered.isEmpty ? nil : (contentType.rawValue, filtered)
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var searchResultsHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Search Results")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                if shouldGroupResults {
                    Text("Organized by \(groupingLabel)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(results.count) result\(results.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                if shouldGroupResults {
                    Text("\(groupedResults.count) group\(groupedResults.count == 1 ? "" : "s")")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var groupingLabel: String {
        if searchManager.selectedPriorities.count > 1 {
            return "Priority"
        } else if searchManager.selectedPlatforms.count > 1 {
            return "Platform"
        } else {
            return "Type"
        }
    }
    
    @ViewBuilder
    private var groupedResultsView: some View {
        LazyVStack(spacing: 20) {
            ForEach(groupedResults, id: \.0) { groupName, groupResults in
                VStack(alignment: .leading, spacing: 12) {
                    // Group Header
                    HStack {
                        Text(groupName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("\(groupResults.count)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.horizontal, 20)
                    
                    // Group Results
                    LazyVStack(spacing: 16) {
                        ForEach(groupResults) { result in
                            SearchResultCard(content: result)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .move(edge: .top).combined(with: .opacity)
                                ))
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    @ViewBuilder
    private var ungroupedResultsView: some View {
        LazyVStack(spacing: 16) {
            ForEach(results) { content in
                SearchResultCard(content: content)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Filter Pills System

struct FilterPillsView: View {
    @ObservedObject var searchManager: SearchManager
    @State private var animateFilterAppearance = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Quick Filter Presets with staggered animation
            FilterCategoryRow(
                title: "Quick Filters",
                isExpanded: true
            ) {
                QuickFilterPresetsView(searchManager: searchManager)
            }
            .opacity(animateFilterAppearance ? 1.0 : 0.0)
            .offset(y: animateFilterAppearance ? 0 : -20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateFilterAppearance)
            
            // Filter pills organized by category with cascading animations
            VStack(spacing: 8) {
                // Priority filters
                if !Priority.allCases.isEmpty {
                    FilterCategoryRow(
                        title: "Priority",
                        isExpanded: true
                    ) {
                        PriorityFilterPills(searchManager: searchManager)
                    }
                    .opacity(animateFilterAppearance ? 1.0 : 0.0)
                    .offset(y: animateFilterAppearance ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateFilterAppearance)
                }
                
                // Platform filters
                if !Platform.allCases.isEmpty {
                    FilterCategoryRow(
                        title: "Platform",
                        isExpanded: true
                    ) {
                        PlatformFilterPills(searchManager: searchManager)
                    }
                    .opacity(animateFilterAppearance ? 1.0 : 0.0)
                    .offset(y: animateFilterAppearance ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateFilterAppearance)
                }
                
                // Content type filters
                if !ContentType.allCases.isEmpty {
                    FilterCategoryRow(
                        title: "Type",
                        isExpanded: true
                    ) {
                        ContentTypeFilterPills(searchManager: searchManager)
                    }
                    .opacity(animateFilterAppearance ? 1.0 : 0.0)
                    .offset(y: animateFilterAppearance ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: animateFilterAppearance)
                }
                
                // Date range filters
                FilterCategoryRow(
                    title: "Date",
                    isExpanded: true
                ) {
                    DateRangeFilterPills(searchManager: searchManager)
                }
                .opacity(animateFilterAppearance ? 1.0 : 0.0)
                .offset(y: animateFilterAppearance ? 0 : -20)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: animateFilterAppearance)
            }
            
            // Enhanced clear all filters button with morphing glass effect
            if searchManager.hasActiveFilters {
                ClearFiltersButton(searchManager: searchManager)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.8)).combined(with: .move(edge: .bottom)),
                        removal: .opacity.combined(with: .scale(scale: 0.8)).combined(with: .move(edge: .bottom))
                    ))
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            withAnimation {
                animateFilterAppearance = true
            }
        }
    }
}

// MARK: - Enhanced Clear Filters Button

struct ClearFiltersButton: View {
    @ObservedObject var searchManager: SearchManager
    @State private var isPressed = false
    @State private var pulseIntensity: Double = 1.0
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                searchManager.clearAllFilters()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.8))
                    .scaleEffect(isPressed ? 1.2 : 1.0)
                
                Text("Clear all filters (\(searchManager.activeFilterCount))")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.regularMaterial)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.red.opacity(0.2),
                                    Color.red.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 40
                            )
                        )
                        .scaleEffect(pulseIntensity)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.red.opacity(0.6),
                                Color.red.opacity(0.3),
                                Color.red.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = pressing
            }
        }, perform: {})
        .onAppear {
            startPulseAnimation()
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(
            .easeInOut(duration: 1.5)
            .repeatForever(autoreverses: true)
        ) {
            pulseIntensity = 1.3
        }
    }
}

struct FilterCategoryRow<Content: View>: View {
    let title: String
    let isExpanded: Bool
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.7))
                .padding(.leading, 4)
            
            content()
        }
    }
}

// MARK: - Individual Filter Pill Rows

struct PriorityFilterPills: View {
    @ObservedObject var searchManager: SearchManager
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Priority.allCases, id: \.self) { priority in
                    FilterPill(
                        text: priority.rawValue,
                        isSelected: searchManager.selectedPriorities.contains(priority),
                        color: priority.color,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                searchManager.togglePriority(priority)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct PlatformFilterPills: View {
    @ObservedObject var searchManager: SearchManager
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Platform.allCases, id: \.self) { platform in
                    FilterPill(
                        text: platform.rawValue,
                        isSelected: searchManager.selectedPlatforms.contains(platform),
                        icon: platform.icon,
                        color: platform.color,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                searchManager.togglePlatform(platform)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct ContentTypeFilterPills: View {
    @ObservedObject var searchManager: SearchManager
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ContentType.allCases, id: \.self) { contentType in
                    FilterPill(
                        text: contentType.rawValue,
                        isSelected: searchManager.selectedContentTypes.contains(contentType),
                        icon: contentType.icon,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                searchManager.toggleContentType(contentType)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct DateRangeFilterPills: View {
    @ObservedObject var searchManager: SearchManager
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(DateRange.allCases, id: \.self) { dateRange in
                    FilterPill(
                        text: dateRange.displayName,
                        isSelected: searchManager.selectedDateRange == dateRange,
                        icon: dateRange.icon,
                        color: dateRange == .allTime ? .gray : .blue,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                searchManager.setDateRange(dateRange)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Core Filter Pill Component

struct FilterPill: View {
    let text: String
    let isSelected: Bool
    let icon: String?
    let color: Color?
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var glowIntensity: Double = 0.0
    
    init(text: String, isSelected: Bool, icon: String? = nil, color: Color? = nil, action: @escaping () -> Void) {
        self.text = text
        self.isSelected = isSelected
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                action()
            }
        }) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundColor(iconColor)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                
                Text(text)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(textColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    // Base glass background with morphing
                    RoundedRectangle(cornerRadius: 16)
                        .fill(pillBackgroundMaterial)
                        .scaleEffect(isPressed ? 0.95 : 1.0)
                    
                    // Selection glow effect
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                RadialGradient(
                                    colors: [
                                        (color ?? .blue).opacity(0.3),
                                        (color ?? .blue).opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 25
                                )
                            )
                            .scaleEffect(1.2)
                            .opacity(glowIntensity)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(pillBorderGradient, lineWidth: pillBorderWidth)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: isSelected ? (color ?? .blue).opacity(0.4) : Color.black.opacity(0.1),
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
        .onAppear {
            if isSelected {
                startGlowAnimation()
            }
        }
        .onChange(of: isSelected) {
            if isSelected {
                startGlowAnimation()
            } else {
                stopGlowAnimation()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var iconColor: Color {
        if isSelected {
            return color ?? .white
        } else {
            return color?.opacity(0.7) ?? .white.opacity(0.7)
        }
    }
    
    private var textColor: Color {
        isSelected ? .black : .white.opacity(0.9)
    }
    
    private var pillBackgroundMaterial: Material {
        isSelected ? .regularMaterial : .ultraThinMaterial
    }
    
    private var pillBorderGradient: LinearGradient {
        if isSelected {
            return LinearGradient(
                colors: [
                    (color ?? .blue).opacity(0.8),
                    (color ?? .blue).opacity(0.4),
                    (color ?? .blue).opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.3),
                    Color.white.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var pillBorderWidth: CGFloat {
        isSelected ? 1.5 : 1.0
    }
    
    // MARK: - Animation Functions
    
    private func startGlowAnimation() {
        withAnimation(
            .easeInOut(duration: 2.0)
            .repeatForever(autoreverses: true)
        ) {
            glowIntensity = 0.8
        }
    }
    
    private func stopGlowAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            glowIntensity = 0.0
        }
    }
}

// MARK: - Quick Filter Presets

struct QuickFilterPresetsView: View {
    @ObservedObject var searchManager: SearchManager
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(searchManager.quickFilterPresets) { preset in
                    QuickFilterPresetPill(
                        preset: preset,
                        action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                searchManager.applyFilterPreset(preset)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct QuickFilterPresetPill: View {
    let preset: FilterPreset
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Icon with glass background
                Image(systemName: preset.icon)
                    .font(.caption)
                    .foregroundColor(preset.color)
                    .frame(width: 20, height: 20)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                
                Text(preset.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        preset.color.opacity(0.6),
                                        preset.color.opacity(0.2),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
            )
            .shadow(color: preset.color.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: false)
        .onTapGesture {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            action()
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        SearchResultsView(
            results: MockSearchData.allContent.prefix(3).map { $0 },
            isSearching: true,
            searchManager: SearchManager()
        )
        
        Spacer()
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
} 
