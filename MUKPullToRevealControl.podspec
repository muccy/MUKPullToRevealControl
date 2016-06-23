Pod::Spec.new do |s|
  s.name             = "MUKPullToRevealControl"
  s.version          = "1.1.1"
  s.summary          = "Pull to reveal and pull to refresh for every UIScrollView."
  s.description      = <<-DESC
                        MUKPullToRevealControl, when added to a UIScrollView instance, places itself at top
                        and can be pulled to be revealed.
                        It could be subclassed to achieve pull to refresh controls. MUKCirclePullToRefreshControl
                        is an example.
                       DESC
  s.homepage         = "https://github.com/muccy/MUKPullToRevealControl"
  s.license          = 'MIT'
  s.author           = { "Marco Muccinelli" => "muccymac@gmail.com" }
  s.source           = { :git => "https://github.com/muccy/MUKPullToRevealControl.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Classes/*.{h,m}'
  s.compiler_flags  = '-Wdocumentation'
  
  s.dependency  'KVOController', '~> 1.0.3'
end
