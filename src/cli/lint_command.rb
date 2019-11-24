require 'rainbow/refinement'
using Rainbow
require 'hunspell'

module HSE
  module CLI
    LintCommand = Command.new('lint', 'Check for mistakes', '(input | \'latest\')', 1) do |input, _|
      input_filepath = arg_to_filepath(input)
      
      # Spellcheck with Hunspell
      contents = File.read(input_filepath)
      hunspell = Hunspell.new('res/en_GB.aff', 'res/en_GB.dic')
      mispelled_words = contents
        .gsub(/\[.+\]\(.+\)/, '\1') # Substitute links with just their text
        .gsub(/\d{2}(st|nd|th|rd)/, '') # Remove ordinals
        .scan(/[A-Za-z][A-Za-z0-9\-]+/)
        .select { |word| !hunspell.spellcheck(word) && !LINT_CUSTOM_WORDS.include?(word) }
        .uniq

      if mispelled_words.any?
        puts "Lint warning: ".yellow.bold + "It looks like there are some " + "misspelled words".yellow + " in your Markdown."
        mispelled_words.each do |word|
          puts "  " + word.blue.bold + (" - did you mean: " + hunspell.suggest(word).join(', ')).black.bright
        end
      end
    end
  end
end
