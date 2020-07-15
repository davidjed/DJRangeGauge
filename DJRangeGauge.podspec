Pod::Spec.new do |spec|
  spec.name 			  = 'DJRangeGauge'
  spec.version 			= '0.0.3'
  spec.summary			= 'Provides a dual-adjustable ios gauge control'
  spec.platform 		= :ios
  spec.license			= 'MIT'
  spec.ios.deployment_target 	= '12.0'
  spec.authors			= 'David Jedeikin'
  spec.homepage			= 'https://github.com/davidjed/DJRangeGauge'
  spec.source_files = 'DJRangeGauge/DJRangeGauge.*'  
  spec.source			  = { :git => 'https://github.com/davidjed/DJRangeGauge.git', :tag => 'v0.0.3' }
  spec.framework    = 'UIKit'
  spec.requires_arc = true
  spec.swift_version = '5.0'

end
