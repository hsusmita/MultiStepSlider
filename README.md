[![Version](https://img.shields.io/badge/pod-2.0-green.svg)](https://cocoapods.org/pods/MultiStepSlider)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://cocoadocs.org/docsets/MultiStepSlider)
[![Documents](https://img.shields.io/badge/platform-iOS-orange.svg?style=flat)](http://cocoadocs.org/docsets/MultiStepSlider)

# MultiStepSlider

A custom UIControl which functions like UISlider where you can set multiple intervals with different step values for each interval. This is useful when an interval spans over large values, for example, price of real estates. In that case it is convenient to divide the large interval in smaller intervals with each interval having its own step value.

#Installation

Add following lines in your pod file if you are using Swift 3
```
pod ‘MultiStepSlider’, '~> 2.0'

```
 
Add following lines in your pod file for previous Swift versions
```
pod ‘MultiStepSlider’, '~> 1.4'
```
#Usage

```objc
import ‘MultiStepSlider’
```

In interface builder, drag one UIView and set its class as MultiStepSlider.

![](https://cloud.githubusercontent.com/assets/3590619/16220300/a3d884ea-37a9-11e6-8732-76d16422ba57.png)

#### Configuration

**MultiStepSlider** can be configured by the following method. 
```
func configureSlider(intervals intervals: [Interval], preSelectedRange: RangeValue?)
```
The first parameter is an array of type **Interval** which is defined as:
```
 public struct Interval {
	public private(set) var min: Float = 0.0
	public private(set) var max: Float = 0.0
	public private(set) var stepValue: Float = 0.0
 }
```
The second parameter is of type **RangeValue** which is defined as:
```
 public struct RangeValue {
	public var lower: Float = 0.0
	public var upper: Float = 0.0
 }
```
This dictates the initial positions for lower and upper thumb. The _lower_ and _upper_ of **RangeValue** should lie within the interval specified and should be a valid node value. For example, if the there is an interval
**Interval(min: 50000, max: 100000, stepValue: 10000)**, then **60000** will be a valid node, but not **65000**. In that case, a warning will be shown.

```
Warning: Range contains invalid node
```

#### Example
```
@IBOutlet weak var slider: MultiStepRangeSlider!
override func viewDidLoad() {
super.viewDidLoad()
let intervals = [Interval(min: 50000, max: 100000, stepValue: 10000),
Interval(min: 100000, max: 1000000, stepValue: 100000),
Interval(min: 1000000, max: 3000000, stepValue: 500000)]
let preSelectedRange = RangeValue(lower: 80000, upper: 500000)
slider.configureSlider(intervals: intervals, preSelectedRange: preSelectedRange)
print("continuous: lower = \(slider.continuousCurrentValues.lower) higher = \(slider.continuousCurrentValues.upper)")
print("discrete: lower = \(slider.discreteCurrentValue.lower) higher = \(slider.discreteCurrentValue.upper)")
}
```
<img src="https://cloud.githubusercontent.com/assets/3590619/16224574/4260d8a4-37c0-11e6-8d39-7d9c6b7497af.gif" width="400" display="inline-block">

# Properties

#### discreteCurrentValue

This is of type RangeValue and gives the discrete upper and lower value.

#### continuousCurrentValue

This is of type RangeValue and gives the continuous upper and lower value.

#### trackTintColor

This color is used to tint the part of the track which is outside the range of lower thumb and upper thumb.

The default color is lightGrayColor.

#### trackHighlightTintColor

The color used to tint the part of the track which is inside the range of lowerValue and upperValue.

The default color is #007AFF (rgba = 0, 122, 255, 1)

#### trackCurvaceousness

This property is used to control the curvature of ends of the track. The property can have value from 0 to 1.
<p>trackCurvaceousness = 0.0</p><span>
<img src="https://cloud.githubusercontent.com/assets/3590619/16221343/dd8df9e4-37af-11e6-93d8-626cb9d4aedb.png"  width="200" height="30" display="inline-block"></span>
<p>trackCurvaceousness = 1.0</p><span>
<img src="https://cloud.githubusercontent.com/assets/3590619/16221294/9e9149f8-37af-11e6-9f97-b088fdb90869.png"  width="200" height="40" display="inline-block"/></span>

#### thumbCurvaceousness

This property is used to control the curvature of the thumbs. The property can have value from 0 to 1. 

<p>trackCurvaceousness = 0.5</p><span>
<img src="https://cloud.githubusercontent.com/assets/3590619/16221988/599a7910-37b3-11e6-8f3d-8dc293dde98f.png"  width="200" height="30" display="inline-block"></span>
<p>trackCurvaceousness = 1.0</p><span>
<img src="https://cloud.githubusercontent.com/assets/3590619/16221294/9e9149f8-37af-11e6-9f97-b088fdb90869.png"  width="200" height="40" display="inline-block"/></span>

#### shadowEnabled

Setting this property as true will show shadow around the thumbs.

# License

MultiStepSlider is available under the MIT License.

# Reference

https://github.com/warchimede/RangeSlider/
