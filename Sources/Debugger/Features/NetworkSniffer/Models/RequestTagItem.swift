//
//  RequestTagItem.swift
//  
//
//  Created by Maxim Aliev on 13.04.2024.
//

import Foundation

enum RequestTagItem: CaseIterable {
    case method
    case code
    case duration
    case sentDataSize
    case receivedDataSize
    
    func getViewModel(from requestModel: RequestModel) -> RequestTagItemViewModel? {
        switch self {
        case .method:
            return RequestTagItemViewModel(
                text: requestModel.method.uppercased(),
                color: requestModel.statusColor
            )
        case .code:
            guard let text = requestModel.code?.description else {
                return nil
            }
            return RequestTagItemViewModel(
                text: text,
                color: requestModel.statusColor
            )
        case .duration:
            guard let text = requestModel.duration?.formattedMilliseconds() else {
                return nil
            }
            return RequestTagItemViewModel(
                text: text
            )
        case .sentDataSize:
            guard let text = requestModel.sentBytes?.formattedDataSize else {
                return nil
            }
            return RequestTagItemViewModel(
                imageName: "arrow.up",
                text: text
            )
        case .receivedDataSize:
            guard let text = requestModel.receivedBytes?.formattedDataSize else {
                return nil
            }
            return RequestTagItemViewModel(
                imageName: "arrow.down",
                text: text
            )
        }
    }
}
