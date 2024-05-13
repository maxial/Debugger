//
//  ContentView.swift
//  Example
//
//  Created by Maxim Aliev on 13.05.2024.
//

import SwiftUI

struct ColorView: View {
    var color: Color
    
    var body: some View {
        color
            .opacity(0.5)
    }
}

struct ContentView: View {
    private enum Constants {
        static let columnsGrid = [GridItem(.adaptive(minimum: 40), spacing: 20)]
    }
    
    var colors: [Color] = [.red, .blue, .green, .orange, .yellow, .pink, .black, .purple, .brown, .cyan, .mint, .indigo, .teal]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("Colors")
                        .padding(.leading, 20)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                
                LazyVGrid(columns: Constants.columnsGrid) {
                    ForEach(colors, id: \.self) { color in
                        ColorView(color: color)
                            .frame(height: 40)
                    }
                }
                .padding([.leading, .trailing], 20)
            }
            .padding(.top, 20)
        }
    }
}

#Preview {
    ContentView()
}
