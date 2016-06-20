//
//  ViewController.swift
//  MultiStepSlider
//
//  Created by Susmita Horrow on 11/01/16.
//  Copyright © 2016 hsusmita. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var minimumLabel: UILabel!
	@IBOutlet weak var maximimLabel: UILabel!
	@IBOutlet weak var slider: MultiStepRangeSlider!
	let numberFomatter = NSNumberFormatter()

	override func viewDidLoad() {
		super.viewDidLoad()
		let intervals = [Interval(min: 50000, max: 100000, stepValue: 10000),
						Interval(min: 100000, max: 1000000, stepValue: 100000),
						Interval(min: 1000000, max: 3000000, stepValue: 500000)]
		slider.configureSlider(intervals: intervals, preSelectedRange: nil)
		minimumLabel.text = abbreviateNumber(NSNumber(float: slider.discreteCurrentValue.lower)) as String
		maximimLabel.text = abbreviateNumber(NSNumber(float: slider.discreteCurrentValue.upper)) as String
	}

	@IBAction func handleSliderChange(sender: AnyObject) {
		minimumLabel.text = abbreviateNumber(NSNumber(float: slider.discreteCurrentValue.lower)) as String
		maximimLabel.text = abbreviateNumber(NSNumber(float: slider.discreteCurrentValue.upper)) as String
		print("lower = \(slider.continuousCurrentValues.lower) higher = \(slider.continuousCurrentValues.upper)")
	}
}

//http://stackoverflow.com/questions/18267211/ios-convert-large-numbers-to-smaller-format

func abbreviateNumber(num: NSNumber) -> NSString {
	var ret: NSString = ""
	let abbrve: [String] = ["K", "M", "B"]

	let floatNum = num.floatValue

	if floatNum > 1000 {

		for i in 0..<abbrve.count {
			let size = pow(10.0, (Float(i) + 1.0) * 3.0)
			if (size <= floatNum) {
				let num = floatNum / size
				let str = floatToString(num)
				ret = NSString(format: "%@%@", str, abbrve[i])
			}
		}
	} else {
		ret = NSString(format: "%d", Int(floatNum))
	}

	return ret
}

func floatToString(val: Float) -> NSString {
	var ret = NSString(format: "%.1f", val)
	var c = ret.characterAtIndex(ret.length - 1)

	while c == 48 {
		ret = ret.substringToIndex(ret.length - 1)
		c = ret.characterAtIndex(ret.length - 1)


		if (c == 46) {
			ret = ret.substringToIndex(ret.length - 1)
		}
	}
	return ret
}



