Pod::Spec.new do |s|
  s.name                   = 'Kagome'
  s.module_name            = 'Kagome'
  s.version                = '0.1.1'
  s.summary                = 'Apple Music inspired modal transition pushing the source controller backwards while overlaying the modal ontop.'
  s.homepage               = 'https://github.com/pkluz/Kagome'
  s.author                 = { 'Philip Kluz' => 'philip.kluz@gmail.com' }
  s.platform               = :ios, '10.0'
  s.ios.deployment_target  = '10.0'
  s.requires_arc           = true
  s.source                 = { :git => 'https://github.com/pkluz/Kagome.git', :tag => s.version.to_s }
  s.source_files           = 'Kagome/**/*.{h,swift,plist,strings}'
end
