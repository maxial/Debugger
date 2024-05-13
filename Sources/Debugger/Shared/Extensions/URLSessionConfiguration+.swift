//
//  URLSessionConfiguration+.swift
//
//
//  Created by Maxim Aliev on 17.03.2024.
//

import Foundation

extension URLSessionConfiguration {
    @objc static func setupSwizzledSessionConfiguration() {
        let defaultSessionConfiguration = class_getClassMethod(
            URLSessionConfiguration.self,
            #selector(getter: URLSessionConfiguration.default)
        )
        
        let debugDefaultSessionConfiguration = class_getClassMethod(
            URLSessionConfiguration.self,
            #selector(URLSessionConfiguration.debugDefaultSessionConfiguration)
        )
        
        if let defaultSessionConfiguration, let debugDefaultSessionConfiguration {
            method_exchangeImplementations(defaultSessionConfiguration, debugDefaultSessionConfiguration)
        }
        
        let ephemeralSessionConfiguration = class_getClassMethod(
            URLSessionConfiguration.self,
            #selector(getter: URLSessionConfiguration.ephemeral)
        )
        
        let debugEphemeralSessionConfiguration = class_getClassMethod(
            URLSessionConfiguration.self,
            #selector(URLSessionConfiguration.debugEphemeralSessionConfiguration)
        )
        
        if let ephemeralSessionConfiguration, let debugEphemeralSessionConfiguration {
            method_exchangeImplementations(ephemeralSessionConfiguration, debugEphemeralSessionConfiguration)
        }
    }
    
    @objc class func debugDefaultSessionConfiguration() -> URLSessionConfiguration {
        let configuration = debugDefaultSessionConfiguration()
        configuration.protocolClasses?.insert(DebugHTTPProtocol.self, at: .zero)
        URLProtocol.registerClass(DebugHTTPProtocol.self)
        return configuration
    }
    
    @objc class func debugEphemeralSessionConfiguration() -> URLSessionConfiguration {
        let configuration = debugEphemeralSessionConfiguration()
        configuration.protocolClasses?.insert(DebugHTTPProtocol.self, at: .zero)
        URLProtocol.registerClass(DebugHTTPProtocol.self)
        return configuration
    }
}
