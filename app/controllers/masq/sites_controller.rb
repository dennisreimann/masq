module Masq
  class SitesController < BaseController
    before_filter :login_required
    before_filter :find_personas, :only => [:create, :edit, :update]

    helper_method :site, :persona

    def index
      @sites = current_account.sites.includes(:persona).order(:url)

      respond_to do |format|
        format.html
      end
    end

    def edit
      site.persona = current_account.personas.find(params[:persona_id]) if params[:persona_id]
    end

    def update
      respond_to do |format|
        if site.update_attributes(site_params)
          flash[:notice] = t(:release_policy_for_site_updated)
          format.html { redirect_to edit_account_site_path(site) }
        else
          format.html { render :action => 'edit' }
        end
      end
    end

    def destroy
      site.destroy

      respond_to do |format|
        format.html { redirect_to account_sites_path }
      end
    end

    private

    def site
      @site ||= current_account.sites.find(params[:id])
    end

    def persona
      @persona ||= site.persona
    end

    def find_personas
      @personas = current_account.personas.order(:title)
    end

    def site_params
      params.require(:site).permit!
    end
  end
end
