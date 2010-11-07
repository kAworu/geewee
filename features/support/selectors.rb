module SelectorHelpers
  # Maps a name to a selector. Used by
  #
  # When /^(?:|I )follow "([^"]*)" ((?:in the|as) .+)$/ do |link, name|
  # Then /^(?:|I )should see "([^"]*)" ((?:in the|as) .+)$/ do |text, name|
  #
  # step definition in custom_web_steps.rb
  #
  def selector_for(name)
    case name

    when /^pagination$/
      'div.pagination'

    when /^(header|footer|sidebar|content)$/
      "##$1"

    else
      raise "Can't find mapping from \"#{name}\" to a selector.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(SelectorHelpers)
