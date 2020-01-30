module LambdaTool
  module EmailTemplating
    # Represents a section with a plaintext title and Markdown body.
    Section = Struct.new('Section', :title, :body) do
      # Renders the section into HTML.
      def render
        markdown = Redcarpet::Markdown.new(HackSocRender.new)
        rendered_body = markdown.render(body)

        TemplateManager.section.gsub("%%BODY%%", rendered_body).gsub("%%TITLE%%", title)
      end
    end
  end
end
