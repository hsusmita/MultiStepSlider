//
//  MultiStepSlider.swift
//  MultiStepSlider
//
//  Created by Susmita Horrow on 11/01/16.
//  Copyright © 2016 hsusmita. All rights reserved.

import Foundation
import UIKit
import QuartzCore

struct Path {
	var origin: CGFloat = 0
	var length: CGFloat = 0
}

public struct Interval {
	var min: Float = 0.0
	var max: Float = 1.0
	var stepValue: Float = 1.0

	func nodeCount() -> Int {
		return Int((max - min) / stepValue) - 1
	}

	func generateNodes() -> [Float] {
		var nodes = [Float]()
		var index = min
		while index <= max {
			nodes.append(index)
			index += stepValue
		}
		return nodes
	}
}

public struct RangeValue {
	var lower: Float = 0.0
	var upper: Float = 0.0
}

class RangeSliderTrackLayer: CALayer {
	static let defaultHighlightTintColor = UIColor(red: 0, green: 122/255.0, blue: 255.0/255.0, alpha: 1.0)
	static let defaultTintColor = UIColor.lightGrayColor()

	var highlightedPath = Path(origin: 0, length: 0)
	var highlightTintColor: UIColor?
	var tintColor: UIColor?
	var curvaceousness: CGFloat = 2.0

	override func drawInContext(ctx: CGContext) {
		// Clip
		let cornerRadius = bounds.height * curvaceousness / 2.0
		let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
		CGContextAddPath(ctx, path.CGPath)

		// Fill the track
		CGContextSetFillColorWithColor(ctx, (tintColor ?? RangeSliderTrackLayer.defaultTintColor).CGColor)
		CGContextAddPath(ctx, path.CGPath)
		CGContextFillPath(ctx)

		// Fill the highlighted range
		CGContextSetFillColorWithColor(ctx, (highlightTintColor ?? RangeSliderTrackLayer.defaultHighlightTintColor).CGColor)
		let rect = CGRect(x: highlightedPath.origin, y: 0.0, width: highlightedPath.length, height: bounds.height)
		CGContextFillRect(ctx, rect)
	}
}

class RangeSliderThumbLayer: CALayer {
	static let defaultTintColor = UIColor(red: 0, green: 122/255.0, blue: 255.0/255.0, alpha: 1.0)
	var highlighted: Bool = false {
		didSet {
			setNeedsDisplay()
		}
	}
	var curvaceousness: CGFloat = 2.0
	var tintColor = defaultTintColor

	override func drawInContext(ctx: CGContext) {
		let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
		let cornerRadius = thumbFrame.height * curvaceousness / 2.0
		let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)

		// Fill
		CGContextSetFillColorWithColor(ctx, tintColor.CGColor)
		CGContextAddPath(ctx, thumbPath.CGPath)
		CGContextFillPath(ctx)

		// Outline
		let strokeColor = UIColor.clearColor()
		CGContextSetStrokeColorWithColor(ctx, strokeColor.CGColor)
		CGContextSetLineWidth(ctx, 0.5)
		CGContextAddPath(ctx, thumbPath.CGPath)
		CGContextStrokePath(ctx)

		// Highlight
		if highlighted {
			CGContextSetFillColorWithColor(ctx, UIColor(white: 0.0, alpha: 0.1).CGColor)
			CGContextAddPath(ctx, thumbPath.CGPath)
			CGContextFillPath(ctx)
		}
	}
}

@IBDesignable
public class MultiStepRangeSlider: UIControl {

	@IBInspectable var trackLayerHeight: CGFloat = 1.0 {
		didSet {
			var trackFrame = trackLayer.frame
			trackFrame.origin.y = (bounds.size.height - trackLayerHeight)/2
			trackFrame.size.height = trackLayerHeight
			trackLayer.frame = trackFrame
			trackLayer.setNeedsDisplay()
		}
	}

	@IBInspectable var trackTintColor: UIColor = RangeSliderTrackLayer.defaultTintColor {
		didSet {
			trackLayer.tintColor = trackTintColor
			trackLayer.setNeedsDisplay()
		}
	}

	@IBInspectable var trackHighlightTintColor: UIColor = RangeSliderTrackLayer.defaultHighlightTintColor {
		didSet {
			trackLayer.highlightTintColor = trackHighlightTintColor
			trackLayer.setNeedsDisplay()
		}
	}


	@IBInspectable var trackCurvaceousness: CGFloat = 1.0 {
		didSet {
			if trackCurvaceousness < 0.0 {
				trackCurvaceousness = 0.0
			}

			if trackCurvaceousness > 1.0 {
				trackCurvaceousness = 1.0
			}
			trackLayer.curvaceousness = trackCurvaceousness
			trackLayer.setNeedsDisplay()
		}
	}

	@IBInspectable var thumbSize: CGSize = CGSize(width: 10.0, height: 10.0) {
		didSet {
			updateLayerFrames()
		}
	}

