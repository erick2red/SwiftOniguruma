//
//  OnigOption.swift
//  
//
//  Created by Erick Perez on 12/30/20.
//

import Foundation

import Darwin
import coniguruma

public struct OnigOption {
    public static let none = OnigOption(value: ONIG_OPTION_NONE)
    public static let ignoreCase = OnigOption(value: ONIG_OPTION_IGNORECASE)
    public static let notBeginOfLine = OnigOption(value: ONIG_OPTION_NOTBOL)
    public static let notEndOfLine = OnigOption(value: ONIG_OPTION_NOTEOL)
    public static let notBeginOfString = OnigOption(value: ONIG_OPTION_NOT_BEGIN_STRING)
    public static let notEndOfString = OnigOption(value: ONIG_OPTION_NOT_END_STRING)
    public static let asciiOnlyWord = OnigOption(value: ONIG_OPTION_WORD_IS_ASCII)
    public static let asciiOnlyDigit = OnigOption(value: ONIG_OPTION_DIGIT_IS_ASCII)
    public static let asciiOnlySpace = OnigOption(value: ONIG_OPTION_SPACE_IS_ASCII)
    public static let asciiOnlyPOSIX = OnigOption(value: ONIG_OPTION_POSIX_IS_ASCII)
    public static let extendedPattern = OnigOption(value: ONIG_OPTION_EXTEND)
    public static let findLongest = OnigOption(value: ONIG_OPTION_FIND_LONGEST)
    public static let ignoreEmpty = OnigOption(value: ONIG_OPTION_FIND_NOT_EMPTY)

    let value: OnigOptionType
}
