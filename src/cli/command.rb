require 'rainbow/refinement'
using Rainbow

module HSE
  module CLI
    # Represents a command on the CLI.
    class Command
      attr_reader :name, :description, :usage, :expected_args, :action

      # Creates a new Command instance.
      # @param [String] name The name of this command, as it will be entered
      #   on the command line.
      # @param [String] description A single-line description of what this
      #   command does.
      # @param [String] usage How this command should be used. This is printed
      #   after the name of the command if usage is invalid.
      # @param [Integer, Range] expected_args The number of expected arguments,
      #   either as an exact number or a range.
      # @yieldparam [*String] One argument is passed to the block for each 
      #   argument passed to the command-line invocation.
      def initialize(name, description, usage, expected_args, &action)
        @name = name
        @description = description
        @usage = usage
        @expected_args = expected_args
        @action = action
      end

      # Prints a message and terminates with an error code.
      # @param [String] x (Optional) The string to print.
      def die(x=nil)
        puts x
        exit 1
      end

      # Runs this command, passing the given arguments.
      # @param [Array<String>] args The arguments to pass to the block.
      def run(args)
        die "Usage: hse #{name} #{usage}" unless expected_args == args.length || (expected_args.is_a?(Range) && expected_args.include?(args.length))

        instance_exec args, &action
      end

      # Generates the help line for this command from its name and description.
      # @return [String]
      def help_line
        "  - #{name.blue.bright} - #{description}"
      end

      # Requests input from the user on STDIN. If validation rules are given,
      # input is requested repeatedly until it is valid against those rules.
      # @param [Array<[String, Proc]>] validation_rules (Optional) A set of
      #   rules to run against the input. If they all return true, the input is
      #   accepted and returned. If any return false, their messages are printed
      #   and input will be requested again.
      # @return [String] The accepted input string.
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

      # Parses a date from a variety of a UK formats into a Date object. The 
      # formats YYYY-MM-DD and DD-MM-YYYY are supported, with either - or / as
      # separators.
      # @param [String] date_str The date string to parse.
      # @return [Date] The parsed date.
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
      # @param [String] x The given file path to convert.
      # @param [String, Symbol] format The file extension to use for the path.
      # @return [String] A relative path to an email. This is not guaranteed to
      #   point to a file which actually exists.
      def arg_to_filepath(x, format=:md)
        if x == 'latest'
          # TODO: handle multiple emails with the same date
          email_mds = Dir.entries('emails').select { |x| x.end_with?('.md') }
          latest = email_mds.sort.last
          latest = "#{latest[0...-3]}.#{format}" if format != :md

          result = "emails/#{latest}"
        elsif x.include?('.')
          # If the path contains a dot, assume it's a name
          x
        else
          result = "emails/#{x}.md"
          result = "#{result[0...-3]}.#{format}" if format != :md
          result
        end
      end
    end
  end
end