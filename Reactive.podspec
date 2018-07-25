Pod::Spec.new do |s|
		s.name 				= "Reactive"
		s.version 			= "1.0.0"
		s.summary         	= "Sort description of 'Reactive' framework"
	    s.homepage        	= "https://github.com/amine2233/Reactive"
	    s.license           = { type: 'MIT', file: 'LICENSE' }
	    s.author            = { 'Amine Bensalah' => 'amine.bensalah@outlook.com' }
	    s.ios.deployment_target = '9.0'
	    s.osx.deployment_target = '10.11'
	    s.tvos.deployment_target = '9.0'
	    s.watchos.deployment_target = '2.0'
	    s.requires_arc = true
	    s.source            = { :git => "https://github.com/amine2233/Reactive.git", :tag => s.version.to_s }
	    s.source_files      = "Sources/**/*.swift"
	    s.pod_target_xcconfig = {
    		'SWIFT_VERSION' => '4.1'
  		}
  		s.swift_version = '4.1'
  		s.module_name = s.name
	end
