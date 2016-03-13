Pod::Spec.new do |s|
  s.name         = "ASIACheckmarkView"
  s.version      = "1.0.1"
  s.summary      = "Beatiful customizable morphing checkmark button - animation between states with optional spinning intermediate state."
  s.description  = "Customizable checkmark button view. Allows to easily animate between states, with optional intermediate Spinning state - if you want to beautifully morph betweeen two states, but need to wait for API in between. Clean and moder look, along with being easy-to-use."
  s.homepage     = "https://github.com/amichnia/ASIACheckmarkView"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Andrzej Michnia" => "amichnia@gmail.com" }
  s.platform     = :ios, '8.0'
  s.source       = { :git => "https://github.com/amichnia/ASIACheckmarkView.git", :tag => "1.0.1" }
  s.source_files  = 'Sources'
  s.requires_arc = true
end