	@IBInspectable var thumbTintColor: UIColor = UIColor.whiteColor() {
		didSet {
			lowerThumbLayer.tintColor = thumbTintColor
			upperThumbLayer.tintColor = thumbTintColor
			lowerThumbLayer.setNeedsDisplay()
			upperThumbLayer.setNeedsDisplay()
		}
	}

	@IBInspectable var thumbCurvaceousness: CGFloat = 1.0 {
		didSet {
			if thumbCurvaceousness < 0.0 {
				thumbCurvaceousness = 0.0
			}

			if thumbCurvaceousness > 1.0 {
				thumbCurvaceousness = 1.0
			}
			lowerThumbLayer.curvaceousness = thumbCurvaceousness
			upperThumbLayer.curvaceousness = thumbCurvaceousness
			lowerThumbLayer.setNeedsDisplay()
			upperThumbLayer.setNeedsDisplay()
		}
	}

	@IBInspectable var shadowEnabled: Bool = true {
		didSet {
			if shadowEnabled {
				addShadow(lowerThumbLayer)
				addShadow(upperThumbLayer)
			} else {
				removeShadow(lowerThumbLayer)
				removeShadow(upperThumbLayer)
			}
		}
	}

	var discreteCurrentValue: RangeValue = RangeValue(lower: 0, upper: 1) {
		didSet {
			updateLayerFrames()
		}
	}
	var continuousCurrentValue: RangeValue {
		return RangeValue(lower: lowerValue, upper: upperValue)
	}

	private var previousLocation = CGPoint()
	private let trackLayer = RangeSliderTrackLayer()
	private let lowerThumbLayer = RangeSliderThumbLayer()
	private let upperThumbLayer = RangeSliderThumbLayer()
	private var intervals: [Interval] = []
	private var preSelectedRange: RangeValue?
	private var nodesList = [Float]()
	private var lowerValue: Float = 0.0 {
		didSet {
			updateLayerFrames()
		}
	}

	private var upperValue: Float = 1.0 {
		didSet {
			updateLayerFrames()
		}
	}

	private var trackFrame: CGRect = CGRect.zero {
		didSet {
			if CGRectEqualToRect(oldValue, trackFrame) {
				return
			}
			trackLayer.frame = trackFrame
			lowerCenter = positionForNodeValue(discreteCurrentValue.lower) ?? CGRectGetMinX(trackFrame)
			upperCenter = positionForNodeValue(discreteCurrentValue.upper) ?? CGRectGetMaxX(trackFrame)
			updateLayerFrames()
		}
	}
	private var lowerCenter: CGFloat = 0.0
	private var upperCenter: CGFloat = 0.0

	override init(frame: CGRect) {
		super.init(frame: frame)
		initializeLayers()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		initializeLayers()
	}

	public func configureSlider(intervals intervals: [Interval], preSelectedRange: RangeValue?) {
		self.intervals = intervals
		self.preSelectedRange = preSelectedRange
		updateNodesList()
		if nodesList.count > 0 {
			if let rangeValue = preSelectedRange {
				guard let _ = positionForNodeValue(rangeValue.lower), _ = positionForNodeValue(rangeValue.upper) else {
					print("Warning: Range contains invalid node")
					return
				}
				discreteCurrentValue = rangeValue
			} else {
				discreteCurrentValue = RangeValue(lower: Float(nodesList[0]), upper: Float(nodesList[nodesList.count-1]))
			}
			lowerCenter = positionForNodeValue(discreteCurrentValue.lower) ?? CGRectGetMinX(trackFrame)
			upperCenter = positionForNodeValue(discreteCurrentValue.upper) ?? CGRectGetMaxX(trackFrame)
		}
		updateLayerFrames()
	}

	override public func layoutSubviews() {
		super.layoutSubviews()
		trackFrame = CGRectMake(thumbSize.width/2, (bounds.size.height - trackLayerHeight)/2,
		bounds.size.width - thumbSize.width, trackLayerHeight)
	}

	// MARK: - Private methods

	private func initializeLayers() {
		trackLayer.contentsScale = UIScreen.mainScreen().scale
		layer.addSublayer(trackLayer)

		lowerThumbLayer.contentsScale = UIScreen.mainScreen().scale
		layer.addSublayer(lowerThumbLayer)

		upperThumbLayer.contentsScale = UIScreen.mainScreen().scale
		layer.addSublayer(upperThumbLayer)
	}

	private func updateLayerFrames() {
		CATransaction.begin()
		CATransaction.setDisableActions(true)

		trackLayer.highlightedPath = Path(origin: lowerCenter - thumbSize.width/2,length: upperCenter - lowerCenter)
		trackLayer.setNeedsDisplay()

		lowerThumbLayer.frame = CGRect(x: lowerCenter - thumbSize.width/2, y: (bounds.size.height - thumbSize.height)/2,
		width: thumbSize.width, height: thumbSize.height)
		lowerThumbLayer.setNeedsDisplay()

		upperThumbLayer.frame = CGRect(x: upperCenter - thumbSize.width/2, y: (bounds.size.height - thumbSize.height)/2,
		width: thumbSize.width, height: thumbSize.height)
		upperThumbLayer.setNeedsDisplay()

		CATransaction.commit()
	}

