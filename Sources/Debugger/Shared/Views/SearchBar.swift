//
//  SearchBar.swift
//
//
//  Created by Maxim Aliev on 25.03.2024.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            TextField("Поиск", text: $text)
                .frame(height: 40)
                .onTapGesture {
                    self.isEditing = true
                }
                .padding(.horizontal, 32)
                .background(Color.systemGray5)
                .cornerRadius(10)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        
                        Spacer()

                        if isEditing {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
            
            Spacer()
            
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 8)
                .transition(.opacity)
                .animation(.default)
            }
        }
    }
}

#Preview {
    SearchBar(text: .constant("Search text"))
}
