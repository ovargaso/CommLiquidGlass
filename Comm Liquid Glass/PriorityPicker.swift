//
//  PriorityPicker.swift
//  Comm Liquid Glass
//
//  Created by Oscar Vargas on 6/17/25.
//

import SwiftUI

struct PriorityPicker: View {
  @Binding var selectedSort: String
  
  private let sortOptions = ["High Priority to Low", "Newest to Oldest", "Oldest to Newest"]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Label
      Text("Sort Messages By")
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.bottom, 4)
      
      // Horizontally Scrollable Pills
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          // Add leading spacer for better scrolling feel
          Spacer()
            .frame(width: 0)
          
          ForEach(sortOptions, id: \.self) { option in
        Button(action: {
              withAnimation(.easeInOut(duration: 0.2)) {
                selectedSort = option
              }
        }) {
              Text(option)
            .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(selectedSort == option ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        .background(
                  RoundedRectangle(cornerRadius: 20)
                    .fill(selectedSort == option ? .regularMaterial : .ultraThinMaterial)
                    .overlay(
                      RoundedRectangle(cornerRadius: 20)
                        .stroke(
                          selectedSort == option ? 
                          Color.white.opacity(0.2) : 
                          Color.white.opacity(0.1), 
                          lineWidth: 1
                        )
                    )
                    .shadow(
                      color: selectedSort == option ? 
                      Color.black.opacity(0.3) : 
                      Color.clear, 
                      radius: 4, x: 0, y: 2
                    )
                )
                .overlay(
                  // Subtle inner glow for selected state
                  selectedSort == option ?
                  RoundedRectangle(cornerRadius: 20)
                    .fill(
      LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.1), .clear]),
        startPoint: .top,
                        endPoint: .bottom
                      )
                    ) : nil
                )
            }
            .buttonStyle(PlainButtonStyle())
          }
          
          // Add trailing spacer for better scrolling feel
          Spacer()
            .frame(width: 0)
        }
        .padding(.horizontal, 20)
      }
      .clipped()
    }
  }
}

#Preview {
  VStack(spacing: 30) {
    PriorityPicker(selectedSort: .constant("High Priority to Low"))
    PriorityPicker(selectedSort: .constant("Newest to Oldest"))
    PriorityPicker(selectedSort: .constant("Oldest to Newest"))
  }
  .padding()
  .background(Color.black)
  .preferredColorScheme(.dark)
} 