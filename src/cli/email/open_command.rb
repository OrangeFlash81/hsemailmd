require 'rainbow/refinement'
using Rainbow

module LambdaTool
  module CLI
    module Email
      OpenCommand = Command.new('email', 'open', 'Build an email and open it in Firefox', '(input | \'latest\')', 1) do |input|
        BuildCommand.run(input)

        filepath = arg_to_filepath(input[0], :html)
        fork { `firefox #{filepath}` }

        puts "Opened ".green + filepath
      end
    end
  end
end
