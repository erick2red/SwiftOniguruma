//
//  Encodings.swift
//  
//
//  Created by Erick Perez on 12/15/20.
//

import coniguruma

struct Encodings {
    static let utf8: OnigEncoding = UnsafeMutablePointer<OnigEncodingType>(&OnigEncodingUTF8)
    static let ascii: OnigEncoding = UnsafeMutablePointer<OnigEncodingType>(&OnigEncodingASCII)
}
