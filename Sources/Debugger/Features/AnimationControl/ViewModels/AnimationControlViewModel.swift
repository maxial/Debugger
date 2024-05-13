//
//  AnimationControlViewModel.swift
//
//
//  Created by Maxim Aliev on 21.03.2024.
//

import UIKit
import Combine

final class AnimationControlViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    
    let type: DebugFeature = .animationControl
    @Published var value: String = ""
    
    @Published var isActivated = false
    @Published var animationSpeed: Float = 1
    
    init() {
        $isActivated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.animationSpeed = 1
            }
            .store(in: &cancellables)
        
        $animationSpeed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] animationSpeed in
                UIApplication.animationSpeed = animationSpeed
                self?.value = self?.isActivated == true ? "\(Int(animationSpeed * 100))%" : "Normal"
            }
            .store(in: &cancellables)
    }
}
