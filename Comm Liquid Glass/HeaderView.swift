//
//  HeaderView.swift
//  Comm Liquid Glass
//
//  Created by Oscar Vargas on 6/17/25.
//

import SwiftUI

struct HeaderView: View {
  @Binding var isSidebarOpen: Bool
  @State private var searchText = ""
  @FocusState private var isSearchFieldFocused: Bool
  
  var body: some View {
    HStack(spacing: 12) {
      Button {
        withAnimation(.easeInOut(duration: 0.3)) { isSidebarOpen.toggle() }
      } label: {
        Image(systemName: "line.horizontal.3")
          .font(.title2)
          .foregroundColor(.white)
      }
      
      HStack(spacing: 12) {
        Image(systemName: "magnifyingglass")
          .foregroundColor(.white.opacity(0.7))
        
        TextField("Search by name, topic, or keyword", text: $searchText)
          .foregroundColor(.white)
          .accentColor(.white)
          .focused($isSearchFieldFocused)
        
        if !searchText.isEmpty {
          Button {
            searchText = ""
          } label: {
            Image(systemName: "xmark.circle.fill")
              .foregroundColor(.white.opacity(0.7))
          }
        }
      }
      .padding(.leading, 8)
      .padding(.vertical, 6)
      .frame(maxWidth: .infinity)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(
            isSearchFieldFocused ? Color.blue : Color.white.opacity(0.3), 
            lineWidth: 1
          )
      )
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
  }
}

#Preview {
  HeaderView(isSidebarOpen: .constant(false))
    .preferredColorScheme(.dark)
    .padding()
}