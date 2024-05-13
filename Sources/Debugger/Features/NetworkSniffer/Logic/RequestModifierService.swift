//
//  RequestModifierService.swift
//
//
//  Created by Maxim Aliev on 23.04.2024.
//

import Foundation

struct RequestModifierService {
    func applyHostSpoofing(
        to request: inout NSMutableURLRequest,
        selectedConfiguration: DebuggerConfiguration
    ) {
        guard
            let url = request.url,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return
        }
        
        components.host = selectedConfiguration.baseURL.host
        request.url = components.url
    }
    
    func applyCustomRules(_ rules: [DebuggerConfigurationRule], to request: inout NSMutableURLRequest) {
        for rule in rules {
            switch rule.type {
            case .requestBody:
                applyRuleToRequestBody(rule: rule, request: &request)
            }
        }
    }
    
    private func applyRuleToRequestBody(
        rule: DebuggerConfigurationRule,
        request: inout NSMutableURLRequest
    ) {
        guard
            rule.isEnabled && rule.path == request.url?.path,
            let contentType = RequestContentType(rawValue: request.allHTTPHeaderFields?["Content-Type"])
        else {
            return
        }
        
        switch contentType {
        case .applicationJson:
            applyRuleToApplicationJsonBody(rule: rule, to: &request)
        case .xWwwFormUrlencoded:
            applyRuleToWwwFormUrlencodedBody(rule: rule, to: &request)
        case .multipartFormData, .unknown:
            // Ignore multipart/form-data and other content types for now
            return
        }
    }
    
    private func applyRuleToApplicationJsonBody(
        rule: DebuggerConfigurationRule,
        to request: inout NSMutableURLRequest
    ) {
        guard
            let httpBody = request.httpBody ?? request.httpBodyStream?.toData(),
            let json = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: Any]
        else {
            return
        }
        
        var params: [String: Any] = json
        
        apply(rule: rule, to: &params)
        
        if let modifiedBody = try? JSONSerialization.data(withJSONObject: params, options: []) {
            request.httpBodyStream = InputStream(data: modifiedBody)
        }
    }
    
    private func applyRuleToWwwFormUrlencodedBody(
        rule: DebuggerConfigurationRule,
        to request: inout NSMutableURLRequest
    ) {
        guard
            let httpBody = request.httpBody ?? request.httpBodyStream?.toData(),
            let queryItemsString = String(data: httpBody, encoding: .utf8),
            let urlComponents = URLComponents(string: "http://fakeurl.com?\(queryItemsString)"),
            let queryItems = urlComponents.queryItems
        else {
            return
        }
        
        var params: [String: Any] = queryItems.reduce(into: [String: Any]()) { result, item in
            result[item.name] = item.value
        }
        
        apply(rule: rule, to: &params)
        
        var components = URLComponents()
        components.queryItems = params.map {
            URLQueryItem(name: $0.key, value: String(describing: $0.value))
        }
        
        if let queryString = components.url?.query {
            let data = queryString.data(using: .utf8) ?? Data()
            let stream = InputStream(data: data)
            request.setValue(String(data.count), forHTTPHeaderField: "Content-Length")
            request.httpBodyStream = stream
        }
    }
    
    private func apply(rule: DebuggerConfigurationRule, to params: inout [String: Any]) {
        for matchingParam in rule.matchingParams {
            switch matchingParam.value {
            case .int(let int):
                if let intParam = params[matchingParam.key] as? Int, int != intParam {
                    return
                }
            case .string(let string):
                if let stringParam = params[matchingParam.key] as? String, string != stringParam {
                    return
                }
            }
        }
        
        for updatingParam in rule.updatingParams {
            params[updatingParam.key] = updatingParam.value.value
        }
    }
}
