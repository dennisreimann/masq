module Masq
  class InfoController < BaseController
    # The yadis discovery header tells incoming OpenID
    # requests where to find the server endpoint.
    def index
      response.headers['X-XRDS-Location'] = server_url(:format => :xrds, :protocol => scheme)
    end

    # This page is to prevent phishing attacks. It should
    # not contain any links, the user has to navigate to
    # the right login page manually.
    def safe_login
      if not Masq::Engine.config.masq.include? 'protect_phishing' or Masq::Engine.config.masq['protect_phishing']
        render :layout => false
      else
        redirect_to login_url
      end
    end

    def help
    end
  end
end
