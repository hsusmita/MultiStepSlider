Pod:: Spec.new do |spec|
  spec.platform     = 'ios', '8.0'
  spec.name         = 'MultiStepRangeSlider'
  spec.version      = '1.2'
  spec.summary      = 'A custom UIControl which functions like UISlider where you can set multiple intervals with different step values for each interval.'
spec.author = {
    'Susmita Horrow' => 'susmita.horrow@gmail.com'
  }
  spec.license          = 'MIT'
  spec.homepage         = 'https://github.com/hsusmita/MultiStepSlider'
  spec.source = {
    :git => 'https://github.com/hsusmita/MultiStepSlider.git',
    :tag => '1.2'
  }
  spec.ios.deployment_target = '8.0'
  spec.source_files = 'MultiStepSlider/Source/*'
  spec.requires_arc = true
end
