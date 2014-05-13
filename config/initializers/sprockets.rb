module Sprockets
  module Helpers
    module RailsHelper

      # add locale to asset_prefix, if assets compiled
      def asset_prefix
        if Rails.env.development?
          Rails.application.config.assets.prefix
        else
          "#{ Rails.application.config.assets.prefix }/#{ I18n.locale }"
        end
      end

      alias_method :asset_path_without_locale, :asset_path

      # prevent asset from caching by adding timestamp
      def asset_path(source, options = {})
        asset_path = asset_path_without_locale(source, options)
        separator = asset_path =~ /\?/ ? '&' : '?'
        
        "#{ asset_path }#{ separator }t=#{ Time.now.to_i }"
      end
      
      alias_method :path_to_asset, :asset_path

    end
  end
end

module Sprockets
  class StaticCompiler

    alias_method :compile_without_manifest, :compile

    # run compile for each available locale
    def compile(*paths)
      I18n.available_locales.each do |locale|
        env.logger.info "Compiling assets for #{ locale.upcase } locale..."

        I18n.locale = locale

        manifest = Sprockets::Manifest.new(env, target)
        manifest.compile *paths
      end

      I18n.locale = I18n.default_locale
    end

  end

  class Manifest

    # add locale to assets' dir
    def dir
      Rails.env.development? ? @dir : "#{ @dir }/#{ I18n.locale }"
    end
    
  end

  class Base

    # add locale to assets cache key
    def cache_key_for(path, options)
      "#{path}:#{I18n.locale}:#{options[:bundle] ? '1' : '0'}"
    end
  
  end

end