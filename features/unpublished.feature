Feature: hidding the unpublished posts
    In order to avoid being disturbed by unfinished posts
    As a visitor
    I want to see only published posts

    Background:
        Given the blog is configured

    Scenario: hidding unpublished posts in the homepage
        Given there is a post titled "Careful"
        And there is a post titled "With That Axe, Eugene"
        And the post titled "With That Axe, Eugene" has not been published yet
        When I go to the homepage
        Then I should see "Careful"
        And I should not see "With That Axe, Eugene"

    Scenario: hidding tags of unpublished posts in the sidebar
        Given there is a post titled "Echoes" tagged with "music, Pink Floyd, Meddle"
        And there is a post titled "Dogs" tagged with "music, Pink Floyd, Animals"
        And the post titled "Dogs" has not been published yet
        When I go to the homepage
        Then I should see "music" in the sidebar
        And I should see "Pink Floyd" in the sidebar
        And I should not see "Animals" in the sidebar

    Scenario: hidding unpublished posts in posts counts in the sidebar
        Given there is a post titled "Ninja"
        And the post titled "Ninja" has not been published yet
        When I go to the homepage
        Then I should see "(0)" in the sidebar
        And I should not see "(1)" in the sidebar

    Scenario: hidding month of unpublished posts in the sidebar
        Given there is a post titled "birthday" created the "12 April 2011"
        And the post titled "birthday" has not been published yet
        When I go to the homepage
        Then I should not see "April 2011" in the sidebar

    Scenario: hidding unpublished posts in archives by author
        Given there is a post titled "Super Mario Bros"
        And the post titled "Super Mario Bros" has not been published yet
        When I go to the archives by author page
        Then I should not see "Super Mario Bros"

    Scenario: hidding unpublished posts in archives by category
        Given there is a post titled "Goldeneye"
        And the post titled "Goldeneye" has not been published yet
        When I go to the archives by category page
        Then I should not see "Goldeneye"

    Scenario: hidding unpublished posts in archives by tag
        Given there is a post titled "Red Wine"
        And the post titled "Red Wine" has not been published yet
        When I go to the archives by tag page
        Then I should not see "Red Wine"

    Scenario: hidding unpublished posts in archives by month
        Given there is a post titled "Love hurts"
        And the post titled "Love hurts" has not been published yet
        When I go to the archives by month page
        Then I should not see "Love hurts"
