//
//  Utility.swift
//  MultiStepSlider
//
//  Created by Susmita Horrow on 31/10/16.
//  Copyright © 2016 hsusmita. All rights reserved.
//

import Foundation
import UIKit

public struct RangeValue {
	public var lower: Float = 0.0
	public var upper: Float = 0.0
	
	public init(lower: Float, upper: Float) {
		self.lower = lower
		self.upper = upper
	}
}

/**
The struct to encapsulate the information of interval.

Initialization:
```
Interval(min: 50000, max: 100000, stepValue: 10000)
```
*/

public struct Interval {
	public private(set) var min: Float = 0.0
	public private(set) var max: Float = 0.0
	public private(set) var stepValue: Float = 0.0
	public private(set) var nodes: [Float] = []
	
	public init(min: Float, max: Float, stepValue: Float) {
		self.min = min
		self.max = max
		self.stepValue = stepValue
		var index = min
		while index <= max {
			self.nodes.append(index)
			index += stepValue
		}
	}
}

