//
//  HeaderView.swift
//  Comm Liquid Glass
//
//  Created by Oscar Vargas on 6/17/25.
//

import SwiftUI

// MARK: - String Extension for Text Width Calculation
extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

// MARK: - FlowLayout for wrapping pills
struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    
    init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        _FlowLayout(spacing: spacing) {
            content
        }
    }
}

struct _FlowLayout: Layout {
    let spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, spacing: spacing, containerWidth: proposal.width ?? 0).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets = layout(sizes: sizes, spacing: spacing, containerWidth: bounds.width).offsets
        
        for (offset, subview) in zip(offsets, subviews) {
            subview.place(at: CGPoint(x: bounds.minX + offset.x, y: bounds.minY + offset.y), proposal: .unspecified)
        }
    }
    
    func layout(sizes: [CGSize], spacing: CGFloat, containerWidth: CGFloat) -> (offsets: [CGPoint], size: CGSize) {
        var result: [CGPoint] = []
        var currentPosition = CGPoint.zero
        var lineHeight: CGFloat = 0
        var maxY: CGFloat = 0
        
        for size in sizes {
            if currentPosition.x + size.width > containerWidth && !result.isEmpty {
                // Move to next line
                currentPosition.x = 0
                currentPosition.y += lineHeight + spacing
                lineHeight = 0
            }
            
            result.append(currentPosition)
            currentPosition.x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            maxY = max(maxY, currentPosition.y + size.height)
        }
        
        return (result, CGSize(width: containerWidth, height: maxY))
    }
}

struct HeaderView: View {
  @Binding var isSidebarOpen: Bool
    @ObservedObject var searchManager: SearchManager
    @Binding var isSearchFieldFocused: Bool
    @FocusState private var fieldIsFocused: Bool
    
    // Selected pill state - MOVED TO SearchManager for testing
    // @State private var selectedPill: String? = nil
    
    // Animation states
    @State private var searchBarScale: CGFloat = 1.0
    @State private var searchIconRotation: Double = 0.0
    @State private var glowIntensity: Double = 0.0
  
