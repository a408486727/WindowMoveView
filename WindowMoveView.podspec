Pod::Spec.new do |s|

  s.name         = "WindowMoveView"
  s.version      = "0.9"
  s.summary      = "Container can move in window"

  s.description  = <<-DESC
                   DESC

  s.homepage     = "https://github.com/a408486727/WindowMoveView"
  s.screenshots  = ""

  s.license      = 'MIT'
  
  s.authors     = {"xuchuanqi" => "a408486727@163.com"}

  s.platform     = :ios, "8.0"
  s.ios.deployment_target = '8.0'
  s.source       = { :git => "https://github.com/a408486727/WindowMoveView.git", :tag => s.version.to_s }

  s.source_files = 'WindowMoveView/*.{h,m}'

  #s.ios.exclude_files = 'Classes/osx'
  #s.osx.exclude_files = 'Classes/ios'
  s.public_header_files = 'WindowMoveView/*.h'

  #s.resources = 'Assets/*.png' , 'Classes/ios/*.{xib}'
  
  #s.frameworks = ''

  s.requires_arc = true

  s.dependency 'Aspects'

end
