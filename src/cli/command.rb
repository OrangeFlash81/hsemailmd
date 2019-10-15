require 'rainbow/refinement'
using Rainbow

module HSE
  module CLI
    # Represents a command on the CLI.
    class Command
      attr_reader :name, :description, :usage, :expected_args, :action

      def initialize(name, description, usage, expected_args, &action)
        @name = name
        @description = description
        @usage = usage
        @expected_args = expected_args
        @action = action
      end

      # Prints a message and terminates with an error code.
      def die(x=nil)
        puts x
        exit 1
      end

      def run(args)
        die "Usage: hse #{name} #{usage}" unless expected_args == args.length || (expected_args.is_a?(Range) && expected_args.include?(args.length))

        instance_exec args, &action
      end

      def help_line
        "  - #{name.blue.bright} - #{description}"
      end

      def input(validation_rules = nil)
        loop do
          print "> ".black.bright
          result = STDIN.gets.chomp

          return result unless validation_rules

          # TODO: this next does not next the right thing
          all_ok = true
          validation_rules.each do |desc, rule|
            unless rule.(result)
              puts desc.red 
              all_ok = false
            end
          end

          return result if all_ok
        end
      end

      def parse_date(date_str)
        # Parse YYYY-MM-DD and DD-MM-YYYY, with - or / as separators
        case date_str
        when /^(\d{2})(?:-|\/)(\d{2})(?:-|\/)(\d{4})$/
          Date.new($3.to_i, $2.to_i, $1.to_i)
        when /^(\d{4})(?:-|\/)(\d{2})(?:-|\/)(\d{2})$/
          Date.new($1.to_i, $2.to_i, $3.to_i)
        else
          raise 'invalid date format'
        end
      end

      # Converts a given command-line file path to item inside "/emails".
      def arg_to_filepath(x)
        if x == 'latest'
          # TODO: handle multiple emails with the same date
          "emails/#{Dir.entries('emails').sort.last}"
        elsif x.include?('.')
          # If the path contains a dot, assume it's a name
          x
        else
          "emails/#{x}.md"
        end
      end
    end
  end
end