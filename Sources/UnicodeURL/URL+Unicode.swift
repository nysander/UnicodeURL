//  UnicodeURL
//
//  Copyright (c) Paweł Madej 2020 | Twitter: @PawelMadejCK
//  License: MIT (see LICENCE files for details)

import Foundation
import IDNSDK

public struct UnicodeURLConvertError: Error {
    public enum ConvertError: Int {
        case none = 0
        case STD3NonLDH = 300
        case STD3Hyphen = 301
        case alreadyEncoded = 302
        case invalidDNSLength = 303
        case cicleCheck = 304
    }

    public let error: ConvertError
}

public extension URL {

    static func urlWithUnicodeString(str: String) -> Self {
        return self.urlWithUnicodeString(str: str)
    }

    static func urlWithUnicodeString(str: String) -> Self? {
        str.count > 0 ? self.init(unicodeString: str) : nil
    }

    init?(unicodeString string: String) {
        self.init(str: string)
    }

    init?(str: String) {
        do {
            if let asciiStr = try URL.convertUnicodeURLString(str: str, toAscii: true) {
                self.init(string: asciiStr)
            } else {
                return nil
            }
        }
        catch {
            return nil
        }
    }

    init?(unicodeUrlString string: String) throws {
        if let asciiStr = try URL.convertUnicodeURLString(str: string, toAscii: true) {
            self.init(string: asciiStr)
        }
        else {
            return nil
        }
    }

    var unicodeAbsoluteString: String? {
        do {
            return try URL.convertUnicodeURLString(str: self.absoluteString, toAscii: false)
        }
        catch {
            return nil
        }
    }

    var unicodeHost: String? {
        guard let host = self.host else { return nil }
        do {
            return try URL.convertUnicodeURLString(str: host, toAscii: false)
        }
        catch {
            return nil
        }
    }

    static func decode(unicodeDomain domain: String) -> String? {
        do {
            return try URL.convertUnicodeURLString(str: domain, toAscii: false)
        }
        catch {
            return nil
        }
    }

    static func convertUnicodeDomainString(hostname: String, toAscii: Bool) throws -> String? {
        var inputString = hostname.utf16.compactMap { UInt16(exactly: $0) }
        let inputLength = hostname.lengthOfBytes(using: .utf16) / MemoryLayout<UInt16>.size

        var hostname: String? = hostname

        var ret = XCODE_SUCCESS
        if toAscii {
            var outputLength = MAX_DOMAIN_SIZE_8
            var outputString: [UInt8] = Array(repeating: UInt8(), count: Int(outputLength))

            ret = Xcode_DomainToASCII(&inputString, Int32(inputLength), &outputString, &outputLength)

            if ret == XCODE_SUCCESS {
                hostname = String(cString: outputString)
            } else {
                /// URL specifies that if a URL is malformed then URLWithString:
                ///  returns nil, so on error we return nil here.
                hostname = nil
            }
        } else {
            var outputLength = MAX_DOMAIN_SIZE_16
            var outputString: [UInt16] = Array(repeating: UInt16(), count: Int(outputLength))

            ret = Xcode_DomainToUnicode16(&inputString, Int32(inputLength), &outputString, &outputLength)

            if ret == XCODE_SUCCESS {
                hostname = String(utf16CodeUnits: outputString, count: Int(outputLength))
            } else {
                /// URL specifies that if a URL is malformed then URLWithString:
                /// returns nil, so on error we return nil here.
                hostname = nil
            }
        }

        if ret != XCODE_SUCCESS,
           let error = UnicodeURLConvertError.ConvertError(rawValue: Int(ret)) {
            throw UnicodeURLConvertError(error: error)
        }

        return hostname
    }

    static func convertUnicodeURLString(str: String, toAscii: Bool) throws -> String? {
        guard !str.isEmpty else {
            return nil
        }

        var urlParts: [String] = []
        var hostname: String? = nil
        var parts: [String] = []

        parts = str.split(after: ":")
        hostname = parts[1]
        urlParts.append(parts[0])

        parts = hostname?.split(after: "//") ?? []
        hostname = parts[1]
        urlParts.append(parts[0])

        parts = hostname?.split(before: CharacterSet(charactersIn: "/?#")) ?? []
        hostname = parts[0]
        urlParts.append(parts[1])

        parts = hostname?.split(after: "@") ?? []
        hostname = parts[1]
        urlParts.append(parts[0])

        parts = hostname?.split(before: CharacterSet(charactersIn: ":")) ?? []
        hostname = parts[0]
        urlParts.append(parts[1])

        /// // Now that we have isolated just the hostname, do the magic decoding...
        if let hostnameDecoded = hostname {
            hostname = try URL.convertUnicodeDomainString(hostname: hostnameDecoded, toAscii: toAscii)
        }
        if hostname == nil {
            return nil
        }
        /// // This will try to clean up the stuff after the hostname in the URL by making sure it's all encoded properly.
        /// // URL doesn't normally do anything like this, but I found it useful for my purposes to put it in here.
        let afterHostname = urlParts[4].appending(urlParts[2])
        let processedAfterHostname = afterHostname.removingPercentEncoding ?? afterHostname

        var URLFragmentPlusHashtagPlusBracketsCharacterSet: CharacterSet = .urlFragmentAllowed
        URLFragmentPlusHashtagPlusBracketsCharacterSet.formUnion(CharacterSet(charactersIn: "#[]"))

        let finalAfterHostname = processedAfterHostname.addingPercentEncoding(withAllowedCharacters: URLFragmentPlusHashtagPlusBracketsCharacterSet)

        /// // Now recreate the URL safely with the new hostname (if it was successful) instead...
        let reconstructedArray = [urlParts[0],
                                  urlParts[1],
                                  urlParts[3],
                                  hostname ?? "",
                                  finalAfterHostname ?? ""]
        let reconstructedURLString = reconstructedArray.joined(separator: "")

        if reconstructedURLString.count == 0 {
            return nil
        }
        if !reconstructedURLString.isValidCharacterSequence {
            return nil
        }

        return reconstructedURLString
    }
}
