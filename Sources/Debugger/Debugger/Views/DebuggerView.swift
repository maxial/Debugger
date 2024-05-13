//
//  DebuggerView.swift
//
//
//  Created by Maxim Aliev on 14.03.2024.
//

import SwiftUI

struct DebuggerView: View {
    @ObservedObject var configurationSwitcherViewModel: ConfigurationSwitcherViewModel
    @ObservedObject var networkSnifferViewModel: NetworkSnifferViewModel
    @ObservedObject var viewInspectorViewModel: ViewInspectorViewModel
    @ObservedObject var animationControlViewModel: AnimationControlViewModel
    @ObservedObject var systemDebuggerViewModel: SystemDebuggerViewModel
    
    var body: some View {
        VStack {
            NavigationView {
                List {
                    DebuggerItemView(
                        viewModel: DebuggerItemViewModel(
                            type: configurationSwitcherViewModel.type,
                            value: configurationSwitcherViewModel.value
                        ),
                        destination: ConfigurationSwitcherView(
                            viewModel: configurationSwitcherViewModel,
                            didSelectConfiguration: {
                                configurationSwitcherViewModel.selectedConfiguration = $0
                            }
                        )
                    )
                    
                    DebuggerItemView(
                        viewModel: DebuggerItemViewModel(
                            type: networkSnifferViewModel.type,
                            value: networkSnifferViewModel.value
                        ),
                        destination: NetworkSnifferView(viewModel: networkSnifferViewModel)
                    )
                    
                    DebuggerItemView(
                        viewModel: DebuggerItemViewModel(
                            type: viewInspectorViewModel.type,
                            value: viewInspectorViewModel.value
                        ),
                        destination: ViewInspectorView(viewModel: viewInspectorViewModel)
                    )
                    
                    DebuggerItemView(
                        viewModel: DebuggerItemViewModel(
                            type: animationControlViewModel.type,
                            value: animationControlViewModel.value
                        ),
                        destination: AnimationControlView(viewModel: animationControlViewModel)
                    )
                    
                    DebuggerItemView(
                        viewModel: DebuggerItemViewModel(
                            type: systemDebuggerViewModel.type,
                            value: systemDebuggerViewModel.value
                        ),
                        destination: SystemDebuggerView(viewModel: systemDebuggerViewModel)
                    )
                }
                .list()
                .navigationTitle("Debugger")
                .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(.stack)
            
            Button(action: {
                Debugger.shared.hideDebugger()
            }, label: {
                Text("Close")
                    .frame(minWidth: .zero, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.systemBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            })
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Spacer(minLength: UIWindow.safeAreaInsets.bottom)
        }
        .background(Color.systemGroupedBackground)
        .ignoresSafeArea()
    }
}

#Preview {
    DebuggerView(
        configurationSwitcherViewModel: ConfigurationSwitcherViewModel(),
        networkSnifferViewModel: NetworkSnifferViewModel(),
        viewInspectorViewModel: ViewInspectorViewModel(),
        animationControlViewModel: AnimationControlViewModel(),
        systemDebuggerViewModel: SystemDebuggerViewModel()
    )
}
