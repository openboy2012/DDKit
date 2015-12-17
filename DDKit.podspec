Pod::Spec.new do |s|
s.name     = 'DDKit'
s.version  = '0.1'
s.license  = 'MIT'
s.summary  = 'The tools about the share kit、oauth login and payment kit.'
s.homepage = 'https://github.com/openboy2012/DDKit.git'
s.author   = { 'DeJohn Dong' => 'dongjia_9251@126.com' }
s.source   = { :git => 'https://github.com/openboy2012/ddkit.git',:tag=>s.version.to_s}
s.ios.deployment_target = '6.0'
s.requires_arc = true
s.source_files = 'Classes/DDKitManager.{h,m}'
s.public_header_files = 'Classes/DDKitManager.h'
s.subspec 'WX' do |ss|
 ss.source_files = 'Classes/Vender/WX/WXApi.h','Classes/Vender/WX/WXApiObject.h','Classes/Vender/WX/WechatAuthSDK.h'
 ss.vendored_libraries = 'Classes/Vender/WX/libWeChatSDK.a'
 ss.libraries = 'z','sqlite3'
 ss.framework = 'SystemConfiguration'
end
s.subspec 'QQ' do |ss|
 ss.source_files = 'Classes/Vender/QQ/TencentOpenAPI.framework/Headers/*.h'
 ss.public_header_files = 'Classes/Vender/QQ/TencentOpenAPI.framework/Headers/*.h'
 ss.resource = 'Classes/Vender/QQ/TencentOpenApi_IOS_Bundle.bundle'
 ss.vendored_frameworks = 'Classes/Vender/QQ/TencentOpenAPI.framework'
 ss.libraries = 'stdc++','z','sqlite3','iconv'
 ss.frameworks = 'Security','CoreGraphics','SystemConfiguration','CoreTelephony'
end
s.subspec 'OpenSSL' do |ss|
 ss.source_files = 'Classes/Vender/openssl/headers/*.h'
 ss.vendored_libraries = 'Classes/Vender/openssl/libcrypto.a','Classes/Vender/openssl/libssl.a'
end
s.subspec 'AlipaySDK' do |ss|
 ss.dependency 'DDKit/OpenSSL'

 ss.source_files = 'Classes/Vender/AlipayUtil/*.{h,m}', 'Classes/Vender/Alipay/AlipaySDK.framework/Headers/*.h'
 ss.public_header_files = 'Classes/Vender/Alipay/AlipaySDK.framework/Headers/*.h'
 ss.vendored_frameworks = 'Classes/Vender/Alipay/AlipaySDK.framework'
 ss.resource = 'Classes/Vender/Alipay/AlipaySDK.bundle'
 ss.libraries = 'z','sqlite3'
 ss.framework = 'SystemConfiguration'
end
s.subspec 'DDPaymentKit' do |ss|
 ss.dependency 'DDKit/AlipaySDK'
 ss.dependency 'DDKit/WX'
 ss.dependency 'DDCategory', '~> 0.4'

 ss.source_files = 'Classes/DDPaymentKit.{h,m}'
end
s.subspec 'DDShareKit' do |ss|
 ss.dependency 'DDKit/WX'
 ss.dependency 'DDKit/QQ'
 ss.dependency 'DDCategory', '~> 0.4'
 ss.dependency 'WeiboSDK', '~> 3.1.3'

 ss.resources = 'Classes/DDKit_iOS_Bundle.bundle'
 ss.source_files = 'Classes/DDShareKit.{h,m}','Classes/DDShareItem.{h,m}'
end
s.subspec 'DDOAuthKit' do |ss|
 ss.dependency 'DDKit/AlipaySDK'
 ss.dependency 'DDKit/WX'
 ss.dependency 'DDKit/QQ'
 ss.dependency 'DDCategory', '~> 0.4'
 ss.dependency 'WeiboSDK', '~> 3.1.3'

 ss.source_files = 'Classes/DDOAuthKit.{h,m}'
end


end
