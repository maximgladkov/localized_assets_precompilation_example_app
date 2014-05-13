module Sprockets
  module Helpers
    module RailsHelper
      def asset_prefix
        Rails.env.development? ? "/assets" : "/assets/#{ I18n.locale }"
      end

      alias_method :asset_path_without_locale, :asset_path
      def asset_path(source, options = {})
        asset_path = asset_path_without_locale(source, options)
        if asset_path =~ /\?/
          "#{ asset_path }&locale=#{ I18n.locale }&t=#{ Time.now.to_i }"
        else
          "#{ asset_path }?locale=#{ I18n.locale }&t=#{ Time.now.to_i }"
        end
      end
      alias_method :path_to_asset, :asset_path
    end
  end
end

module Sprockets
  class StaticCompiler

    alias_method :compile_without_manifest, :compile
    def compile(*paths)
      I18n.available_locales.each do |locale|
        env.logger.info "Compiling assets for #{ locale.upcase } locale..."

        I18n.locale = locale

        manifest = Sprockets::Manifest.new(env, target)
        manifest.compile *paths
      end
    end
  end

  class Manifest
    def dir
      Rails.env.development? ? @dir : "#{ @dir }/#{ I18n.locale }"
    end
  end

  class Base
    def cache_key_for(path, options)
      "#{path}:#{I18n.locale}:#{options[:bundle] ? '1' : '0'}"
    end
  end

end