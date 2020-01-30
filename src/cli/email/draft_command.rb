require 'net/imap'

module LambdaTool
  module CLI
    module Email
      DraftCommand = Command.new('draft', 'Save an email to the remote account as a draft', '(input | \'latest\')', 1) do |input, _|
        input_filepath = arg_to_filepath(input)
        content = LambdaTool::EmailTemplating::Document.from_text(File.read(input_filepath)).render

        imap = Net::IMAP.new('imap.gmail.com', 993, true)
        imap.authenticate('LOGIN', 'aaron.christiansen@hacksoc.org', '###')
        p imap.list('' '*')
      end
    end
  end
end