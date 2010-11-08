Feature: read and add comments
    In order to know other's visitor though and write mines
    As a visitor
    I want to read a post's comments and add some

    Background:
        Given the blog is configured
        And there is a post titled "gone with the wind"

    Scenario: reading a comment
        Given there is a comment on "gone with the wind" saying "it's the best movie eva!"
        When I go to the post page "gone with the wind"
        Then I should see "it's the best movie eva!" in the content

    Scenario: writting a comment
        Given I am on the post page "gone with the wind"
        When I fill in the following:
          | name    | Rhett Butler                          |
          | email   | rhett@butler.com                      |
          | comment | Frankly, my dear, I don't give a damn |
        And I press "Submit!"
        Then I should be on the post page "gone with the wind"
        And I should see "Thank you"
        And I should see "Your comment has been created"
        And I should see "Rhett Butler" in the content
        And I should not see "rhett@butler.com" in the content
        And I should see "Frankly, my dear, I don't give a damn" in the content
