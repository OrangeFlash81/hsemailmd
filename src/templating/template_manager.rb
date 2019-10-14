module HSE
  module Templating
    # Handles loading section and document templates.
    class TemplateManager
      TEMPLATE_DIR = "parts"

      @@template_cache = {}

      # Fetches a template from the directory by its name, using a cached version
      # if available, and caching the template if it was not already cached.
      def self.load_template(name)
        @@template_cache[name] ||= File.read("#{TEMPLATE_DIR}/#{name}")
      rescue Errno::ENOENT
        raise "a template is missing: #{TEMPLATE_DIR}/#{name}"
      end

      # Create method to access the three required templates: after, before and
      # section.
      class << self
        [:after, :before, :section].each do |temp|
          define_method(temp) do
            self.load_template("#{temp}.html")
          end
        end
      end
    end
  end
end