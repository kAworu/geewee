require 'spec_helper'

describe ApplicationHelper do

  describe :markdown do
    it 'should render mkd' do
      text = "it's strong, are you?"
      helper.markdown("**#{text}**").should == "<p><strong>#{text}</strong></p>"
    end

    it 'should allow html' do
      text     = %{<a onmouseonver="alert('pwned');">XSS &</a>}
      expected = %{<p><a onmouseonver="alert('pwned');">XSS &amp;</a></p>}
      helper.markdown(text).should == expected
    end

    describe '%code tag' do
      it 'should call CodeRay.scan' do
        CodeRay.should_receive(:scan).with("Some Code\n", nil).
          and_return(mock :div => String.new)
        helper.markdown "%code\nSome Code\n%/code"
      end

      it 'should pass the language option to CodeRay' do
        CodeRay.should_receive(:scan).with("Some Code\n", :ruby).
          and_return(mock :div => String.new)
        helper.markdown "%code lang=ruby\nSome Code\n%/code"
      end

      it 'should pass the language option to CodeRay in a case insensitive way' do
        CodeRay.should_receive(:scan).with("Some Code\n", :python).
          and_return(mock :div => String.new)
        helper.markdown "%code lang=pYtHoN\nSome Code\n%/code"
      end

      describe 'CodeRay tokens options' do
        before :each do
          @tokens = mock
          CodeRay.should_receive(:scan).and_return(@tokens)
        end

        it 'should pass the tab_width option to CodeRay tokens' do
          @tokens.should_receive(:div).with(:tab_width => 42).and_return('')
          helper.markdown "%code tab_width=42\nrm -rf /\n%/code"
        end

        it 'should pass the tw option as tab_width to CodeRay tokens' do
          @tokens.should_receive(:div).with(:tab_width => 42).and_return('')
          helper.markdown "%code tw=42\nrm -rf /\n%/code"
        end

        it 'should pass the line_numbers option to CodeRay tokens' do
          @tokens.should_receive(:div).with(:line_numbers => :list).and_return('')
          helper.markdown "%code line_numbers=list\nrm -rf /\n%/code"
        end

        it 'should pass the ln option as line_numbers to CodeRay tokens' do
          @tokens.should_receive(:div).with(:line_numbers => :list).and_return('')
          helper.markdown "%code ln=list\nrm -rf /\n%/code"
        end

        [:table, :inline, :list].each do |ln_opt|
          it "should accept #{ln_opt} as valid options for line_numbers" do
            @tokens.should_receive(:div).with(:line_numbers => ln_opt).and_return('')
            helper.markdown "%code line_numbers=#{ln_opt}\nrm -rf /\n%/code"
          end
        end
      end
    end
  end

  describe :markdown_no_html do
    it 'should render mkd' do
      text = "it's strong, are you?"
      helper.markdown_no_html("**#{text}**").should == "<p><strong>#{text}</strong></p>"
    end

    it 'should escape html' do
      mkd      = %{<a onmouseonver="alert('pwned');">XSS &</a>}
      expected = %{<p>&lt;a onmouseonver="alert('pwned');"&gt;XSS &amp;&lt;/a&gt;</p>}
      helper.markdown_no_html(mkd).should == expected
    end
  end

  describe :comment_url do
    it "should return the comment's post path with comment as anchor" do
      @comment = Factory.create :comment
      @post    = @comment.post
      expected = "http://test.host/posts/#{@post.cached_slug}#comment_#{@comment.id}"
      helper.comment_url(@comment).should == expected
    end
  end

  describe :html_title do
    it 'should return nil by default' do
      helper.html_title.should be_nil
    end

    it "should use the page's title when @page is defined" do
      @page = Factory.create :page
      helper.instance_variable_set(:@page, @page)
      helper.html_title.should == @page.title
    end

    it "should use the post's title when @post is defined" do
      @post = Factory.create :post
      helper.instance_variable_set(:@post, @post)
      helper.html_title.should == @post.title
    end
  end

  context 'when the locale is :en' do
    before :each do
      I18n.locale = :en
    end

    it 'should have comments_count_to_words speaking english' do
      helper.comments_count_to_words( 0).should == 'no comments'
      helper.comments_count_to_words( 1).should == 'one comment'
      helper.comments_count_to_words( 2).should == 'two comments'
      helper.comments_count_to_words(64).should == 'sixty-four comments'
    end

    it 'should have number_to_word translating number into english' do
      {
        2 => 'two', 3 => 'three', 4 => 'four', 5 => 'five', 6 => 'six',
        7 => 'seven', 8 => 'eight', 9 => 'nine', 10 => 'ten', 11 => 'eleven',
        12 => 'twelve', 13 => 'thirteen', 14 => 'fourteen', 15 => 'fifteen',
        16 => 'sixteen', 17 => 'seventeen', 18 => 'eighteen', 19 => 'nineteen',
        20 => 'twenty', 21 => 'twenty-one', 22 => 'twenty-two', 23 => 'twenty-three',
        30 => 'thirty', 39 => 'thirty-nine', 46 => 'forty-six', 58 => 'fifty-eight',
        65 => 'sixty-five', 77 => 'seventy-seven', 84 => 'eighty-four',
        91 => 'ninety-one', 100 => 'one hundred', 101 => 'one hundred one',
        102 => 'one hundred two', 200 => 'two hundred', 201 => 'two hundred one',
        202 => 'two hundred two', 324 => 'three hundred twenty-four',
        777 => 'seven hundred seventy-seven', 851 => 'eight hundred fifty-one',
      }.each do |n, val|
        helper.number_to_word(n).should == val
      end
    end

    it 'should have time_ago_sentance speaking english' do
      helper.time_ago_sentance(Time.now           ).should == 'less than a minute ago'
      helper.time_ago_sentance(Time.now - 1.minute).should == 'one minute ago'
      helper.time_ago_sentance(Time.now - 2.minute).should == 'two minutes ago'
      helper.time_ago_sentance(Time.now -   1.hour).should == 'about one hour ago'
      helper.time_ago_sentance(Time.now -  2.hours).should == 'about two hours ago'
      helper.time_ago_sentance(Time.now -    1.day).should == 'one day ago'
      helper.time_ago_sentance(Time.now -   2.days).should == 'two days ago'
      helper.time_ago_sentance(Time.now -  1.month).should == 'about one month ago'
      helper.time_ago_sentance(Time.now - 2.months).should == 'two months ago'
      helper.time_ago_sentance(Time.now -   1.year).should == 'about one year ago'
      helper.time_ago_sentance(Time.now -  2.years).should == 'about two years ago'
      helper.time_ago_sentance(Time.now - 42.years).should == 'about forty-two years ago'
    end
  end

  context 'when the locale is :fr' do
    before :each do
      I18n.locale = :fr
    end

    it 'should have comments_count_to_words speaking french' do
      helper.comments_count_to_words( 0).should == 'aucun commentaire'
      helper.comments_count_to_words( 1).should == 'un commentaire'
      helper.comments_count_to_words( 2).should == 'deux commentaires'
      helper.comments_count_to_words(64).should == 'soixante-quatre commentaires'
    end

    it 'should have number_to_word translating number into french' do
      {
        2 => 'deux', 3 => 'trois', 4 => 'quatre', 5 => 'cinq', 6 => 'six',
        7 => 'sept', 8 => 'huit', 9 => 'neuf', 10 => 'dix', 11 => 'onze',
        12 => 'douze', 13 => 'treize', 14 => 'quatorze', 15 => 'quinze',
        16 => 'seize', 17 => 'dix-sept', 18 => 'dix-huit', 19 => 'dix-neuf',
        20 => 'vingt', 21 => 'vingt et un', 22 => 'vingt-deux', 23 => 'vingt-trois',
        30 => 'trente', 39 => 'trente-neuf', 46 => 'quarante-six', 58 => 'cinquante-huit',
        65 => 'soixante-cinq', 77 => 'septante-sept', 84 => 'huitante-quatre',
        91 => 'nonante et un', 100 => 'cent', 101 => 'cent un',
        102 => 'cent deux', 200 => 'deux cents', 201 => 'deux cent un',
        202 => 'deux cent deux', 324 => 'trois cent vingt-quatre',
        777 => 'sept cent septante-sept', 851 => 'huit cent cinquante et un',
      }.each do |n, val|
        helper.number_to_word(n).should == val
      end
    end

    it 'should have time_ago_sentance speaking french' do
      helper.time_ago_sentance(Time.now           ).should == "il y a moins d'une minute"
      helper.time_ago_sentance(Time.now - 1.minute).should == 'il y a une minute'
      helper.time_ago_sentance(Time.now - 2.minute).should == 'il y a deux minutes'
      helper.time_ago_sentance(Time.now -   1.hour).should == 'il y a environ une heure'
      helper.time_ago_sentance(Time.now -  2.hours).should == 'il y a environ deux heures'
      helper.time_ago_sentance(Time.now -    1.day).should == 'il y a un jour'
      helper.time_ago_sentance(Time.now -   2.days).should == 'il y a deux jours'
      helper.time_ago_sentance(Time.now -  1.month).should == 'il y a environ un mois'
      helper.time_ago_sentance(Time.now - 2.months).should == 'il y a deux mois'
      helper.time_ago_sentance(Time.now -   1.year).should == 'il y a environ un an'
      helper.time_ago_sentance(Time.now -  2.years).should == 'il y a environ deux ans'
      helper.time_ago_sentance(Time.now - 42.years).should == 'il y a environ quarante-deux ans'
    end
  end
end
