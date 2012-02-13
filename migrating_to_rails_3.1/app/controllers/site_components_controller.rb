class SiteComponentsController < ApplicationController
  layout :choose_layout
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml, :js
  def index
    @site_components = @site.site_components
  end

  def show
    @site_component = @site.site_components.find(params[:id])
  end

  def new
    @site_component = SiteComponent.new
  end

  def edit
    @site_component = @site.site_components.find(params[:id])
  end

  def create
    @site_component = SiteComponent.new(params[:site_component])

    if @site_component.save
      # TODO colocar tradução na mensagem de sucesso
      redirect_to(site_site_components_url, :notice => 'Componente criado com sucesso.')
    else
      render :action => "new"
    end
  end

  def update
    @site_component = @site.site_components.find(params[:id])

    if @site_component.update_attributes(params[:site_component])
      # TODO colocar tradução na mensagem de sucesso
      redirect_to(site_site_components_url, :notice => 'Componente atualizado com sucesso.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @site_component = SiteComponent.find(params[:id])
    @site_component.destroy

    redirect_to(site_site_components_url)
  end
  
  def sort
    @site_components = @site.site_components

    params['sort_sites_component'] ||= []
    params['sort_sites_component'].to_a.each do |p|
      site_component = SiteComponent.find(p)
      site_component.position = (params['sort_sites_component'].index(p) + 1)
      site_component.save
    end
  end
  
  def toggle_field
    @site_component = SiteComponent.find(params[:id])
    if params[:field] 
      if @site_component.update_attributes("#{params[:field]}" => (@site_component[params[:field]] == 0 or not @site_component[params[:field]] ? true : false))
        flash[:notice] = t"successfully_updated"
      else
        flash[:notice] = t"error_updating_object"
      end
    end
    redirect_back_or_default site_site_components_path(@site)
  end
end