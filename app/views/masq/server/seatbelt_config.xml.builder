xml.instruct!
xml.opConfig(:version => '1.0', :serverIdentifier => endpoint_url) do
  xml.configRevision('2008090801')
  xml.title(Masq::Engine.config.masq['name'])
  xml.serverIdentifier(endpoint_url)
  xml.opDomain(Masq::Engine.config.masq['host'])
  xml.opCertCommonName(Masq::Engine.config.masq['ssl_certificate_common_name']) if Masq::Engine.config.masq['use_ssl']
  xml.opCertSHA1Hash(Masq::Engine.config.masq['ssl_certificate_sha1']) if Masq::Engine.config.masq['use_ssl']
  xml.loginUrl(login_url(:protocol => scheme))
  xml.welcomeUrl(root_url(:protocol => scheme))
  xml.loginStateUrl(seatbelt_state_url(:protocol => scheme, :format => :xml))
  xml.settingsIconUrl("#{root_url(:protocol => scheme)}images/seatbelt_icon.png")
  xml.toolbarGrayIconUrl("#{root_url(:protocol => scheme)}images/seatbelt_icon_gray.png")
  xml.toolbarHighIconUrl("#{root_url(:protocol => scheme)}images/seatbelt_icon_high.png")
  xml.toolbarGrayBackground('#EBEBEB')
  xml.toolbarGrayBorder('#666666')
  xml.toolbarGrayText('#666666')
  xml.toolbarLoginBackground('#EBEBEB')
  xml.toolbarLoginBorder('#2B802B')
  xml.toolbarLoginText('#2B802B')
  xml.toolbarHighBackground('#EBEBEB')
  xml.toolbarHighBorder('#F50012')
  xml.toolbarHighText('#F50012')
end
