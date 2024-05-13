//
//  SystemDebuggerWidgetView.swift
//
//
//  Created by Maxim Aliev on 26.04.2024.
//

import SwiftUI

struct SystemDebuggerWidgetView: View {
    @ObservedObject var viewModel: SystemDebuggerViewModel
    
    var externalSize = CGSize(width: 140, height: 42)
    
    var body: some View {
        Text(viewModel.getWidgetText())
            .multilineTextAlignment(.center)
            .font(.system(size: 9))
            .frame(width: externalSize.width, height: externalSize.height)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.systemBackground)
            )
    }
}

#Preview {
    SystemDebuggerWidgetView(viewModel: SystemDebuggerViewModel())
}
