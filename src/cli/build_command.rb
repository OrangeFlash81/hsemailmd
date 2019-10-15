require 'rainbow/refinement'
using Rainbow

module HSE
  module CLI
    BuildCommand = Command.new('build', 'Build a Markdown email to HTML', '(input | \'latest\') [output]', 0..2) do    
      input_filepath = arg_to_filepath(ARGV[1])
      content = HSE::Templating::Document.from_text(File.read(input_filepath)).render
      output_filepath = ARGV[2] || "#{input_filepath.gsub(/(.*)\.([^\/]+)$/, '\1')}.html" # cursed regex to remove file extension
      File.write(output_filepath, content)

      puts "Built email ".green + input_filepath + " to ".green + output_filepath
    end
  end
end
