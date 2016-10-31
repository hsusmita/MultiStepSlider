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

class RangeSliderTrackLayer: CALayer {
	static let defaultHighlightTintColor = UIColor(red: 0, green: 122/255.0, blue: 255.0/255.0, alpha: 1.0)
	static let defaultTintColor = UIColor.lightGray

	var highlightedPath = Path(origin: 0, length: 0)
	var highlightTintColor: UIColor?
	var tintColor: UIColor?
	var curvaceousness: CGFloat = 2.0

	override func draw(in ctx: CGContext) {
		// Clip
		let cornerRadius = bounds.height * curvaceousness / 2.0
		let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
		ctx.addPath(path.cgPath)

		// Fill the track
		ctx.setFillColor((tintColor ?? RangeSliderTrackLayer.defaultTintColor).cgColor)
		ctx.addPath(path.cgPath)
		ctx.fillPath()

		// Fill the highlighted range
		ctx.setFillColor((highlightTintColor ?? RangeSliderTrackLayer.defaultHighlightTintColor).cgColor)
		let rect = CGRect(x: highlightedPath.origin, y: 0.0, width: highlightedPath.length, height: bounds.height)
		ctx.fill(rect)
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

	override func draw(in ctx: CGContext) {
		let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
		let cornerRadius = thumbFrame.height * curvaceousness / 2.0
		let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
		
		// Fill
		ctx.setFillColor(tintColor.cgColor)
		ctx.addPath(thumbPath.cgPath)
		ctx.fillPath()

		// Outline
		let strokeColor = UIColor.clear
		ctx.setStrokeColor(strokeColor.cgColor)
		ctx.setLineWidth(0.5)
		ctx.addPath(thumbPath.cgPath)
		ctx.strokePath()

		// Highlight
		if highlighted {
			ctx.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
			ctx.addPath(thumbPath.cgPath)
			ctx.fillPath()
		}
	}
}

@IBDesignable

open class MultiStepRangeSlider: UIControl {
	
	/**
	The height of track.
	
	The track is the horizontal line on which the thumbs slide
	*/

	@IBInspectable open var trackLayerHeight: CGFloat = 1.0 {
		didSet {
			var trackFrame = trackLayer.frame
			trackFrame.origin.y = (bounds.size.height - trackLayerHeight)/2
			trackFrame.size.height = trackLayerHeight
			trackLayer.frame = trackFrame
			trackLayer.setNeedsDisplay()
		}
	}
	
	/**
	The color used to tint the part of the track which is outside the range of lowerValue and upperValue.
	
	The default color is lightGrayColor.
	*/

	@IBInspectable open var trackTintColor: UIColor = RangeSliderTrackLayer.defaultTintColor {
		didSet {
			trackLayer.tintColor = trackTintColor
			trackLayer.setNeedsDisplay()
		}
	}
	
	/**
	The color used to tint the part of the track which is inside the range of lowerValue and upperValue.
	
	The default color is #007AFF (rgba = 0, 122, 255, 1)
	*/
	@IBInspectable open var trackHighlightTintColor: UIColor = RangeSliderTrackLayer.defaultHighlightTintColor {
		didSet {
			trackLayer.highlightTintColor = trackHighlightTintColor
			trackLayer.setNeedsDisplay()
		}
	}
	
	/**
	This property is used to control the curvature of ends of the track.
	
	The property can have value from 0 to 1.
	*/
	@IBInspectable open var trackCurvaceousness: CGFloat = 1.0 {
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
	
	/**
	The size of thumb.
	
	The thumbs mark the lower and upper end of the selected range on the slider
	*/
	@IBInspectable open var thumbSize: CGSize = CGSize(width: 10.0, height: 10.0) {
		didSet {
			updateLayerFrames()
		}
	}
	
	/**
	The color used as tint color for the thumbs
	
	The thumbs mark the lower and upper end of the selected range on the slider
	The default color is #007AFF (rgba = 0, 122, 255, 1)
	*/
	@IBInspectable open var thumbTintColor: UIColor = UIColor.white {
		didSet {
			lowerThumbLayer.tintColor = thumbTintColor
			upperThumbLayer.tintColor = thumbTintColor
			lowerThumbLayer.setNeedsDisplay()
			upperThumbLayer.setNeedsDisplay()
		}
	}
	
	/**
	This property is used to control the curvature of the thumbs.
	
	The property can have value from 0 to 1.
	*/
	@IBInspectable open var thumbCurvaceousness: CGFloat = 1.0 {
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
	
	/**
	Setting this propery adds shadow to both of the thumbs.
	*/
	@IBInspectable open var shadowEnabled: Bool = true {
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
	
	/**
	This represents the discrete upper and lower values.
	*/
	open var discreteCurrentValue: RangeValue = RangeValue(lower: 0, upper: 1) {
		didSet {
			updateLayerFrames()
		}
	}
	
	/**
	This gives the continuous upper and lower values.
	*/
	open var continuousCurrentValue: RangeValue {
		return RangeValue(lower: lowerValue, upper: upperValue)
	}
	
	// MARK: - Private variables

	private var intervals: [Interval] = []
	private var preSelectedRange: RangeValue?
	private var nodesList = [Float]()
	private var previousLocation = CGPoint()
	private let trackLayer = RangeSliderTrackLayer()
	private let lowerThumbLayer = RangeSliderThumbLayer()
	private let upperThumbLayer = RangeSliderThumbLayer()
	private var lowerCenter: CGFloat = 0.0
	private var upperCenter: CGFloat = 0.0
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
			if oldValue.equalTo(trackFrame) {
				return
			}
			trackLayer.frame = trackFrame
			lowerCenter = positionForNodeValue(discreteCurrentValue.lower) ?? trackFrame.minX
			upperCenter = positionForNodeValue(discreteCurrentValue.upper) ?? trackFrame.maxX
			updateLayerFrames()
		}
	}
	
	// MARK: - Life cycle
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initializeLayers()
	}
	
	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		initializeLayers()
	}

