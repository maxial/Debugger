//
//  RequestBody.swift
//
//
//  Created by Maxim Aliev on 19.05.2024.
//

import Foundation

struct RequestBody {
    let contentType: RequestContentType
    var body: [String: Any]
}
