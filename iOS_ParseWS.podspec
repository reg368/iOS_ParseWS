Pod::Spec.new do |spec|
  spec.name         = 'iOS_ParseWS'
  spec.version      = '1.0.1'
  spec.license      = 'MIT'
  spec.homepage     = 'https://github.com/reg368/iOS_ParseWS'
  spec.summary      = 'Provide two type of method fetch Json format data from web service. NSURLSession Base API'
  spec.source       = { :git => 'https://github.com/reg368/iOS_ParseWS.git', :tag => 'master' }
  spec.source_files = 'XMLDictionary.h','XMLDictionary.m','ParseWS.h','ParseWS.m'
  spec.author       = { 'reg368' => 'reg368@gmail.com' }
  spec.platform = :ios, '8.0'

end