	override open func layoutSubviews() {
		super.layoutSubviews()
		trackFrame = CGRect(x: thumbSize.width/2, y: (bounds.size.height - trackLayerHeight)/2,
		                        width: bounds.size.width - thumbSize.width, height: trackLayerHeight)
	}
	
	// MARK: - Public methods
	
	/**
	The method configures the required variables
	
	- parameter intervals: The array intervals into which the slider is divided.
	preSelectedRange: This dictates the initial positions for lower and upper thumb.
	The lower and upper of RangeValue should lie within the interval specified and should be a valid node value.
	For example, if the there is an interval Interval(min: 50000, max: 100000, stepValue: 10000),
	then 60000 will be a valid node, but not 65000. In that case, a warning will be shown.
	
	*/
	open func configureSlider(intervals: [Interval], preSelectedRange: RangeValue?) {
		self.intervals = intervals
		self.preSelectedRange = preSelectedRange
		updateNodesList()
		if nodesList.count > 0 {
			if let rangeValue = preSelectedRange {
				guard let _ = positionForNodeValue(rangeValue.lower), let _ = positionForNodeValue(rangeValue.upper) else {
					print("Warning: Range contains invalid node")
					return
				}
				discreteCurrentValue = rangeValue
			} else {
				discreteCurrentValue = RangeValue(lower: Float(nodesList[0]), upper: Float(nodesList[nodesList.count-1]))
			}
			lowerValue = discreteCurrentValue.lower
			upperValue = discreteCurrentValue.upper
			lowerCenter = positionForNodeValue(discreteCurrentValue.lower) ?? trackFrame.minX
			upperCenter = positionForNodeValue(discreteCurrentValue.upper) ?? trackFrame.maxX
		}
		updateLayerFrames()
	}
	
	// MARK: - Private methods
	
