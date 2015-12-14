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
s.resources = 'DDKit/DDKit_iOS_Bundle.bundle'
s.subspec 'WX' do |ss|
 ss.source_files = 'DDKit/Vender/WX/WXApi.h','DDKit/Vender/WX/WXApiObject.h','DDKit/Vender/WX/WechatAuthSDK.h'
 ss.vendored_libraries = 'DDKit/Vender/WX/libWeChatSDK.a'
 ss.libraries = 'z','sqlite3'
 ss.framework = 'SystemConfiguration'
end
s.subspec 'QQ' do |ss|
 ss.source_files = 'DDKit/Vender/QQ/TencentOpenAPI.framework/Headers/*.h'
 ss.public_header_files = 'DDKit/Vender/QQ/TencentOpenAPI.framework/Headers/*h'
 ss.resource = 'DDKit/Vender/QQ/TencentOpenApi_IOS_Bundle.bundle'
 ss.vendored_frameworks = 'DDKit/Vender/QQ/TencentOpenAPI.framework'
 ss.libraries = 'stdc++','z','sqlite3','iconv'
 ss.frameworks = 'Security','CoreGraphics','SystemConfiguration','CoreTelephony'
end
s.subspec 'OpenSSL' do |ss|
 ss.source_files = 'DDKit/Vender/openssl/headers/*.h'
 ss.vendored_libraries = 'DDKit/Vender/openssl/libcrypto.a','DDKit/Vender/openssl/libssl.a'
end
s.subspec 'AlipaySDK' do |ss|
 ss.dependency 'DDKit/OpenSSL'

 ss.source_files = 'DDKit/Vender/AlipayUtil/*.{h,m}'
 ss.public_header_files = 'DDKit/Vender/Alipay/AlipaySDK.framework/Headers/*h'
 ss.vendored_frameworks = 'DDKit/Vender/Alipay/AlipaySDK.framework'
 ss.resource = 'DDKit/Vender/Alipay/AlipaySDK.bundle'
 ss.libraries = 'z','sqlite3'
 ss.framework = 'SystemConfiguration'
end
s.subspec 'DDPaymentKit' do |ss|
 ss.dependency 'DDKit/AlipaySDK'
 ss.dependency 'DDKit/WX'
 ss.dependency 'DDCategory', '~> 0.4'

 ss.source_files = 'DDKit/DDPaymentKit.{h,m}'
end
s.subspec 'DDShareKit' do |ss|
 ss.dependency 'DDKit/WX'
 ss.dependency 'DDKit/QQ'
 ss.dependency 'DDCategory', '~> 0.4'
 ss.dependency 'WeiboSDK', '~> 3.1.3'

ss.source_files = 'DDKit/DDShareKit.{h,m}','DDKit/DDShareItem.{h,m}'
end
s.subspec 'DDOAuthKit' do |ss|
 ss.dependency 'DDKit/AlipaySDK'
 ss.dependency 'DDKit/WX'
 ss.dependency 'DDKit/QQ'
 ss.dependency 'DDCategory', '~> 0.4'
 ss.dependency 'WeiboSDK', '~> 3.1.3'

 ss.source_files = 'DDKit/DDOAuthKit.{h,m}'
end

s.source_files = 'DDKit/DDKitManager.{h,m}'

end
