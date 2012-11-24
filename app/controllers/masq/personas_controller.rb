module Masq
  class PersonasController < BaseController
    before_filter :login_required
    before_filter :store_return_url, :only => [:new, :edit]

    helper_method :persona

    def index
      @personas = current_account.personas

      respond_to do |format|
        format.html
      end
    end

    def create
      respond_to do |format|
        if persona.save!
          flash[:notice] = t(:persona_successfully_created)
          format.html { redirect_back_or_default account_personas_path }
        else
          format.html { render :action => "new" }
        end
      end
    end

    def update
      respond_to do |format|
        if persona.update_attributes(params[:persona])
          flash[:notice] = t(:persona_updated)
          format.html { redirect_back_or_default account_personas_path }
        else
          format.html { render :action => "edit" }
        end
      end
    end

    def destroy
      respond_to do |format|
        begin
          persona.destroy
        rescue Persona::NotDeletable
          flash[:alert] = t(:persona_cannot_be_deleted)
        end
        format.html { redirect_to account_personas_path }
      end
    end

    protected

    def persona
      @persona ||= params[:id].present? ?
        current_account.personas.find(params[:id]) :
        current_account.personas.new(params[:persona])
    end

    def redirect_back_or_default(default)
      case session[:return_to]
      when decide_path then redirect_to decide_path(:persona_id => persona.id)
      else super(default)
      end
    end

    def store_return_url
      store_location(params[:return]) unless params[:return].blank?
    end
  end
end
