Pod::Spec.new do |spec|
  spec.name 			= 'DJRangeGauge'
  spec.version 			= '0.0.1'
  spec.summary			= 'Provides a gauge control for ios'
  spec.platform 		= :ios
  spec.license			= 'MIT'
  spec.ios.deployment_target 	= '9.0'
  spec.authors			= 'David Jedeikin'
  spec.homepage			= 'https://github.com/davidjed/DJRangeGauge'
  spec.source_files 		= 'DJRangeGauge/DJRangeGauge.*'  
  spec.source			= { :git => 'https://github.com/davidjed/DJRangeGauge.git', :tag => 'v0.0.1' }
  spec.framework  = 'UIKit'
  spec.requires_arc = true

end
