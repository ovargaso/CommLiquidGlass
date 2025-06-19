//
//  HeaderView.swift
//  Comm Liquid Glass
//
//  Created by Oscar Vargas on 6/17/25.
//

import SwiftUI

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
    
    // Selected pill state
    @State private var selectedPill: String? = nil
    
    // Animation states
    @State private var searchBarScale: CGFloat = 1.0
    @State private var searchIconRotation: Double = 0.0
    @State private var glowIntensity: Double = 0.0
  
  var body: some View {
        ZStack {
            // No background tap gesture here - we'll handle it differently
            
            VStack(spacing: 0) {
                // Main header container
                HStack(spacing: 16) {
                    // Hamburger Menu Button with Glass Enhancement
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
                    
                    // Enhanced Search Bar with Liquid Glass Effects
                    searchBarContainer
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
            }
        }
        .onChange(of: searchManager.searchText) {
            searchManager.performSearch()
            // Clear selected pill if user starts typing manually
            if !searchManager.searchText.isEmpty && selectedPill != nil && searchManager.searchText != selectedPill {
                selectedPill = nil
            }
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
            
            // Content area - either selected pill or text field
            HStack(spacing: 8) {
                if let selectedPill = selectedPill {
                    // Show selected pill
                    selectedPillView(selectedPill)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                } else {
                    // Show text field
                    TextField("Search by name, topic, or keyword", text: $searchManager.searchText)
                        .foregroundColor(.white)
                        .accentColor(.blue)
                        .focused($fieldIsFocused)
                        .submitLabel(.search)
                        .onSubmit {
                            searchManager.performSearch()
                        }
                        .transition(.asymmetric(
                            insertion: .opacity,
                            removal: .opacity
                        ))
                }
                
                Spacer()
            }
        
            // Clear Button with Glass Effect
            if !searchManager.searchText.isEmpty || selectedPill != nil {
          Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        searchManager.clearSearch()
                        selectedPill = nil
                        isSearchFieldFocused = false
                        fieldIsFocused = false
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
        // Glass morphing animation
        .scaleEffect(searchBarScale)
        .shadow(
            color: isSearchFieldFocused ? Color.blue.opacity(0.3) : Color.black.opacity(0.1),
            radius: isSearchFieldFocused ? 12 : 4,
            x: 0,
            y: isSearchFieldFocused ? 6 : 2
        )
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
            
            // Quick suggestions with glass styling (reordered)
            VStack(alignment: .leading, spacing: 12) {
                // Recent Searches (moved to top)
                HStack {
                    Text("Recent Searches")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                }
                .padding(.horizontal, 12)
                
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
    
    // MARK: - Selected Pill View (in search bar)
    @ViewBuilder
    private func selectedPillView(_ text: String) -> some View {
        HStack(spacing: 6) {
            // Tappable content area for editing
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedPill = nil
                    isSearchFieldFocused = true
                    fieldIsFocused = true
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: iconForSuggestion(text))
                        .font(.caption)
                        .foregroundColor(.blue.opacity(0.8))
                    
                    Text(text)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Small remove button
            Button {
                print("🧪 DEBUG: X button in pill was tapped!")
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedPill = nil
                    searchManager.clearSearch()
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 16, height: 16)
                    .background(Circle().fill(.ultraThinMaterial))
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Circle()) // Make the hit area clear and prevent gesture conflicts
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            // Combine all styling into single background
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                .background(
                    // Subtle blue glow for selected state
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
     
     // MARK: - Suggestion Pill
    @ViewBuilder
    private func suggestionPill(_ text: String) -> some View {
        Button {

            withAnimation(.easeInOut(duration: 0.3)) {
                selectedPill = text
                searchManager.searchText = text
                isSearchFieldFocused = false
                fieldIsFocused = false
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