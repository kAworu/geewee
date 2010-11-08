Feature: browse the archives by category
    In order to only see posts of interesting topic
    As a visitor
    I want to browse the posts by category

    Background:
        Given the blog is configured

    Scenario: Seeing the categories in the sidebar
        Given there is a category named "Business"
        And there is a category named "Children"
        When I go to the homepage
        Then I should see "Categories" in the sidebar
        And I should see "Business" in the sidebar
        And I should see "Children" in the sidebar

    Scenario: Seeing all the posts that belongs to a category
        Given there is a category named "Programming" with 3 posts
        And I am on the homepage
        When I follow "Programming" in the sidebar
        Then I should be on the archives page of the category "Programming"
        And I should see "Programming" in the content
        And I should see the list of all the posts from the category "Programming"

    Scenario: Seeing the category index with their posts
        Given there is a category named "Crime" with 5 posts
        And there is a category named "Thriller" with 0 posts
        And I am on the homepage
        When I follow "Categories" in the sidebar
        Then I should be on the archives by category page
        And I should see "Crime" in the content
        And I should see the list of all the posts from the category "Crime"
        And I should see "Thriller" in the content
        And I should see the list of all the posts from the category "Thriller"

    Scenario: reading a post from the archive by the link from the category's page
        Given there is a category named "Music"
        And there is a post titled "Oh by the way, which one's Pink?" in the category "Music"
        And I am on the archives page of the category "Music"
        When I follow "Oh by the way, which one's Pink?" in the content
        Then I should be on the post page "Oh by the way, which one's Pink?"
