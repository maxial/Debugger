//
//  AnimationControlView.swift
//
//
//  Created by Maxim Aliev on 16.03.2024.
//

import SwiftUI

struct AnimationControlView: View {
    @ObservedObject var viewModel: AnimationControlViewModel
    
    var body: some View {
        List {
            animationSpeedItemView
        }
        .list()
        .navigationTitle(viewModel.type.name)
    }
    
    private var animationSpeedItemView: some View {
        VStack {
            Toggle(isOn: $viewModel.isActivated) {
                Text(getAnimationSpeedStatus())
            }
            .padding(.vertical, 4)
            
            if viewModel.isActivated {
                Slider(
                    value: $viewModel.animationSpeed,
                    in: 0.1...1.0,
                    step: 0.05
                )
                .padding(.top, 4)
                .padding(.bottom, 16)
            }
        }
        .listRow(isEditable: false)
        .onTapGesture {
            viewModel.isActivated.toggle()
        }
    }
    
    private func getAnimationSpeedStatus() -> String {
        let animationSpeed = "\(Int(round(viewModel.animationSpeed * 100)))%"
        
        return "Animations Speed" + (viewModel.isActivated ? ": \(animationSpeed)" : "")
    }
}

#Preview {
    AnimationControlView(viewModel: AnimationControlViewModel())
}
