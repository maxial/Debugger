//
//  RequestModelBeautifier.swift
//
//
//  Created by Maxim Aliev on 18.03.2024.
//

import UIKit

class RequestModelBeautifier: NSObject {
    
    static func overview(request: RequestModel) -> NSMutableAttributedString{
        let url = NSMutableAttributedString().bold("URL ").normal((request.url?.absoluteString ?? "") + "\n")
        let method = NSMutableAttributedString().bold("Method ").normal(request.method + "\n")
        let responseCode = NSMutableAttributedString().bold("Response Code ").normal((request.code?.description ?? "") + "\n")
        let requestStartTime = NSMutableAttributedString().bold("Request Start Time ").normal((request.date.stringWithFormat(dateFormat: "MMM d yyyy - HH:mm:ss") ?? "-") + "\n")
        let duration = NSMutableAttributedString().bold("Duration ").normal(request.duration?.formattedMilliseconds() ?? "-" + "\n")
        let final = NSMutableAttributedString()
        for attr in [url, method, responseCode, requestStartTime, duration]{
            final.append(attr)
        }
        return final
    }
    
    static func header(_ headers: [String: String]?) -> NSMutableAttributedString{
        guard let headerDictionary = headers else {
            return NSMutableAttributedString(string: "-")
        }
        let final = NSMutableAttributedString()
        for (key, value) in headerDictionary {
            final.append(NSMutableAttributedString().bold(key).normal(" " + value + "\n"))
        }
        return final
    }
    
    static func body(_ body: Data?, splitLength: Int? = nil, completion: @escaping (String) -> Void){
        DispatchQueue.global().async {
            completion(RequestModelBeautifier.body(body, splitLength: splitLength))
            return
        }
    }
    
    static func body(_ body: Data?, splitLength: Int? = nil) -> String{
        guard body != nil else {
            return "-"
        }
        
        if let data = splitLength != nil ? String(data: body!, encoding: .utf8)?.characters(n: splitLength!) : String(data: body!, encoding: .utf8){
            return data.prettyPrintedJSON ?? data
        }
        
        return "-"
    }
    
    static func txtExport(request: RequestModel) -> String{
        
        var txt: String = ""
        txt.append("*** Overview *** \n")
        txt.append(overview(request: request).string + "\n\n")
        txt.append("*** Request Header *** \n")
        txt.append(header(request.headers).string + "\n\n")
        txt.append("*** Request Body *** \n")
        txt.append(body(request.httpBody) + "\n\n")
        txt.append("*** Response Header *** \n")
        txt.append(header(request.responseHeaders).string + "\n\n")
        txt.append("*** Response Body *** \n")
        txt.append(body(request.dataResponse) + "\n\n")
        txt.append("------------------------------------------------------------------------\n")
        txt.append("------------------------------------------------------------------------\n")
        txt.append("------------------------------------------------------------------------\n\n\n\n")
        return txt
    }
    
    static func curlExport(request: RequestModel) -> String{
        
        var txt: String = ""
        txt.append("*** Overview *** \n")
        txt.append(overview(request: request).string + "\n\n")
        txt.append("*** curl Request *** \n")
        txt.append(request.curlRequest + "\n\n")
        txt.append("*** Response Header *** \n")
        txt.append(header(request.responseHeaders).string + "\n\n")
        txt.append("*** Response Body *** \n")
        txt.append(body(request.dataResponse) + "\n\n")
        txt.append("------------------------------------------------------------------------\n")
        txt.append("------------------------------------------------------------------------\n")
        txt.append("------------------------------------------------------------------------\n\n\n\n")
        return txt
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 15)]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14)]
        let normal = NSMutableAttributedString(string:text, attributes: attrs)
        append(normal)
        return self
    }
    
    func chageTextColor(to color: UIColor) -> NSMutableAttributedString {
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color , range: NSRange(location: 0,length: string.count))
        return self
    }
}

extension Dictionary {
    var prettyPrintedJSON: String? {
        do {
            let data: Data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        } catch _ {
            return nil
        }
    }
}

extension String {
    var prettyPrintedJSON: String? {
        guard let stringData = self.data(using: .utf8),
            let object = try? JSONSerialization.jsonObject(with: stringData, options: []),
            let jsonData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let formattedJSON = String(data: jsonData, encoding: .utf8) else { return nil }

        return formattedJSON.replacingOccurrences(of: "\\/", with: "/")
    }
}

extension Date {
    func stringWithFormat(dateFormat: String, timezone: TimeZone? = nil) -> String?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if timezone != nil{
            dateFormatter.timeZone = timezone!
        }
        return dateFormatter.string(from: self)
    }
}

extension Double {
    func formattedMilliseconds() -> String {
        let rounded = self
        if rounded < 1000 {
            return "\(Int(rounded)) ms"
        } else if rounded < 1000 * 60 {
            let seconds = rounded / 1000
            return "\(Int(seconds)) s"
        } else if rounded < 1000 * 60 * 60 {
            let secondsTemp = rounded / 1000
            let minutes = secondsTemp / 60
            let seconds = (rounded - minutes * 60 * 1000) / 1000
            return "\(Int(minutes)) m \(Int(seconds)) s"
        } else if self < 1000 * 60 * 60 * 24 {
            let minutesTemp = rounded / 1000 / 60
            let hours = minutesTemp / 60
            let minutes = (rounded - hours * 60 * 60 * 1000) / 1000 / 60
            let seconds = (rounded - hours * 60 * 60 * 1000 - minutes * 60 * 1000) / 1000
            return "\(Int(hours)) h \(Int(minutes)) m \(Int(seconds)) s"
        } else {
            let hoursTemp = rounded / 1000 / 60 / 60
            let days = hoursTemp / 24
            let hours = (rounded - days * 24 * 60 * 60 * 1000) / 1000 / 60 / 60
            let minutes = (rounded - days * 24 * 60 * 60 * 1000 - hours * 60 * 60 * 1000) / 1000 / 60
            let seconds = (rounded - days * 24 * 60 * 60 * 1000 - hours * 60 * 60 * 1000 - minutes * 60 * 1000) / 1000
            return "\(Int(days)) d \(Int(hours)) h \(Int(minutes)) m \(Int(seconds)) s"
        }
    }
}

extension Int64 {
    var formattedDataSize: String {
        if self < 1024 {
            return "\(self) B"
        } else if self < 1024 * 1024 {
            return String(format: "%.01f KB", Float(self) / 1024)
        } else if self < 1024 * 1024 * 1024 {
            return String(format: "%.01f MB", Float(self) / (1024 * 1024))
        } else if self < 1024 * 1024 * 1024 * 1024 {
            return String(format: "%.01f GB", Float(self) / (1024 * 1024 * 1024))
        } else {
            return String(format: "%.01f TB", Float(self) / (1024 * 1024 * 1024 * 1024))
        }
    }
}

extension String {
    //substrings of equal length
    func characters(n: Int) -> String{
        return String(prefix(n))
    }
}
