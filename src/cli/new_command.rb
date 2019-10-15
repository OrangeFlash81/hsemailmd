require 'rainbow/refinement'
using Rainbow
require 'json'
require 'open-uri'

module HSE
  module CLI
    NewCommand = Command.new('new', 'Create a new Markdown email with calendar events', '', 0) do
      puts "Enter the " + "name".yellow + " of this email, in-this-format."
      name = input([
        ['Please enter a name.',            ->x{ x.strip != '' }],
        ['The name cannot contain spaces.', ->x{ !x.include?(' ') }],
        ['The name cannot contain dots.',   ->x{ !x.include?('.') }]
      ])

      puts "Enter the " + "date when you plan to send this email".yellow + ", YYYY-MM-DD."
      date = input([
        ['Please use the format YYYY-MM-DD.', ->x{ /^\d{4}-\d{2}-\d{2}$/ === x }]
      ])

      puts "Is this a " + "newsletter".yellow + "? (Y/N)"
      is_newsletter_str = input([
        ['Please enter Y or N.', ->x{ %w[N Y].include?(x.upcase) }]
      ])
      is_newsletter = is_newsletter_str.upcase == 'Y'

      path = "emails/#{date}-#{name}.md"
      die "An email with this name and date already exists.".red if File.exist?(path)
      File.write(path, '')
      puts "Email created!".green

      if is_newsletter
        puts "Finding events for the week of #{date}..."
        year, month, day = date.split('-').map(&:to_i)
        date_obj = Date.new(year, month, day)

        events = JSON.parse(open("https://api.hacksoc.org/calendar/events/#{year}/#{month}").read)
        events_this_week = []
        events.each do |event|
          event_day, event_month, event_year = event['when_human']['short_start_date'].split('/').map(&:to_i)
          event_date_obj = Date.new(event_year, event_month, event_day)

          distance = (event_date_obj - date_obj.at_beginning_of_week).to_i
          next unless distance >= 0 && distance < 7

          event_name = EVENT_NAMES[event['summary']] || event['summary']
          event_description = EVENT_DESCRIPTIONS[event_name] || event['description']
          # TODO: use am/pm time
          event_time = event['when_human']['start_time']
          event_weekday = event['when_human']['long_start_date'][0...3]

          events_this_week << \
            "**#{event_name}** - _#{event_time}, #{event_weekday} #{event_day}/#{event_month}_ - _#{event['location']}_\n\n#{event_description}"
        end

        puts "There are #{events_this_week.length} events this week."

        email_contents = <<HERE
% Hello, HackSoc!

XXXXXXXX

% The Calendar

#{events_this_week.join("\n\n---\n\n")}

% And Finally...

Make sure you're in HackSoc's Slack workspace! We have over 100 members, and
it's free to join the conversation, so
[sign up now](https://hacksoc-york.slack.com/)!

If you'd like to become a member of the society, simply 
[sign up here](https://yusu.org/activities/view/hacksoc)! If you
aren't sure yet, we'd love you to come along to any of our events and chat to
us. If you have any questions, get in touch over social media or Slack!

Have a great week,

Aaron 🤖
HERE
        File.write(path, email_contents)
        puts "Added newsletter template!".green
      end
    end
  end
end