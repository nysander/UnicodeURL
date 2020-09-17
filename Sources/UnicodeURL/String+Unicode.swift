//  UnicodeURL
//
//  Copyright (c) Paweł Madej 2020 | Twitter: @PawelMadejCK
//  License: MIT (see LICENCE files for details)

import Foundation
import CoreFoundation

extension String {
    var isValidCharacterSequence: Bool {
        let length = self.count
        if length == 0 {
            return true
        }

        var buffer = Array(repeating: Int8(), count: length)
        _ = self.getCString(&buffer, maxLength: length, encoding: .utf8)


        var pendingSurrogateHigh = false

        for index in 0..<length {
            let c = unichar(truncatingIfNeeded: buffer[index])
            if CFStringIsSurrogateHighCharacter(c) {
                if pendingSurrogateHigh {
                    // Surrogate high after surrogate high
                    return false
                } else {
                    pendingSurrogateHigh = true
                }
            } else if CFStringIsSurrogateLowCharacter(c) {
                if pendingSurrogateHigh {
                    pendingSurrogateHigh = false
                } else {
                    // Isolated surrogate low
                    return false
                }
            } else {
                // Isolated surrogate high
                if pendingSurrogateHigh {
                    return false
                }
            }
        }

        // Isolated surrogate high
        if pendingSurrogateHigh {
            return false
        }

        return true
    }

    func split(after string: String) -> [String] {
        let firstPart: String
        let secondPart: String
        let range: NSRange = NSString(string: self).range(of: string)

        if range.location != NSNotFound {
            let index = range.location + range.length
            firstPart = NSString(string: self).substring(to: index)
            secondPart = NSString(string: self).substring(from: index)
        } else {
            firstPart = ""
            secondPart = self
        }

        return [firstPart, secondPart]
    }

    func split(before chars: CharacterSet) -> [String] {
        var index = self.startIndex

        while index != self.endIndex {
            if chars.contains(self[index]) {
                break
            }
            index = self.index(index, offsetBy: 1)
        }

        return [
            String(self.prefix(upTo: index)),
            String(self.suffix(from: index))
        ]
    }
}

extension CharacterSet {
    func contains(_ character: Character) -> Bool {
        let string = String(character)
        return string.rangeOfCharacter(from: self, options: [], range: string.startIndex..<string.endIndex) != nil
    }
}
