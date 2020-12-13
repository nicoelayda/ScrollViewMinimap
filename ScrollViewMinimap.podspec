Pod::Spec.new do |spec|

    spec.name         = "ScrollViewMinimap"
    spec.version      = "1.0.0"
    spec.summary      = "Custom control for adding minimap functionality to UIScrollView"
    spec.description  = <<-DESC
                        ScrollViewMinimap is a control for adding minimap functionality to UIScrollView.
                        
                        Features
                         * Automatic sizing based on scroll view's content view.
                         * Automatic thumbnail generation.
                         * Customisable highlight rect.
                     DESC
    spec.homepage     = "https://github.com/nicoelayda/ScrollViewMinimap"
    spec.license      = { :type => "MIT", :file => "LICENSE" }
  
    spec.author             = { "Dominic Elayda" => "nico@elayda.com" }
    spec.social_media_url   = "https://twitter.com/nicoelayda"
  
    spec.platform     = :ios, "12.0"
  
    spec.source       = { :git => "https://github.com/nicoelayda/ScrollViewMinimap.git", :tag => "v#{spec.version}" }
    spec.source_files  = "Sources/**/*.swift"

    spec.resource_bundles = { "ScrollViewMinimap-Assets" => ["Sources/ScrollViewMinimap/Assets.xcassets"] }

    spec.swift_versions = ["5.0", "5.1", "5.2", "5.3"]
  
  end
  