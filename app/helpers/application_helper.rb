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

    text.split("\n").each do |line|
      if code
        if line =~ /^%\/code\s*$/
          result << if lang
                      CodeRay.scan(code, lang.downcase.to_sym).div
                    else
                      "<div class=\"code\"><pre>#{code}</pre></div>"
                    end
          code = lang = nil
        else
          code << line << "\n"
        end
      else
        if line =~ /^%code\b/
          if line =~ /\s+lang(?:uage)?=(\w+)/
            lang = $1
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
