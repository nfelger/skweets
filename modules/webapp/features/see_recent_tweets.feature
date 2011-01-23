Feature:
  So I know when people say amazing or horrifying stuff about us
  As a Songkicker
  I want to see recent tweets involving the word songkick

  Scenario: See some tweets
    Given 10 tweets have been processed
    When I visit "/"
    Then I want to see 10 tweets
