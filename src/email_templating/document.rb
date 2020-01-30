require_relative 'hacksoc_render'
require_relative 'section'

module LambdaTool
  module EmailTemplating
    # A document with any number of sections.
    Document = Struct.new('Document', :sections) do
      # Creates a Document instance from the markup language described in README.
      def self.from_text(text)
        sections = []

        current_title = nil
        current_body = ""
        text.split("\n").each do |line|
          # If we get a new section title, use the current title and body to
          # instantiate a Section, then set the section title and reset the body
          if /^%(.+)$/ === line
            next_section_title = $1.strip

            sections << Section.new(current_title, current_body) unless current_title.nil?
            current_title = next_section_title
            current_body = ""
          else
            current_body += "#{line}\n"
          end
        end

        # Add the final section
        # (It was never added to the sections array because no section followed it)
        sections << Section.new(current_title, current_body)

        Document.new(sections)
      end

      # Renders the document into HTML.
      def render
        markdown = Redcarpet::Markdown.new(HackSocRender.new)
        TemplateManager.before + sections.map(&:render).inject(:+) + TemplateManager.after
      end
    end
  end
end
