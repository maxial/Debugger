//
//  HttpBodyStream.swift
//
//
//  Created by Maxim Aliev on 19.05.2024.
//

import Foundation

struct HttpBodyStream {
    let contentLength: Int?
    let inputStream: InputStream
}
