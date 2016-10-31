//
//  Array+Sorting.swift
//  Tripta
//
//  Created by Susmita Horrow on 04/01/16.
//  Copyright © 2016 Fueled. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
	public func unique() -> [Element] {
		var arrayCopy = self
		arrayCopy.uniqueInPlace()
		return arrayCopy
	}

	mutating public func uniqueInPlace() {
		var seen = [Element]()
		var index = 0
		for element in self {
			if seen.contains(element) {
				remove(at: index)
			} else {
				seen.append(element)
				index += 1
			}
		}
	}
}
