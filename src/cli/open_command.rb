require 'rainbow/refinement'
using Rainbow

module HSE
  module CLI
    OpenCommand = Command.new('open', 'Build an email and open it in Firefox', '(input | \'latest\')', 1) do |input|
      BuildCommand.run(input)

      filepath = arg_to_filepath(ARGV[1], :html)
      fork { `firefox #{filepath}` }

      puts "Opened ".green + filepath
    end
  end
end
