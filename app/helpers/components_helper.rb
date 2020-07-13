module ComponentsHelper
  # returns the mini layout  divs ---  The menu that attaches an component to a block
  def make_mini_layout
    theme = @skin.base_theme
    width = theme.layout['width'] || 500

    content_for :stylesheets, stylesheet_link_tag('mini_layout')
    divs = "<div id='mini_layout' style='width: #{width}px'>"

    theme.layout['placeholders'].map do |placeholders|
      divs += "<div class='mini_level' style='height:#{placeholders['height'] || 25}px'>"
      divs += make_placeholders_divs(theme, placeholders, width)
      divs += '</div>'
    end

    divs += '</div>'
  end

  def render_component_icon(compo)
    return '' if compo.raw_component[:icon].blank?

    if compo.raw_component[:icon].match(/^fa\|/)
      fa_icon(compo.raw_component[:icon].gsub('fa|', ''))
    elsif compo.raw_component[:icon].match(/^flag\|/)
      ''#flag(compo.raw_component[:icon].gsub('flag|', ''))
    else
      icon(compo.raw_component[:icon])
    end
  end

  def list_component(compo, leftout = false)
    exceptions = ['show']
    exceptions << 'edit' unless component_is_available(compo.name)
    components_html = '<li '
    components_html << "id='sort_sites_component_#{compo.id }' " unless leftout
    nickname = compo.alias.present? ? compo.alias : compo.default_alias
    component_icon = render_component_icon(compo)
    component_title = "#{t("components.#{compo.name}.name")} #{"- #{nickname}" if nickname.present?}"
    if compo.is_group?
      components_html << "class='component-#{ compo.name } "
    else
      components_html << "class='component "
    end
    components_html << "#{'disabled' unless component_is_available(compo.name)} #{compo.publish ? '' : 'deactivated'}' data-place='#{compo.place_holder}'>
      <div class=\"component-ctrl\">
        #{ "<span class='handle'>#{image_tag('drag.png')}</span>" if check_permission(Sites::Admin::ComponentsController, 'sort') and !leftout }
        <span class='widget-name'>
          #{ toggle_field(compo, 'publish', 'toggle', controller: :components, skin_id: compo.skin_id, remote: true, class: 'toggle-component') }
          #{if check_permission(Sites::Admin::ComponentsController, 'edit')
                link_to("#{component_icon} #{component_title} #{content_tag(:span, icon(:edit), class: 'oh-c-i')}".html_safe, edit_site_admin_skin_component_path(compo.skin_id, compo.id), class: 'widget-edit')
            else
                component_title
            end}
        </span>
        <div class=\"pull-right actions\" style='min-width: 46px'>
          #{link_to(image_tag('add-row-w.svg'), new_site_admin_skin_component_path(compo.skin_id, placeholder: compo.id), class: 'btn btn-success btn-sm add-subitem', title: t('.new_child_component')) if compo.is_group? && check_permission(Sites::Admin::ComponentsController, [:new]) && !leftout}
          #{render_dropdown_menu do
              [
                (link_to(fa_icon('clone', text: t('clone')), clone_site_admin_skin_component_path(compo.skin_id, compo.id), method: :post, data: {disable_with: t('.cloning')}) if test_permission(:components, :clone)),
                make_menu(compo, except: exceptions, with_text: true, controller: Sites::Admin::ComponentsController, params: {skin_id: compo.skin_id}),
                (link_to(icon(:remove, text: t('.remove_group')), site_admin_skin_component_path(compo.skin_id, compo.id, del_group: true), title: t('.remove_group_hint'), method: :delete, data: {confirm: t('.are_you_sure_group_del', alias: compo.alias)}) if compo.is_group? && check_permission(Sites::Admin::ComponentsController, 'destroy') )
              ].compact.join.html_safe
            end}
        </div>
      </div>"
    if compo.is_group?
      components_per_group = @components.select { |comp| comp.place_holder.to_i == compo.id }
      @components = @components - components_per_group
      components_html << "<div><ul class=\"order-list\" data-place=\"#{compo.id}\">"
      components_per_group.each do |comp|
        component = Weby::Components.factory(comp)
        components_html << list_component(component, leftout)
      end
      components_html << '</ul></div>'
    end
    components_html << '</li>'
    components_html.html_safe
  end

  # Search for the existing components ordering by the I18N name
  def available_components_sorted
    options = { 'Weby' => components_as_options(Weby::Components.components(:weby)) }
    if (theme_templates = @skin.base_theme&.components_templates).present?
      options['Templates Weby'] = theme_templates.map do |name, _opt|
        [t("components.#{name}.name").strip, "components_template|#{name}"]
      end.sort{ |a, b| a[0] <=> b[0] }
    end

    current_site.active_extensions.each do |extension|
      extension_components = components_as_options(Weby::Components.components(extension.name.to_sym))
      options[t("extensions.#{extension.name}.name")] = extension_components if extension_components.any?
    end

    options
  end

  private
  def components_as_options(components)
    components.map { |comp, _opt| [t("components.#{comp}.name").strip, comp.to_s] }.sort! { |a, b| a[0] <=> b[0] }
  end

  # Generate the mini-layout view so  the user can choose the placeholder
  def make_placeholders_divs(theme, placeholders, width)
    divs = ''
    placeholders['names'].map do |name|
      divs += "<div
                  id='mini_#{name}'
                  class='hover'
                  style='width:#{ if placeholders['widths'].nil?
                                    ((width / placeholders['names'].size).to_s + 'px')
                                  else
                                    (placeholders['widths'][placeholders['names'].index(name)].to_s + '%')
                                  end };
                   height:#{placeholders['height'] || 25}px;'>
               #{t("themes.#{theme.name}.placeholders.#{name}")}  </div>"
    end
    divs
  end
end
