Pod::Spec.new do |s|
  s.name = "LKAlertView"
  s.version = "1.3.3"
  s.summary = "A similar system alertView  framework for Apple platforms"
  s.homepage = "https://github.com/fanlilinSaber/LKAlertView"
  s.license = { type: 'MIT', file: 'LICENSE' }
  s.authors = { "Fan Li Lin" => '824589131.com' }
  s.platform = :ios, "9.0"
  s.requires_arc = true
  s.source = { :git => 'https://github.com/fanlilinSaber/LKAlertView.git', :tag => "v#{s.version}" }
  s.source_files = "LKAlertView/*.{h,m}"
end
