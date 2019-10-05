#!/usr/bin/env ruby

require 'redcarpet'

# Custom Redcarpet renderer with special <hr> styles.
class HackSocRender < Redcarpet::Render::HTML
  def hrule
    %(<hr style="margin: 5px 20px 5px 20px; height: 1px; border: none; background-color: #CCC;" />)
  end
end

# Handles loading section and document templates.
class TemplateManager
  TEMPLATE_DIR = "parts"

  @@template_cache = {}

  # Fetches a template from the directory by its name, using a cached version
  # if available, and caching the template if it was not already cached.
  def self.load_template(name)
    @@template_cache[name] ||= File.read("#{TEMPLATE_DIR}/#{name}")
  rescue Errno::ENOENT
    raise "a template is missing: #{TEMPLATE_DIR}/#{name}"
  end

  # Create method to access the three required templates: after, before and
  # section.
  class << self
    [:after, :before, :section].each do |temp|
      define_method(temp) do
        self.load_template("#{temp}.html")
      end
    end
  end
end

# Represents a section with a plaintext title and Markdown body.
Section = Struct.new('Section', :title, :body) do
  # Renders the section into HTML.
  def render
    markdown = Redcarpet::Markdown.new(HackSocRender.new)
    rendered_body = markdown.render(body)

    TemplateManager.section.gsub("%%BODY%%", rendered_body).gsub("%%TITLE%%", title)
  end
end

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

if ARGV.length != 1 && ARGV.length != 2
  puts "Usage: hsemailmd.rb <input-file> [output-file]"
  exit
end

content = Document.from_text(File.read(ARGV[0])).render
filename = ARGV[1] || "#{ARGV[0].gsub(/(.*)\.([^\/]+)$/, '\1')}.html" # cursed regex to remove file extension
File.write(filename, content)
