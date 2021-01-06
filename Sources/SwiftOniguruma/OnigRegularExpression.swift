//
//  OnigRegularExpression.swift
//
//
//  Created by Erick Perez on 12/4/20.
//

import Foundation

import Darwin
import coniguruma

public typealias ScanCallback = (Int, Int, OnigMatches) -> Bool

public enum OnigSearchDirection {
    case forward
    case backward
}

public final class OnigRegularExpression {
    internal let pointer: OnigRegex
    let pattern: String
    let options: OnigOption
    var includedInASet: Bool

    public init(pattern string: String, options: OnigOption = .none) throws {
        Self.initialize()

        pattern = string
        let patternChars = "\(string)\0".utf8.map({ char in UInt8(char) })
        pointer = try patternChars.withUnsafeBufferPointer({ patternPointer in
            var regexPointer: OnigRegex?
            var error = OnigErrorInfo()

            let result = onig_new(&regexPointer,
                                  patternPointer.baseAddress,
                                  patternPointer.baseAddress?.advanced(by: patternPointer.count - 1),
                                  options.value,
                                  Encodings.utf8,
                                  OnigDefaultSyntax,
                                  &error)

            if result != ONIG_NORMAL {
                throw StandardError.initializationFailed("Initialization failed with error: \(result)")
            }

            return regexPointer!
        })

        self.options = options
        includedInASet = false
    }

    deinit {
        if !includedInASet {
            onig_free(pointer)
        }
    }

    internal func register() {
        includedInASet = true
    }

    public func search(in source: String, direction: OnigSearchDirection = .forward) throws-> OnigMatches {
        let sourceChars = "\(source)\0".utf8.map({ char in UInt8(char) })

        let region = onig_region_new()
        defer {
            onig_region_free(region, 1 /* 1:free self, 0:free contents only */)
        }

        return try sourceChars.withUnsafeBufferPointer({ charsPointer in
            let start: UnsafePointer<UInt8>?
            let range: UnsafePointer<UInt8>?

            if direction == .forward {
                start = charsPointer.baseAddress
                range = charsPointer.baseAddress?.advanced(by: charsPointer.count - 1)
            } else {
                start = charsPointer.baseAddress?.advanced(by: charsPointer.count - 1)
                range = charsPointer.baseAddress
            }

            let result = onig_search(pointer,
                                     charsPointer.baseAddress,
                                     charsPointer.baseAddress?.advanced(by: charsPointer.count - 1),
                                     start,
                                     range,
                                     region,
                                     options.value)

            if result >= 0 {
                guard let region = region else {
                    throw StandardError.generic("onig_search failed region nil but result is: \(result).")
                }

                return OnigMatches(region)
            } else if result != ONIG_MISMATCH {
                throw StandardError.generic("onig_search failed with error: \(result)")
            }

            return .empty()
        })
    }

    public func scan(source string: String, callback delegate: ScanCallback) throws -> Int {
        let stringChars = "\(string)\0".utf8.map({ char in UInt8(char) })

        let region = onig_region_new()
        defer { onig_region_free(region, 1 /* 1:free self, 0:free contents only */) }

        return try stringChars.withUnsafeBufferPointer({ charsPointer in
            return try withoutActuallyEscaping(delegate, do: { delegate in
                return try withUnsafePointer(to: delegate, { delegate in
                    let delegate = UnsafeMutablePointer(mutating: delegate)

                    let matches = onig_scan(pointer,
                                            charsPointer.baseAddress,
                                            charsPointer.baseAddress?.advanced(by: charsPointer.count - 1),
                                            region,
                                            ONIG_OPTION_NONE,
                                            { (number, position, matchRegion, callback) -> Int32 in
                                                guard let callback = callback?.load(as: ScanCallback.self) else {
                                                    print("[\(#function)#\(#line)] Do nothing. No callback")
                                                    return 1
                                                }

                                                let number = Int(number)
                                                let position = Int(position)
                                                let proceed = callback(number, position, OnigMatches(matchRegion))
                                                return proceed ? 0 : 1
                                            },
                                            delegate)

                    if matches >= 0 {
                        return Int(matches)
                    } else if matches != ONIG_MISMATCH {
                        throw StandardError.generic("onig_scan failed with error: \(matches)")
                    }

                    return 0
                })
            })
        })
    }

    public class func initialize() {
        var encs: UnsafeMutablePointer<OnigEncodingTypeST>? = Encodings.utf8
        _ = onig_initialize(&encs, 1)
    }

    public static var version: String {
        guard let versionStr = onig_version() else {
            return ""
        }

        return String(cString: versionStr)
    }
}
