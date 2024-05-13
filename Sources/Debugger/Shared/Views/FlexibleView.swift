//
//  FlexibleView.swift
//  
//
//  Created by Maxim Aliev on 23.03.2024.
//

import SwiftUI

struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    var spacing: CGFloat = 8
    var padding: EdgeInsets = EdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: .zero)
    var alignment: HorizontalAlignment = .leading
    
    @ViewBuilder
    let content: (Data.Element) -> Content
    
    @State
    private var availableWidth: CGFloat = .zero
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: alignment, vertical: .center)) {
            Color.clear
                .frame(height: 1)
                .readSize { size in
                    let deviceWidth = UIWindow.keyWindow?.bounds.width ?? .zero
                    availableWidth = min(size.width, deviceWidth - padding.leading - padding.trailing)
                }
            
            _FlexibleView(
                availableWidth: availableWidth,
                data: data,
                spacing: spacing,
                padding: padding,
                alignment: alignment,
                content: content
            )
        }
        .padding(padding)
    }
}

private struct _FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let padding: EdgeInsets
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    @State
    var elementsSize: [Data.Element: CGSize] = [:]
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { rowElements in
                HStack(spacing: spacing) {
                    ForEach(rowElements, id: \.self) { element in
                        content(element)
                            .fixedSize()
                            .readSize { size in
                                elementsSize[element] = size
                            }
                    }
                }
            }
        }
        .animation(.none, value: elementsSize)
    }
    
    func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRow: Int = .zero
        var remainingWidth = availableWidth
        
        for element in data {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
            
            if remainingWidth - elementSize.width >= .zero {
                rows[currentRow].append(element)
            } else {
                currentRow = currentRow + 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            
            remainingWidth = remainingWidth - (elementSize.width + spacing)
        }
        
        return rows
    }
}
