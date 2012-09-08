require 'openid'
require 'openid/consumer/discovery'
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/extensions/ax'
require 'yubikey' if Masq::Engine.config.masq['can_use_yubikey']