# Targetprocess::Ruby

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/targetprocess/ruby`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'targetprocess-ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install targetprocess-ruby

## Usage

### Authentication

### UserStories

```xml
  <UserStory ResourceType="UserStory" Id="1094" Name="Add Endpoint to Grotto for Exporting Orders">
    <Description>&lt;!--markdown--&gt;As Grotto
I have an endpoint that when hit moves a new group of orders to queued

#### Notes
- Phil from Slack: "I am concerned that if we export 25 orders instead of 17, Grossman will not finish the 25 before the next window of orders is available meaning that I will only get 25 orders into Grossman every 20 minutes instead of 17 every ten."
Friday morning the Grotto scheduler ran at

Jan 20 04:09:49 grotto-production app/scheduler.2861:  Added 16 uninitiated orders to the export queue
Jan 20 04:19:37 grotto-production app/scheduler.1380:  Added 9 uninitiated orders to the export queue

Then Grotto-agent download orders (which places the files into the import folder for Grossman) ran at

Jan 20 04:09:39 grotto-agent-production_app26-prd-gsh grotto-agent:  I, [2017-01-20T04:10:03.463761 #31150]  INFO -- : Executing download_orders
Jan 20 04:19:39 grotto-agent-production_app26-prd-gsh grotto-agent:  I, [2017-01-20T04:20:03.464116 #31705]  INFO -- : Executing download_orders

Causing 26 orders to be placed in the import folder at 4:19:39

Options to fix
- Use temporize to control exactly when the Grotto export_orders job runs
  - Temporize pings a web endpoint so this would require it to trigger a background job
- Change download_orders on grotto-agent to run on it's own and every 5 minutes


#### Acceptance
- Verify that a new endpoint in Grotto exists that triggers queuing up the next batch of orders for export

	 </Description>
    <StartDate>2017-01-20T12:25:55</StartDate>
    <EndDate>2017-01-25T12:42:45</EndDate>
    <CreateDate>2017-01-20T12:21:06</CreateDate>
    <ModifyDate>2017-01-25T12:42:46</ModifyDate>
    <LastCommentDate>2017-01-25T12:42:40</LastCommentDate>
    <Tags></Tags>
    <NumericPriority>722.875</NumericPriority>
    <Effort>3.0000</Effort>
    <EffortCompleted>3.0000</EffortCompleted>
    <EffortToDo>0.0000</EffortToDo>
    <Progress>1.0000</Progress>
    <TimeSpent>0.0000</TimeSpent>
    <TimeRemain>0.0000</TimeRemain>
    <LastStateChangeDate>2017-01-25T12:42:45</LastStateChangeDate>
    <PlannedStartDate nil="true" />
    <PlannedEndDate nil="true" />
    <InitialEstimate>0.0000</InitialEstimate>
    <Units>pt</Units>
    <EntityType ResourceType="EntityType" Id="4" Name="UserStory" />
    <Project ResourceType="Project" Id="14" Name="Grotto">
      <Process ResourceType="Process" Id="2" Name="Tracker" />
    </Project>
    <LastEditor ResourceType="GeneralUser" Id="5">
      <FirstName>John</FirstName>
      <LastName>Gray</LastName>
      <Login>jgray</Login>
    </LastEditor>
    <Owner ResourceType="GeneralUser" Id="1">
      <FirstName>Eric</FirstName>
      <LastName>Cranston</LastName>
      <Login>ecranston</Login>
    </Owner>
    <LastCommentedUser ResourceType="GeneralUser" Id="5">
      <FirstName>John</FirstName>
      <LastName>Gray</LastName>
      <Login>jgray</Login>
    </LastCommentedUser>
    <LinkedTestPlan nil="true" />
    <Release nil="true" />
    <Iteration nil="true" />
    <TeamIteration ResourceType="TeamIteration" Id="1083" Name="Sprint #2" />
    <Team ResourceType="Team" Id="26" Name="Developer Team" />
    <Priority ResourceType="Priority" Id="5" Name="Nice To Have">
      <Importance>5</Importance>
    </Priority>
    <EntityState ResourceType="EntityState" Id="82" Name="Done">
      <NumericPriority>82</NumericPriority>
    </EntityState>
    <ResponsibleTeam ResourceType="TeamAssignment" Id="849" />
    <Feature ResourceType="Feature" Id="972" Name="Grotto Export Automation" />
    <CustomFields />
  </UserStory>
 ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/targetprocess-ruby.

