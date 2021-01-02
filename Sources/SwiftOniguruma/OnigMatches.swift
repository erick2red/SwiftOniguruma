//
//  OnigMatches.swift
//  
//
//  Created by Erick Perez on 12/28/20.
//

import Foundation

import Darwin
import coniguruma

public class OnigMatches {
    var region: UnsafeMutablePointer<OnigRegion>?

    init(_ region: UnsafeMutablePointer<OnigRegion>! = nil) {
        if region != nil {
            self.region = onig_region_new()
            onig_region_copy(self.region, region)
        }
    }

    deinit {
        if region != nil {
            onig_region_free(region, 1 /* 1:free self, 0:free contents only */)
        }
    }

    public static func empty() -> OnigMatches {
        return OnigMatches()
    }

    public var isEmpty: Bool {
        get {
            return region == nil || region?.pointee.num_regs == 0
        }
    }

    public var count: Int {
        get {
            return Int(region?.pointee.num_regs ?? 0)
        }
    }

    subscript(index: Int) -> (Int, Int) {
        get {
            guard let region = region else {
                return (0, 0)
            }

            guard region.pointee.num_regs > 0 else {
                return (0, 0)
            }

            return (Int(region.pointee.beg[index]), Int(region.pointee.end[index]))
        }
    }
}