  var body: some View {
        ZStack {
            // No background tap gesture here - we'll handle it differently
            
            VStack(spacing: 0) {
                // Main header container with dynamic layout
                HStack(spacing: 16) {
                    // Hamburger Menu Button with Glass Enhancement - hide when searching
                    if !isSearchFieldFocused {
                        Button {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { 
                                isSidebarOpen.toggle() 
                            }
                        } label: {
                            Image(systemName: "line.horizontal.3")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                                // Glass illumination effect
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            RadialGradient(
                                                colors: [
                                                    Color.white.opacity(0.1),
                                                    Color.clear
                                                ],
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 22
                                            )
                                        )
                                        .opacity(isSidebarOpen ? 1.0 : 0.0)
                                        .animation(.easeInOut(duration: 0.3), value: isSidebarOpen)
                                )
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                                        }
                    
                    // Enhanced Search Bar with Liquid Glass Effects + Pill-Internal X Button
                ZStack(alignment: .leading) {
                    searchBarContainer
                    
                    // SOLUTION: X button positioned precisely inside the pill area
                    if let selectedPill = searchManager.selectedPill {
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                // Calculate exact position to place X button inside pill
                                let iconWidth: CGFloat = 18 // Search icon width
                                let iconSpacing: CGFloat = 14 // Spacing after search icon
                                let pillIconWidth: CGFloat = 12 // Pill icon width (caption font)
                                let pillIconSpacing: CGFloat = 6 // Spacing after pill icon
                                let pillLeadingPadding: CGFloat = 12 // Pill's leading padding
                                let pillText = selectedPill
                                let estimatedTextWidth = pillText.widthOfString(usingFont: UIFont.systemFont(ofSize: 15, weight: .medium))
                                let textSpacing: CGFloat = 6 // Space between text and X
                                
                                // Calculate X position: search icon + spacing + pill leading + pill icon + pill spacing + text + spacing
                                let xPosition = iconWidth + iconSpacing + pillLeadingPadding + pillIconWidth + pillIconSpacing + estimatedTextWidth + textSpacing
                                
                                Spacer()
                                    .frame(width: xPosition)
                                
                                Button {
                                    print("✅ PILL INTERNAL X BUTTON - Pill removed successfully!")
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        searchManager.selectedPill = nil
                                        // Keep focus maintained and preserve any typed text
                                        isSearchFieldFocused = true
                                        fieldIsFocused = true
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white.opacity(0.8))
                                        .frame(width: 16, height: 16)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                                
                                Spacer()
                            }
                        }
                        .frame(height: 44) // Match search bar height
                    }
                }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .zIndex(1001) // Above background tap area
                
                // Search suggestions positioned properly below the header
                if isSearchFieldFocused && searchManager.searchText.isEmpty {
                    searchSuggestionsOverlay
                        .padding(.horizontal, 20)
                        .zIndex(1002) // Above everything else
                }
                
                // Filter Pills - show when search is active or filters are applied
                if isSearchFieldFocused || searchManager.hasActiveFilters || !searchManager.searchText.isEmpty {
                    FilterPillsView(searchManager: searchManager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                        .zIndex(1000)
                }
            }
        }
        .onChange(of: searchManager.searchText) {
            searchManager.performSearch()
            // Pills now only clear via explicit user actions (X buttons)
            // No automatic clearing during typing sessions
        }
        .onChange(of: isSearchFieldFocused) {
            fieldIsFocused = isSearchFieldFocused
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                updateSearchBarAppearance()
            }
        }
        .onChange(of: fieldIsFocused) {
            isSearchFieldFocused = fieldIsFocused
        }
    }
    
    // MARK: - Search Bar Container
    @ViewBuilder
    private var searchBarContainer: some View {
        HStack(spacing: 14) {
            // Animated Search Icon
            Image(systemName: isSearchFieldFocused ? "magnifyingglass.circle.fill" : "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isSearchFieldFocused ? .blue : .white.opacity(0.7))
                .rotationEffect(.degrees(searchIconRotation))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isSearchFieldFocused)
            
            // Content area - pill AND text field together
            HStack(spacing: 8) {
                // Show pill with space reserved for internal X button (handled externally)
                if let selectedPill = searchManager.selectedPill {
                    HStack(spacing: 6) {
                        Image(systemName: iconForSuggestion(selectedPill))
                            .font(.caption)
                            .foregroundColor(.blue.opacity(0.8))
                        
                        Text(selectedPill)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        // Reserve space for the X button to appear inside
                        Spacer()
                            .frame(width: 20) // Exact space for the X button
                    }
                    .padding(.leading, 12)
                    .padding(.trailing, 4) // Less trailing padding - X will fill this space
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.regularMaterial)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.blue.opacity(0.1),
                                                Color.clear
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                    )
                }
                
                // Always show text field (with dynamic placeholder)
                TextField(searchManager.selectedPill != nil ? "Continue typing..." : searchManager.smartPlaceholder, text: $searchManager.searchText)
                    .foregroundColor(.white)
                    .accentColor(.blue)
                    .focused($fieldIsFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        searchManager.performSearch()
                    }
                
                Spacer()
            }
        
            // Clear Button with Glass Effect - Main search field X (should clear everything)
            if !searchManager.searchText.isEmpty || searchManager.selectedPill != nil {
          Button {
                    print("🟡 MAIN SEARCH X BUTTON TAPPED")
                    print("🟡 BEFORE: searchText = '\(searchManager.searchText)', selectedPill = '\(searchManager.selectedPill ?? "nil")'")
                    
                    withAnimation(.easeInOut(duration: 0.3)) {
                        // Clear everything - this is the main search field X button
                        searchManager.clearSearch()
                        searchManager.selectedPill = nil
                        isSearchFieldFocused = false
                        fieldIsFocused = false
                        print("🟡 EVERYTHING CLEARED - main search X should clear all")
                    }
          } label: {
            Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 24, height: 24)
                        )
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
      .frame(maxWidth: .infinity)
        // LIQUID GLASS BACKGROUND with morphing effects
        .background(
            Group {
                if isSearchFieldFocused {
                    // Active state - more pronounced glass with glow
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.regularMaterial)
      .overlay(
                            // Glass illumination from within
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.blue.opacity(0.15),
                                            Color.blue.opacity(0.05),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            // Animated glow effect
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.blue.opacity(0.6),
                                            Color.blue.opacity(0.3),
                                            Color.blue.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                                .opacity(glowIntensity)
                        )
                } else {
                    // Inactive state - subtle glass
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
            }
        )
        // Enhanced Glass morphing animation with fluid transitions
        .scaleEffect(searchBarScale)
        .overlay(
            // Dynamic glass illumination effect
            RoundedRectangle(cornerRadius: isSearchFieldFocused ? 16 : 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            isSearchFieldFocused ? Color.blue.opacity(0.1) : Color.clear,
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(isSearchFieldFocused ? 1.05 : 1.0)
                .opacity(isSearchFieldFocused ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.6), value: isSearchFieldFocused)
        )
        .shadow(
            color: isSearchFieldFocused ? Color.blue.opacity(0.4) : Color.black.opacity(0.1),
            radius: isSearchFieldFocused ? 16 : 4,
            x: 0,
            y: isSearchFieldFocused ? 8 : 2
        )
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isSearchFieldFocused)
        // Note: Moving search suggestions to main body level for proper positioning
    }
    
    // MARK: - Search Suggestions Overlay
    @ViewBuilder
    private var searchSuggestionsOverlay: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Close button header (removed title)
            HStack {
                Spacer()
                
                // Close button with glass effect
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSearchFieldFocused = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 24, height: 24)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 12)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
            
            // Smart suggestions with glass styling
            VStack(alignment: .leading, spacing: 12) {
                // Smart Filter-Based Suggestions (prioritized when filters are active)
                if !searchManager.smartSearchSuggestions.isEmpty {
                    HStack {
                        Image(systemName: "brain")
                            .font(.caption2)
                            .foregroundColor(.blue.opacity(0.8))
                        Text("Smart Suggestions")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(searchManager.smartSearchSuggestions, id: \.self) { suggestion in
                            suggestionPill(suggestion)
                        }
                    }
                    .padding(.horizontal, 12)
                }
                
                // Recent Searches (moved to top)
                HStack {
                    Text("Recent Searches")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, searchManager.smartSearchSuggestions.isEmpty ? 0 : 8)
                
                FlowLayout(spacing: 8) {
                    ForEach(searchManager.recentSearches, id: \.self) { suggestion in
                        suggestionPill(suggestion)
                    }
                }
                .padding(.horizontal, 12)
                
                // Popular Searches (moved to bottom)
                HStack {
                    Text("Popular Searches")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                }
                .padding(.top, 14)
                .padding(.horizontal, 12)
                
                FlowLayout(spacing: 8) {
                    ForEach(searchManager.popularSearches, id: \.self) { suggestion in
                        suggestionPill(suggestion)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 14)
            }
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 8)
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
        .zIndex(1000) // Higher than other content
    }
    
    // MARK: - Selected Pill View (in search bar) - UNUSED IN CURRENT TEST
    // Keeping for reference but not currently used
    @ViewBuilder
    private func selectedPillView(_ text: String) -> some View {
        Text("Unused in current test")
     }
     
     // MARK: - Suggestion Pill
    @ViewBuilder
    private func suggestionPill(_ text: String) -> some View {
        Button {
            print("🟦 SUGGESTION PILL TAPPED: '\(text)'")
            
            // Add haptic feedback for consistency
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()

            withAnimation(.easeInOut(duration: 0.3)) {
                searchManager.selectedPill = text
                searchManager.searchText = ""  // Clear text to start fresh typing
                // Keep focus active so cursor appears
                isSearchFieldFocused = true
                fieldIsFocused = true
                print("🟦 PILL CREATED: '\(text)' - Focus maintained")
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: iconForSuggestion(text))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Text(text)
                    .font(.caption)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Contextual Icon Mapping
    private func iconForSuggestion(_ text: String) -> String {
        let lowercased = text.lowercased()
        
        // People/Contacts
        if lowercased.contains("vincent") || lowercased.contains("chase") || 
           lowercased.contains("team") || lowercased.contains("standup") {
            return "person.circle.fill"
        }
        
        // Documents/Reports
        if lowercased.contains("budget") || lowercased.contains("review") || 
           lowercased.contains("report") || lowercased.contains("q3") || 
           lowercased.contains("data") {
            return "doc.text.fill"
        }
        
        // Meetings/Calendar
        if lowercased.contains("meeting") || lowercased.contains("client") ||
           lowercased.contains("call") || lowercased.contains("sync") {
            return "calendar.circle.fill"
        }
        
        // Products/Launch
        if lowercased.contains("product") || lowercased.contains("launch") ||
           lowercased.contains("release") || lowercased.contains("feature") {
            return "rocket.fill"
        }
        
        // Projects
        if lowercased.contains("project") || lowercased.contains("sigma") ||
           lowercased.contains("initiative") {
            return "folder.fill"
        }
        
        // Marketing/Campaign
        if lowercased.contains("marketing") || lowercased.contains("campaign") ||
           lowercased.contains("promotion") || lowercased.contains("ads") {
            return "megaphone.fill"
        }
        
        // Analytics/Charts
        if lowercased.contains("analytics") || lowercased.contains("metrics") ||
           lowercased.contains("performance") || lowercased.contains("stats") {
            return "chart.bar.fill"
        }
        
        // Default fallback
        return "magnifyingglass"
    }
    
    // MARK: - Animation Helpers
    private func updateSearchBarAppearance() {
        if isSearchFieldFocused {
            searchBarScale = 1.02
            searchIconRotation = 360
            glowIntensity = 1.0
        } else {
            searchBarScale = 1.0
            searchIconRotation = 0
            glowIntensity = 0.0
        }
    }
}



// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        HeaderView(
            isSidebarOpen: .constant(false),
            searchManager: SearchManager(),
            isSearchFieldFocused: .constant(false)
        )
        
        Spacer()
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
}