//
//  XMLSimpleContent.swift
//  XMLCoding
//
//  Created by Vincent Esche on 1/3/19.
//  Copyright © 2019 Vincent Esche. All rights reserved.
//

import Foundation

public enum XMLSimpleContent: Equatable {
    case string(String)
    case data(Data)
    
    public var string: String? {
        switch self {
        case .string(let string):
            return string
        case .data(let data):
            return String(data: data, encoding: .utf8)
        }
    }
    
    public var data: Data? {
        guard case let .data(data) = self else {
            return nil
        }
        return data
    }
}
