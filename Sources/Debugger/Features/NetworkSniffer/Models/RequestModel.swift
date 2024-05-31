//
//  File 2.swift
//  
//
//  Created by Maxim Aliev on 16.03.2024.
//

import SwiftUI

final class RequestModel: ObservableObject, Identifiable {
    let id: String
    let url: URL?
    let date: Date
    let method: String
    let headers: [String: String]
    @Published var credentials: [String: String]
    @Published var cookies: String?
    @Published var httpBody: Data?
    @Published var code: Int?
    @Published var responseHeaders: [String: String]?
    @Published private(set) var dataResponse: Data?
    @Published var errorClientDescription: String?
    @Published var duration: Double?
    @Published var sentBytes: Int64?
    @Published var receivedBytes: Int64?
    
    private let lock = NSLock()
    
    init(request: URLRequest, session: URLSession?) {
        id = UUID().uuidString
        url = request.url
        date = Date()
        method = request.httpMethod ?? "GET"
        credentials = [:]
        var headers = request.allHTTPHeaderFields ?? [:]
        httpBody = request.httpBody
        
        session?.configuration.httpAdditionalHeaders?
            .filter { $0.0 != AnyHashable("Cookie") }
            .forEach { element in
                guard let key = element.0 as? String, let value = element.1 as? String else {
                    return
                }
                headers[key] = value
        }
        self.headers = headers
        
        if
            let credentialStorage = session?.configuration.urlCredentialStorage,
            let port = url?.port,
            let host = url?.host,
            let scheme = url?.scheme
        {
            let protectionSpace = URLProtectionSpace(
                host: host,
                port: port,
                protocol: scheme,
                realm: host,
                authenticationMethod: NSURLAuthenticationMethodHTTPBasic
            )

            if let credentials = credentialStorage.credentials(for: protectionSpace)?.values {
                for credential in credentials {
                    guard let user = credential.user, let password = credential.password else { continue }
                    self.credentials[user] = password
                }
            }
        }
        
        if let session = session, let url = request.url, session.configuration.httpShouldSetCookies {
            if let cookieStorage = session.configuration.httpCookieStorage,
                let cookies = cookieStorage.cookies(for: url), !cookies.isEmpty {
                self.cookies = cookies.reduce("") { $0 + "\($1.name)=\($1.value);" }
            }
        }
    }
    
    func initResponse(response: URLResponse) {
        guard let responseHttp = response as? HTTPURLResponse else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.code = responseHttp.statusCode
            self?.responseHeaders = responseHttp.allHeaderFields as? [String: String]
        }
    }
    
    func saveDataResponse(data: Data) {
        lock.lock()
        DispatchQueue.main.async { [weak self] in
            defer { self?.lock.unlock() }
            guard let self else { return }
            if dataResponse == nil {
                dataResponse = data
            } else {
                dataResponse?.append(data)
            }
        }
    }
    
    func readDataResponse() -> Data? {
        lock.lock()
        defer { lock.unlock() }
        return dataResponse
    }
    
    func saveHttpBody(from request: URLRequest) {
        DispatchQueue.main.async { [weak self] in
            self?.httpBody = request.httpBody ?? request.httpBodyStream?.toData()
        }
    }
    
    func calcDuration() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            duration = fabs(date.timeIntervalSinceNow) * 1000
        }
    }
    
    func collectMetrics(sentBytes: Int64, receivedBytes: Int64) {
        DispatchQueue.main.async { [weak self] in
            self?.sentBytes = sentBytes
            self?.receivedBytes = receivedBytes
        }
    }
    
    func saveError(_ errorDescription: String) {
        DispatchQueue.main.async { [weak self] in
            self?.errorClientDescription = errorDescription
        }
    }
    
    var urlWithoutQuery: String {
        guard let url else {
            return ""
        }
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.query = nil
        return urlComponents?.url?.absoluteString ?? ""
    }
    
    var curlRequest: String {
        var components = ["$ curl -v"]

        guard
            let _ = self.url?.host
        else {
            return "$ curl command could not be created"
        }

        if method != "GET" {
            components.append("-X \(method)")
        }
        
        components += headers.map {
            let escapedValue = String(describing: $0.value).replacingOccurrences(of: "\"", with: "\\\"")
            return "-H \"\($0.key): \(escapedValue)\""
        }

        if let httpBodyData = httpBody, let httpBody = String(data: httpBodyData, encoding: .utf8) {
            // the following replacingOccurrences handles cases where httpBody already contains the escape \ character before the double quotation mark (") character
            var escapedBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\"") // \" -> \\\"
            // the following replacingOccurrences escapes the character double quotation mark (")
            escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"") // " -> \"

            components.append("-d \"\(escapedBody)\"")
        }
        
        for credential in credentials {
            components.append("-u \(credential.0):\(credential.1)")
        }
        
        if let cookies = cookies {
            components.append("-b \"\(cookies[..<cookies.index(before: cookies.endIndex)])\"")
        }

        if let url {
            components.append("\"\(url)\"")
        }

        return components.joined(separator: " \\\n\t")
    }
    
    var postmanItem: PMItem? {
        guard let url, let scheme = url.scheme, let host = url.host else {
            return nil
        }
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyyMMdd_HHmmss"
        
        let name = "\(dateFormatterGet.string(from: date))-\(url)"
        
        var headers: [PMHeader] = []
        let method = self.method
        for header in self.headers {
            headers.append(PMHeader(key: header.0, value: header.1))
        }
        
        var rawBody: String = ""
        if let httpBodyData = httpBody, let httpBody = String(data: httpBodyData, encoding: .utf8) {
            rawBody = httpBody
        }
        
        let hostList = host.split(separator: ".")
            .map{ String(describing: $0) }
        
        var pathList = url.pathComponents
        pathList.removeFirst()

        let body = PMBody(mode: "raw", raw: rawBody)
        
        let query: [PMQuery]? = url.query?.split(separator: "&").compactMap{ element in
            let splittedElements = element.split(separator: "=")
            guard splittedElements.count == 2 else { return nil }
            let key = String(splittedElements[0])
            let value = String(splittedElements[1])
            return PMQuery(key: key, value: value)
        }

        let urlPostman = PMURL(raw: url.absoluteString, urlProtocol: scheme, host: hostList, path: pathList, query: query)
        let request = PMRequest(method: method, header: headers, body: body, url: urlPostman, description: "")
        
        // build response
        
        let responseHeaders = self.responseHeaders?.compactMap{ (key, value) in
            return PMHeader(key: key, value: value)
        } ?? []
        
        let responseBody: String
        if let data = dataResponse, let string = String(data: data, encoding: .utf8) {
            responseBody = string
        }
        else {
            responseBody = ""
        }
        
        let response = PMResponse(name: url.absoluteString, originalRequest: request, status: "", code: code ?? .zero, postmanPreviewlanguage: "html", header: responseHeaders, cookie: [], body: responseBody)
        
        return PMItem(name: name, item: nil, request: request, response: [response])
    }
    
    var statusColor: Color {
        guard let code = code else {
            return .httpCode.generic
        }
        
        switch code {
        case 200..<300:
            return .httpCode.success
        case 300..<400:
            return .httpCode.redirect
        case 400..<500:
            return .httpCode.clientError
        case 500..<600:
            return .httpCode.serverError
        default:
            return .httpCode.generic
        }
    }
}
