//
//  File.swift
//  
//
//  Created by Erick Perez on 12/4/20.
//

import Foundation

// FIXME: Add me to a library
enum StandardError: Error {
    case invalidArgument(String)
    case initializationFailed(String)
    case generic(String)
}
