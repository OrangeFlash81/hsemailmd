require 'rainbow/refinement'
using Rainbow
require 'json'
require 'ruby-handlebars'

module LambdaTool
  module CLI
    module TalkAd
      JsonCommand = Command.new('talk-ad', 'new', 'Create a talk ad from stdin JSON', '', 0) do
        data = JSON.parse(STDIN.read)
        
        # Check required keys
        %w[title speaker date timeStart timeEnd location abstract speakerImage].each do |key|
          die "missing key #{key}" unless data[key]
        end

        # Compile template
        template_path = File.join(__dir__, 'template.html')
        compiled_template = Handlebars::Handlebars.new.compile(File.read(template_path))
        html = compiled_template.(data)
        output_path = "talk-ads/#{data['date']}-#{data['speaker']}.html".gsub(/\s/, '-').downcase
        File.write(output_path, html)
      end
    end
  end
end