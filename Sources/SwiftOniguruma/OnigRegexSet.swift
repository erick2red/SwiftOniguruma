//
//  OnigRegexSet.swift
//  
//
//  Created by Erick Perez on 1/3/21.
//

import Foundation

import Darwin
import coniguruma

public final class OnigRegexSet {
    let pointer: OpaquePointer
    var expressions: [OnigRegularExpression]

    public init() throws {
        OnigRegularExpression.initialize()

        var regset: OpaquePointer?
        let result = onig_regset_new(&regset, 0, nil)
        if result != ONIG_NORMAL {
            throw StandardError.initializationFailed("Initialization failed with error: \(result)")
        }

        pointer = regset!
        expressions = []
    }

    deinit {
        expressions.forEach({ regex in try? regex.removedFromSet() })
        expressions.removeAll()

        onig_regset_free(pointer)
    }

    public func add(_ regex: OnigRegularExpression) throws {
        let result = onig_regset_add(pointer, regex.pointer)
        if result == ONIG_NORMAL {
            expressions.append(regex)
        } else if result != ONIG_NORMAL {
            throw StandardError.generic("Add failed with error: \(result)")
        }
    }

    public func firstMatch(in source: String) throws -> (regex: OnigRegularExpression?, matches: OnigMatches) {
        let sourceChars = "\(source)\0".utf8.map({ char in UInt8(char) })

        let result = sourceChars.withUnsafeBufferPointer({ charsPointer -> Int32 in
            var matchPosition: Int32 = 0
            return onig_regset_search(pointer,
                                      charsPointer.baseAddress,
                                      charsPointer.baseAddress?.advanced(by: charsPointer.count - 1),
                                      charsPointer.baseAddress,
                                      charsPointer.baseAddress?.advanced(by: charsPointer.count - 1),
                                      ONIG_REGSET_POSITION_LEAD,
                                      OnigOption.none.value,
                                      &matchPosition)
        })

        if result >= 0 {
            let region = onig_regset_get_region(pointer, result)

            return (expressions[Int(result)], OnigMatches(region))
        } else if result != ONIG_MISMATCH {
            throw StandardError.generic("onig_search failed with error: \(result)")
        }

        return (nil, .empty())
    }
}
