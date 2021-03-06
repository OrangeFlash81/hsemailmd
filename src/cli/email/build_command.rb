require 'rainbow/refinement'
using Rainbow

module LambdaTool
  module CLI
    module Email
      BuildCommand = Command.new('email', 'build', 'Build a Markdown email to HTML', '(input | \'latest\') [output]', 0..2) do |input, output|
        input_filepath = arg_to_filepath(input)
        content = LambdaTool::EmailTemplating::Document.from_text(File.read(input_filepath)).render
        output_filepath = output || arg_to_filepath(input, :html) # cursed regex to remove file extension
        File.write(output_filepath, content)

        puts "Built email ".green + input_filepath + " to ".green + output_filepath
      end
    end
  end
end
