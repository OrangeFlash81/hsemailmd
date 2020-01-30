# This is the HSE configuration file. 
# It's just a Ruby script which is required by the main script, so you can
# write code in here if you want to (for example, custom commands).

# When creating a newsletter, events will have their name overridden if there is
# a key of their original name.
EVENT_NAMES = {
  'Boardgames & Cake' => 'Board Games and Cake'
}

# When creating a newsletter, events will have their description overridden if 
# there is a key of their name. Name replacement with EVENT_NAMES takes place
# first.
EVENT_DESCRIPTIONS = {
  'CoffeeScript' => 'Our weekly social on Hes East; enjoy some lunch and have a good chat.',
  'Board Games and Cake' => "One of HackSoc's oldest traditions, where we play many board games and eat plenty of cake! Members are encouraged to bring their own board games and cake if they enjoy the events.",
  'HackPub' => 'Join us in the Rook and Gaskill and chat to members past and present over a pint (of something non-alcoholic, if you so desire).',
  'Film Night' => 'Come and enjoy a film with fellow HackSoc members! Submit your film suggestions to the [Film Night Portal](https://hacksoc-film-night.herokuapp.com/).'
}

# Custom words which the linter's spell checker specifically allows.
LINT_CUSTOM_WORDS = %w[
  HackSoc RCH Lakehouse
]

# The commands available in the CLI.
COMMANDS = [
  HSE::CLI::NewCommand,
  HSE::CLI::BuildCommand,
  HSE::CLI::LintCommand,
  HSE::CLI::OpenCommand,
]