	private func positionForNodeValue(value: Float)-> CGFloat? {
		let scale = Float(trackLayer.frame.size.width) / (Float(nodesList.count))
		var nodeNumber = -1
		for i in 0..<nodesList.count {
			if value == nodesList[i] {
				nodeNumber = i
			}
		}
		if nodeNumber >= 0 && nodeNumber < nodesList.count {
			let scaledPosition = scale * Float(nodeNumber)
			if nodeNumber == nodesList.count - 1 {
				return CGRectGetMaxX(trackLayer.frame)
			}else if nodeNumber == 0 {
				return CGRectGetMinX(trackLayer.frame)
			}else {
				return CGFloat(scaledPosition + Float(CGRectGetMinX(trackLayer.frame)) + scale/2)
			}
		}else {
			return nil
		}
	}

	private func nodeValueForPosition(position: CGFloat)-> Float? {
		let scale = trackLayer.frame.size.width / CGFloat(nodesList.count)
		let scaledPosition = position - CGRectGetMinX(trackLayer.frame)
		let nodeNumber = Int(floor(scaledPosition / scale))
		if nodeNumber < nodesList.count && nodeNumber >= 0 {
			return nodesList[nodeNumber]
		}else {
			return nil
		}
	}

	private func actualValueForPosition(position: CGFloat)-> Float? {
		let scale = trackLayer.frame.size.width / CGFloat(nodesList.count)
		let scaledPosition = position - CGRectGetMinX(trackLayer.frame)
		let nodeNumber = Int(floor(scaledPosition / scale))
		if nodeNumber < nodesList.count - 1 && nodeNumber >= 0 {
			let nextNode = nodeNumber + 1
			let valueDifference = nodesList[nextNode] - nodesList[nodeNumber]
			let lower = CGFloat(nodeNumber) * scale
			let value = Float(scaledPosition - lower) * valueDifference / Float(scale)
			return nodesList[nodeNumber] + value
		} else {
			return nil
		}
	}

	private func updateNodesList() {
		nodesList.removeAll()
		for interval in intervals {
			nodesList += interval.generateNodes()
		}
		nodesList.uniqueInPlace()
	}

	private var numberOfNodes: Int {
		var nodeCount = 0
		for interval in intervals {
			nodeCount += Int((interval.max - interval.min) / interval.stepValue)
		}
		nodeCount -= intervals.count - 1
		return nodeCount
	}

	private func addShadow(layer: CALayer) {
		layer.shadowColor = UIColor.blackColor().CGColor
		layer.shadowOffset = CGSizeMake(0.0, 2.0)
		layer.shadowOpacity = 0.3
		layer.shadowRadius = 2
		layer.shadowPath = UIBezierPath(roundedRect: layer.bounds.insetBy(dx: 1, dy: 2), cornerRadius: layer.bounds.height/2).CGPath
	}

	private func removeShadow(layer: CALayer) {
		layer.shadowOpacity = 0.0
	}

	private func updateUpperValue(offset: CGFloat) {
		upperCenter = boundValue(upperCenter + offset, toLowerValue: CGRectGetMidX(lowerThumbLayer.frame) + thumbSize.width,
		                         upperValue: CGRectGetMaxX(trackLayer.frame))
		if let nodeValue = nodeValueForPosition(upperCenter) {
			discreteCurrentValue.upper = nodeValue
		}
		if let actualValue = actualValueForPosition(upperCenter) {
			upperValue = actualValue
		}
	}

	private func updateLowerValue(offset: CGFloat) {
		lowerCenter = boundValue(lowerCenter + offset, toLowerValue: CGRectGetMinX(trackLayer.frame),
		                         upperValue:  CGRectGetMidX(upperThumbLayer.frame) - thumbSize.width)
		if let nodeValue = nodeValueForPosition(lowerCenter) {
			discreteCurrentValue.lower = nodeValue
		}
		if let actualValue = actualValueForPosition(lowerCenter) {
			lowerValue = actualValue
		}
	}

	private func boundValue(value: CGFloat, toLowerValue lowerValue: CGFloat, upperValue: CGFloat) -> CGFloat {
		return min(max(value, lowerValue), upperValue)
	}

	// MARK: - Touches

	public override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
		previousLocation = touch.locationInView(self)
		if lowerThumbLayer.frame.contains(previousLocation) {
			lowerThumbLayer.highlighted = true
		} else if upperThumbLayer.frame.contains(previousLocation) {
			upperThumbLayer.highlighted = true
		}
		return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
	}

	public override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
		let location = touch.locationInView(self)
		let deltaLocation = location.x - previousLocation.x
		previousLocation = location

		if lowerThumbLayer.highlighted {
			updateLowerValue(deltaLocation)

		} else if upperThumbLayer.highlighted {
			updateUpperValue(deltaLocation)
		}
		updateLayerFrames()
		sendActionsForControlEvents(.ValueChanged)
		return true
	}

	override public func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
		lowerThumbLayer.highlighted = false
		upperThumbLayer.highlighted = false
	}
}
