//
//  Type+Extension.swift
//  Kiwee
//
//  Created by NY on 2024/4/22.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension Array where Element == Message {
    var contentCount: Int { reduce(0, { $0 + $1.content.count }) }
}
