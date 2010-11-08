Feature: browse the archives by tags
    In order to see the relation between posts on the blog
    As a visitor
    I want to browse the posts by tag

    Background:
        Given the blog is configured

    Scenario: Seeing the tags in the sidebar
        Given there is a post titled "Mastering Regular Expression" tagged with "books, programming, perl"
        When I go to the homepage
        Then I should see "Tags cloud" in the sidebar
        And I should see "books" in the sidebar
        And I should see "programming" in the sidebar
        And I should see "perl" in the sidebar

    Scenario: Seeing all the posts that share a tag
        Given there is 3 published posts tagged with "UNIX"
        And I am on the homepage
        When I follow "UNIX" in the sidebar
        Then I should be on the archives page of the posts tagged with "UNIX"
        And I should see "UNIX" in the content
        And I should see the list of all the posts tagged with "UNIX"

    Scenario: Seeing the tag index with their posts
        Given there is a post titled "In The Mood For Love" tagged with "movie, Hong Kong, Wong Kar Wai"
        And I am on the homepage
        When I follow "Tags cloud" in the sidebar
        Then I should be on the archives by tag page
        And I should see "movie" in the content
        And I should see the list of all the posts tagged with "movie"
        And I should see "Hong Kong" in the content
        And I should see the list of all the posts tagged with "Hong Kong"
        And I should see "Wong Kar Wai" in the content
        And I should see the list of all the posts tagged with "Wong Kar Wai"

    Scenario: following the tag link in post list
        Given there is a post titled "Atom Heart Mother" tagged with "music, Pink Floyd"
        And I am on the archives by tag page
        When I follow "Pink Floyd" in the content
        Then I should be on the archives page of the posts tagged with "Pink Floyd"
