require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Category API" do


  before(:all) do
    new_advertiser = {
      'Title' => "Test"
    }
    client = Adzerk::Client.new(API_KEY)
    @flights= client.flights
    @advertisers = client.advertisers
    @channels = client.channels
    @campaigns = client.campaigns
    @priorities = client.priorities
    @category = client.categories
    # @sites = client.sites
    advertiser = @advertisers.create(:title => "test")
    $advertiserId = advertiser[:id].to_s

    channel = @channels.create(:title => 'Test Channel ' + rand(1000000).to_s,
                               :commission => '0.0',
                               :engine => 'CPM',
                               :keywords => 'test',
                               'CPM' => '10.00',
                               :ad_types =>  [1,2,3,4])
    $channel_id = channel[:id].to_s

    priority = @priorities.create(:name => "High Priority Test",
                                  :channel_id => $channel_id,
                                  :weight => 1,
                                  :is_deleted => false)
    $priority_id = priority[:id].to_s

    campaign = @campaigns.
      create(:name => 'Test campaign ' + rand(1000000).to_s,
             :start_date => "1/1/2011",
             :end_date => "12/31/2011",
             :is_active => false,
             :price => '10.00',
             :advertiser_id => $advertiserId,
             :flights => [],
             :is_deleted => false)
    $campaign_id = campaign[:id]

    new_flight = {
      :no_end_date => false,
      :priority_id => $priority_id,
      :name => 'Test flight ' + rand(1000000).to_s,
      :start_date => "1/1/2011",
      :end_date => "12/31/2011",
      :no_end_date => false,
      :price => '15.00',
      :option_type => 1,
      :impressions => 10000,
      :is_unlimited => false,
      :is_full_speed => false,
      :keywords => "test, test2",
      :user_agent_keywords => nil,
      :weight_override => nil,
      :campaign_id => $campaign_id,
      :is_active => true,
      :is_deleted => false
    }
    flight = @flights.create(new_flight)
    $flight_id = flight[:id].to_s

    $category_name = 'test category'
    $new_category = {
      :name => $category_name
    }

  end

  it "should add a category to a flight" do
    cat = @category.create($flight_id, $new_category)
    $category_id = cat[:id]
    cat[:name].should eq($category_name)

  end

  it "should list categories for a given flight" do
    cat = @category.list($flight_id)[:items].first
    cat[:name].should eq($category_name)
    cat[:id].should eq($category_id)
  end

  it "should list categories for the current network" do
    cat = @category.listAll()[:items].first
    cat[:name].should eq($category_name)
    cat[:id].should eq($category_id)
  end

  it "should delete a category from a flight" do
    response = @category.delete($flight_id, $category_id)
    response.body.should == '"Successfully deleted"'
  end

  it "should error when the flight or category id does not exist or does not belong to the network" do
    bad_id = 0
    lambda{ cat = @category.create(bad_id, $new_category) }.should raise_error
    lambda{ cat = @category.list(bad_id) }.should raise_error
    lambda{ cat = @category.delete(bad_id,$category_id) }.should raise_error
    lambda{ cat = @category.delete($flight_id,bad_id) }.should raise_error
  end

end
