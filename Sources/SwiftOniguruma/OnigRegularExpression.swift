import Foundation

import Darwin
import coniguruma

public final class OnigRegularExpression {
    static var initialized: Bool = false

    var regex: OnigRegex?

    public class func initialize() {
        var encoding = OnigEncodingUTF8

        if !initialized {
            withUnsafeMutablePointer(to: &encoding, { useEncodings in
                var encs: UnsafeMutablePointer<OnigEncodingTypeST>? = useEncodings
                _ = onig_initialize(&encs, 1)
            })

            initialized = true
        }
    }

    public init(from pattern: String) throws {
        if !Self.initialized {
            Self.initialize()
        }

        guard let patternChars = pattern.cString(using: .utf8)?.map({ c in UInt8(c) }) else {
            throw StandardError.invalidArgument("Pattern \"\(pattern)\" can't be processed")
        }

        regex = nil

        try patternChars.withUnsafeBufferPointer({ patternPointer in
            var encoding = OnigEncodingUTF8
            var error = OnigErrorInfo()

            let result = onig_new(&regex,
                                  patternPointer.baseAddress,
                                  patternPointer.baseAddress?.advanced(by: patternPointer.count),
                                  OnigOptionType(),
                                  &encoding,
                                  OnigDefaultSyntax,
                                  &error)

            if result != ONIG_NORMAL {
                throw StandardError.initializationFailed("Initialization failed with error: \(result)")
            }
        })
    }

    deinit {
        onig_free(regex)
    }

    public func search(in source: String) throws {
        guard let sourceChars = source.cString(using: .utf8)?.map({ c in UInt8(c) }) else {
            throw StandardError.invalidArgument("Source \"\(source)\" can't be processed")
        }

        let region = onig_region_new()
        defer {
            onig_region_free(region, 1 /* 1:free self, 0:free contents only */)
        }

        try sourceChars.withUnsafeBufferPointer({ charsPointer in
            let result = onig_search(regex,
                                     charsPointer.baseAddress,
                                     charsPointer.baseAddress?.advanced(by: charsPointer.count),
                                     charsPointer.baseAddress,
                                     charsPointer.baseAddress?.advanced(by: charsPointer.count),
                                     region,
                                     ONIG_OPTION_NONE)

            if result >= 0 {
                guard let region = region else {
                    throw StandardError.generic("onig_search failed with: \(result) but region is nil")
                }

                print("[\(#function)#\(#line)] match found at: \(result)")
                let numberOfMatchers = region.pointee.num_regs
                for i in 0..<numberOfMatchers {
                    let start = region.pointee.beg[Int(i)]
                    let end = region.pointee.end[Int(i)]
                    print("Match[\(i)] starts at: \(start) and ends at: \(end)")
                }
            }
            else if result == ONIG_MISMATCH {
                //FIXME: return not found
                throw StandardError.initializationFailed("Initialization failed with error: \(result)")
            } else {
                throw StandardError.generic("Initialization failed with error: \(result)")
            }
        })
    }

    public static var version: String {
        guard let versionStr = onig_version() else {
            return ""
        }

        return String(cString: versionStr)
    }
}
