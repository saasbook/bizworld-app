Feature: Create a master survey

  As an admin
  I should be able to create surveys

Scenario: create a master survey
  Given that I am an admin
  Then I should be able to create a master survey
  And a new survey should be able to see this master survey
