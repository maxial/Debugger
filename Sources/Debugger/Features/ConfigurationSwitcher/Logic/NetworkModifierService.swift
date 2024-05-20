//
//  NetworkModifierService.swift
//
//
//  Created by Maxim Aliev on 23.04.2024.
//

import Foundation

struct NetworkModifierService {
    func applyHostSpoofing(
        to request: inout URLRequest,
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
    
    func apply(rules: [DebuggerConfigurationRule], to request: inout URLRequest) {
        for rule in rules where isMatching(request: request, to: rule) {
            switch rule.type {
            case .requestBody:
                guard var requestBody = getRequestBody(for: request) else {
                    return
                }
                
                apply(rule: rule, to: &requestBody)
                
                if let httpBodyStream = getHttpBodyStream(for: requestBody) {
                    set(httpBodyStream: httpBodyStream, to: &request)
                }
            case .responseBody:
                break
            }
        }
    }
    
    func apply(
        rules: [DebuggerConfigurationRule],
        to responseData: inout Data,
        on request: URLRequest
    ) {
        for rule in rules where isMatching(request: request, to: rule) {
            switch rule.type {
            case .requestBody:
                break
            case .responseBody:
                apply(rule: rule, to: &responseData)
            }
        }
    }
    
    func isMatching(request: URLRequest, to rule: DebuggerConfigurationRule) -> Bool {
        guard rule.isEnabled && rule.path == request.url?.path else {
            return false
        }
        
        guard let requestBody = getRequestBody(for: request) else {
            return rule.matchingParams.isEmpty
        }
        
        for matchingParam in rule.matchingParams {
            switch matchingParam.value {
            case .int(let int):
                if let intParam = requestBody.body[matchingParam.key] as? Int, int != intParam {
                    return false
                }
            case .string(let string):
                if let stringParam = requestBody.body[matchingParam.key] as? String, string != stringParam {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func getRequestBody(for request: URLRequest) -> RequestBody? {
        guard
            let contentTypeValue = request.allHTTPHeaderFields?["Content-Type"],
            let contentType = RequestContentType(rawValue: contentTypeValue)
        else {
            return nil
        }
        
        switch contentType {
        case .applicationJson:
            guard
                let httpBody = request.httpBody ?? request.httpBodyStream?.toData(),
                let json = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: Any]
            else {
                return nil
            }
            
            return RequestBody(contentType: contentType, body: json)
        case .xWwwFormUrlencoded:
            guard
                let httpBody = request.httpBody ?? request.httpBodyStream?.toData(),
                let queryItemsString = String(data: httpBody, encoding: .utf8),
                let urlComponents = URLComponents(string: "http://fakeurl.com?\(queryItemsString)"),
                let queryItems = urlComponents.queryItems
            else {
                return nil
            }
            
            let json = queryItems.reduce(into: [String: Any]()) { result, item in
                result[item.name] = item.value
            }
            
            return RequestBody(contentType: contentType, body: json)
        case .multipartFormData, .unknown:
            // Ignore multipart/form-data and other content types for now
            return nil
        }
    }
    
    private func apply(rule: DebuggerConfigurationRule, to requestBody: inout RequestBody) {
        for updatingParam in rule.updatingParams {
            requestBody.body[updatingParam.key] = updatingParam.value.value
        }
    }
    
    private func apply(rule: DebuggerConfigurationRule, to responseData: inout Data) {
        if rule.updatingResponse.isEmpty == false, let data = rule.updatingResponse.data(using: .utf8) {
            responseData = data
        }
    }
    
    private func getHttpBodyStream(for requestBody: RequestBody) -> HttpBodyStream? {
        switch requestBody.contentType {
        case .applicationJson:
            if let jsonData = try? JSONSerialization.data(withJSONObject: requestBody.body, options: []) {
                return HttpBodyStream(contentLength: nil, inputStream: InputStream(data: jsonData))
            }
        case .xWwwFormUrlencoded:
            var components = URLComponents()
            components.queryItems = requestBody.body.map {
                URLQueryItem(name: $0.key, value: String(describing: $0.value))
            }
            
            if let queryString = components.url?.query {
                let data = queryString.data(using: .utf8) ?? Data()
                let stream = InputStream(data: data)
                return HttpBodyStream(contentLength: data.count, inputStream: stream)
            }
        case .multipartFormData, .unknown:
            // Ignore multipart/form-data and other content types for now
            return nil
        }
        
        return nil
    }
    
    private func set(httpBodyStream: HttpBodyStream, to request: inout URLRequest) {
        if let contentLength = httpBodyStream.contentLength {
            request.setValue(String(contentLength), forHTTPHeaderField: "Content-Length")
        }
        request.httpBodyStream = httpBodyStream.inputStream
    }
}