	// MARK: - Drawing
	private func initializeLayers() {
		trackLayer.contentsScale = UIScreen.main.scale
		layer.addSublayer(trackLayer)

		lowerThumbLayer.contentsScale = UIScreen.main.scale
		layer.addSublayer(lowerThumbLayer)

		upperThumbLayer.contentsScale = UIScreen.main.scale
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
	
	private func addShadow(_ layer: CALayer) {
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
		layer.shadowOpacity = 0.3
		layer.shadowRadius = 2
		layer.shadowPath = UIBezierPath(roundedRect: layer.bounds.insetBy(dx: 1, dy: 2), cornerRadius: layer.bounds.height/2).cgPath
	}

	private func removeShadow(_ layer: CALayer) {
		layer.shadowOpacity = 0.0
	}
	
	// MARK: - Calculations
	/**
	The method generates node based on the intervals given.
	*/
	
	private func updateNodesList() {
		nodesList.removeAll()
		nodesList = intervals.map { $0.nodes }.flatMap { $0 }
		nodesList.uniqueInPlace()
	}
	
	/**
	The track is divided into number of nodes. Each node is assigned one value.
	
	This method returns x-cordinate of node corresponding to the given value
	
	- parameter value: The node value for which x-cordinate to be calculated
	
	- returns:
	x-cordinate of the node for the given value if such node exist, else returns nil
	
	*/
	private func positionForNodeValue(_ value: Float)-> CGFloat? {
		let scale = Float(trackLayer.frame.size.width) / (Float(nodesList.count))
		var nodeNumber = -1
		for i in 0..<nodesList.count {
			if value == nodesList[i] {
				nodeNumber = i
			}
		}
		guard nodeNumber >= 0 && nodeNumber < nodesList.count else {
			return nil
		}
		let scaledPosition = scale * Float(nodeNumber)
		if nodeNumber == nodesList.count - 1 {
			return trackLayer.frame.maxX
		}else if nodeNumber == 0 {
			return trackLayer.frame.minX
		}else {
			return CGFloat(scaledPosition + Float(trackLayer.frame.minX) + scale/2)
		}
	}
	
	/**
	The track is divided into number of nodes. Each node is assigned one value.
	
	This method fetches the node nearest to the given thumb position and returns the value assinged to the node.
	
	- parameter position: The thumb position for which node value to be calculated
	
	- returns:
	The value assinged to the node if any valid node exists at the given position, else it returns nil.
	*/
	private func nodeValueForPosition(_ position: CGFloat)-> Float? {
		let scale = trackLayer.frame.size.width / CGFloat(nodesList.count)
		let scaledPosition = position - trackLayer.frame.minX
		let nodeNumber = Int(floor(scaledPosition / scale))
		guard nodeNumber < nodesList.count && nodeNumber >= 0 else {
			return nil
		}
		return nodesList[nodeNumber]
	}
	
	/**
	This method returns the actual value corresponding to the thumb position
	
	- parameter position: The position for which value to be calculated
	
	- returns:
	The actual value corresponding to the thumb position if the position is valid, else it returns nil.
	*/
	private func actualValueForPosition(_ position: CGFloat)-> Float? {
		let scale = trackLayer.frame.size.width / CGFloat(nodesList.count)
		let scaledPosition = position - trackLayer.frame.minX
		let nodeNumber = Int(floor(scaledPosition / scale))
		guard nodeNumber < nodesList.count - 1 && nodeNumber >= 0 else {
			return nil
		}
		let nextNode = nodeNumber + 1
		let valueDifference = nodesList[nextNode] - nodesList[nodeNumber]
		let lower = CGFloat(nodeNumber) * scale
		let value = Float(scaledPosition - lower) * valueDifference / Float(scale)
		return nodesList[nodeNumber] + value
	}
	
	/**
	This method updates upperCenter(the center of upper thumb), upperValue and upper property of discreteCurrentValue
	
	- Parameter offset : The distance moved by upper thumb with respect to last location
	
	*/
	private func updateUpperValue(_ offset: CGFloat) {
		upperCenter = boundValue(upperCenter + offset, lowerValue: lowerThumbLayer.frame.midX + thumbSize.width,
		                         upperValue: trackLayer.frame.maxX)
		if let nodeValue = nodeValueForPosition(upperCenter) {
			discreteCurrentValue.upper = nodeValue
		}
		if let actualValue = actualValueForPosition(upperCenter) {
			upperValue = actualValue
		}
	}
	
	/**
	This method updates lowerCenter(the center of lower thumb), lowerValue and upper property of discreteCurrentValue
	
	- Parameter offset : The distance moved by lower thumb with respect to last location
	*/
	private func updateLowerValue(_ offset: CGFloat) {
		lowerCenter = boundValue(lowerCenter + offset,lowerValue: trackLayer.frame.minX,
		                         upperValue:  upperThumbLayer.frame.midX - thumbSize.width)
		if let nodeValue = nodeValueForPosition(lowerCenter) {
			discreteCurrentValue.lower = nodeValue
		}
		if let actualValue = actualValueForPosition(lowerCenter) {
			lowerValue = actualValue
		}
	}
	
	/**
	This method makes sure the given value lies between given upper and lower limit.
	
	- Parameter value: The value to be checked
	lowerValue: The lower limit
	upperValue: The upper limit
	
	
	- returns
	The given value if it lies within the range
	
	The lowerValue if the given value is less than the lowerValue
	
	The upperValue if the given value is greater than the upperValue
	*/
	private func boundValue(_ value: CGFloat, lowerValue: CGFloat, upperValue: CGFloat) -> CGFloat {
		return min(max(value, lowerValue), upperValue)
	}
	
	// MARK: - Touches
	
	open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		previousLocation = touch.location(in: self)
		if lowerThumbLayer.frame.contains(previousLocation) {
			lowerThumbLayer.highlighted = true
		} else if upperThumbLayer.frame.contains(previousLocation) {
			upperThumbLayer.highlighted = true
		}
		return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
	}

	open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		let location = touch.location(in: self)
		let deltaLocation = location.x - previousLocation.x
		previousLocation = location
		
		if lowerThumbLayer.highlighted {
			updateLowerValue(deltaLocation)
			
		} else if upperThumbLayer.highlighted {
			updateUpperValue(deltaLocation)
		}
		updateLayerFrames()
		sendActions(for: .valueChanged)
		return true
	}
	
	override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		lowerThumbLayer.highlighted = false
		upperThumbLayer.highlighted = false
	}
}
