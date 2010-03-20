# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # from acts_as_taggable_on_steroids
  include TagsHelper

  # our own markdown function that support coderay.
  # FIXME: it's ugly.
  def markdown text
    result  = String.new
    code    = nil
    lang    = nil
    opts    = nil

    text.split("\n").each do |line|
      if code
        if line =~ /^%\/code\s*$/
          result << if lang
                      tokens = CodeRay.scan(code, lang.downcase.to_sym)
                      tokens.div(opts)
                    else
                      "<div class=\"code\"><pre>#{h code}</pre></div>"
                    end
          code = lang = nil
        else
          code << line << "\n"
        end
      else
        if line =~ /^%code\b/
          opts = Hash.new
          if line =~ /\s+lang(?:uage)?=(\w+)\b/
            lang = $1
          end
          if line =~ /\s+(?:ln|line_numbers)=(\w+)\b/
            if %[table inline list].include?($1)
              opts[:line_numbers] = $1.to_sym
            end
          end
          if line =~ /\s+(?:tw|tab_width)=(\d+)\b/
            opts[:tab_width] = $1.to_i
          end
          code = String.new
        else
          result << line << "\n"
        end
      end
    end
    BlueCloth.new(result).to_html
  end

  # disable html support in mkd
  def markdown_no_html text
    BlueCloth.new(text, :filter_html).to_html
  end

  # hack for atom
  def comment_url comment
    post_url comment.post, :anchor => "comment_#{comment.id}"
  end

  # guess the <title> of the page.
  def html_title
    if @post
      @post.title
    elsif @page
      @page.title
    end
  end
end
