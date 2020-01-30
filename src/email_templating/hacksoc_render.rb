module LambdaTool
  module EmailTemplating
    # Custom Redcarpet renderer with special <hr> styles.
    class HackSocRender < Redcarpet::Render::HTML
      def hrule
        %(<hr style="margin: 5px 20px 5px 20px; height: 1px; border: none; background-color: #CCC;" />)
      end
    end
  end
end
