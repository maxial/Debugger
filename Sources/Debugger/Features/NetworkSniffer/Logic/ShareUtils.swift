////
////  ShareUtils.swift
////
////
////  Created by Maxim Aliev on 19.03.2024.
////

import UIKit

enum RequestResponseExportOption {
    case flat
    case curl
    case postman
}

final class ShareUtils {
    static func getActivityItems(requests: [RequestModel], requestExportOption: RequestResponseExportOption = .flat) -> [Any] {
        var text = ""
        switch requestExportOption {
        case .flat:
            text = getTxtText(requests: requests)
        case .curl:
            text = getCurlText(requests: requests)
        case .postman:
            text = getPostmanCollection(requests: requests) ?? "{}"
            text = text.replacingOccurrences(of: "\\/", with: "/")
        }
        
        return [text]
    }
        
    private static func getTxtText(requests: [RequestModel]) -> String {
        var text: String = ""
        for request in requests {
            text = text + RequestModelBeautifier.txtExport(request: request)
        }
        return text
    }
    
    private static func getCurlText(requests: [RequestModel]) -> String {
        var text: String = ""
        for request in requests{
            text = text + RequestModelBeautifier.curlExport(request: request)
        }
        return text
    }
    
    private static func getPostmanCollection(requests: [RequestModel]) -> String? {
        var items: [PMItem] = []
        
        for request in requests {
            guard let postmanItem = request.postmanItem else { continue }
            items.append(postmanItem)
        }
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyyMMdd_HHmmss_SSS"
        
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        
        let collectionName = "\(appName) \(dateFormatterGet.string(from: Date()))"

        let info = PMInfo(postmanID: collectionName, name: collectionName, schema: "https://schema.getpostman.com/json/collection/v2.1.0/collection.json")
        
        let postmanCollectionItem = PMItem(name: collectionName, item: items, request: nil, response: nil)
        
        let postmanCollection = PostmanCollection(info: info, item: [postmanCollectionItem])
        
        let encoder = JSONEncoder()
        
        if let data = try? encoder.encode(postmanCollection), let string = String(data: data, encoding: .utf8) {
            return string
        }
        else {
            return nil
        }
    }
}
