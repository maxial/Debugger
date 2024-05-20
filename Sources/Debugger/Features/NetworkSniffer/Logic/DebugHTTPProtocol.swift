//
//  DebugHTTPProtocol.swift
//
//
//  Created by Maxim Aliev on 16.03.2024.
//

import Foundation

final class DebugHTTPProtocol: URLProtocol {
    private var session: URLSession?
    private var sessionTask: URLSessionDataTask?
    private var currentRequest: RequestModel?
    
    static var ignoreHosts: [String] = []
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
        
        if session == nil {
            session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        guard DebugHTTPProtocol.shouldHandleRequest(request) else {
            return false
        }
        
        return property(forKey: String(describing: Self.self), in: request) == nil
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard var mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            return
        }
        
        DebugHTTPProtocol.setProperty(true, forKey: String(describing: Self.self), in: mutableRequest)
        
        var newRequest = mutableRequest as URLRequest
        
        Debugger.shared.applyDebugSettings(to: &newRequest)
        
        sessionTask = session?.dataTask(with: newRequest)
        sessionTask?.resume()
        
        currentRequest = RequestModel(request: newRequest, session: session)
        
        if let currentRequest {
            Debugger.shared.save(request: currentRequest)
        }
    }
    
    override func stopLoading() {
        sessionTask?.cancel()
        
        currentRequest?.saveHttpBody(from: request)
        currentRequest?.calcDuration()
        
        if let currentRequest {
            Debugger.shared.save(request: currentRequest)
        }
        
        session?.invalidateAndCancel()
    }
    
    deinit {
        session = nil
        sessionTask = nil
        currentRequest = nil
    }
    
    private static func shouldHandleRequest(_ request: URLRequest) -> Bool {
        guard let host = request.url?.host else {
            return false
        }
        
        return DebugHTTPProtocol.ignoreHosts.filter{ host.contains($0) }.isEmpty
    }
}

extension DebugHTTPProtocol: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        currentRequest?.saveDataResponse(data: data)
        
        if
            let request = dataTask.originalRequest,
            Debugger.shared.isResponseWillBeModified(for: request) == false
        {
            client?.urlProtocol(self, didLoad: data)
        }
    }
    
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)
        
        currentRequest?.initResponse(response: response)
        
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            currentRequest?.saveError(error.localizedDescription)
            
            client?.urlProtocol(self, didFailWithError: error)
            
            if let request = task.originalRequest, Debugger.shared.isResponseWillBeModified(for: request) {
                print("DEBBUG: ERROR")
            }
        } else {
            if let request = task.originalRequest, Debugger.shared.isResponseWillBeModified(for: request) {
                if var responseData = currentRequest?.dataResponse {
                    Debugger.shared.applyDebugSettings(to: &responseData, on: request)
                    
                    print("DEBBUG: ALL GOOD")
                    client?.urlProtocol(self, didLoad: responseData)
                } else {
                    print(currentRequest == nil ? "DEBBUG: nil currentRequest" : "DEBBUG: EMPTY RESPONSE")
                }
            } else {
                if let request = task.originalRequest {
                    if Debugger.shared.isResponseWillBeModified(for: request) == false {
                        print("DEBBUG: Will NOT BeModified")
                    }
                } else {
                    print("DEBBUG: originalRequest nil")
                }
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
        
        completionHandler(request)
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error else {
            return
        }
        
        currentRequest?.saveError(error.localizedDescription)
        
        client?.urlProtocol(self, didFailWithError: error)
    }
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let wrappedChallenge = URLAuthenticationChallenge(
            authenticationChallenge: challenge,
            sender: CustomAuthenticationChallengeSender(handler: completionHandler)
        )
        
        client?.urlProtocol(self, didReceive: wrappedChallenge)
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        client?.urlProtocolDidFinishLoading(self)
    }
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics
    ) {
        var receivedBytes: Int64 = .zero
        var sentBytes: Int64 = .zero
        
        metrics.transactionMetrics.forEach { metric in
            receivedBytes += metric.countOfResponseBodyBytesReceived
            sentBytes += metric.countOfRequestHeaderBytesSent
                + metric.countOfRequestBodyBytesSent
                + metric.countOfRequestBodyBytesBeforeEncoding
        }
        
        currentRequest?.collectMetrics(sentBytes: sentBytes, receivedBytes: receivedBytes)
    }
}

final class CustomAuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender {
    typealias CustomAuthenticationChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    
    let handler: CustomAuthenticationChallengeHandler
    
    init(handler: @escaping CustomAuthenticationChallengeHandler) {
        self.handler = handler
    }

    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
        handler(.useCredential, credential)
    }
    
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
        handler(.useCredential, nil)
    }
    
    func cancel(_ challenge: URLAuthenticationChallenge) {
        handler(.cancelAuthenticationChallenge, nil)
    }
    
    func performDefaultHandling(for challenge: URLAuthenticationChallenge) {
        handler(.performDefaultHandling, nil)
    }
    
    func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {
        handler(.rejectProtectionSpace, nil)
    }
}
