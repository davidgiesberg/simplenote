require 'test_helper'

class SimpleNoteTest < Test::Unit::TestCase
  context "initialize" do
    setup do
      SimpleNote.stubs(:post).returns("token")
      @simplenote = SimpleNote.new("validaccount@example.com","token")  
    end
    
    should "store the provided token" do
      @simplenote.token.should == "token"
    end

    should "store the provided email" do
      @simplenote.email.should == "validaccount@example.com"
    end
  end
  
  context "login" do
    setup do
      SimpleNote.stubs(:post).returns("token")
      @simplenote = SimpleNote.new
      @email = "validaccount@example.com"
      @password = "correctpassword"
      @simplenote.login(@email, @password)
    end

    should "store the returned token" do
      @simplenote.token.should == "token"
    end

    should "store the email" do
      @simplenote.email.should == @email
    end

    should "post to /login with email and password base 64 encoded" do
      expected_body = Base64.encode64({ :email => @email, :password => @password}.to_params)
      assert_received(SimpleNote, :post) do |expect|
        expect.with "/login", :body => expected_body
      end
    end
  end

  context "get_index" do
    setup do
      # TODO - test helper to construct urls given a SimpleNote object
      @url = "https://simple-note.appspot.com/api/index?email=me%40example.com&auth=token"
      body = '[{"key":"notekey", "modify":"2009-09-02 12:00:00.000000", "key":"AB1234"}]'
      FakeWeb.register_uri(:get, @url, :body => body)
      @simplenote = SimpleNote.new
      @simplenote.stubs(:token).returns("token")
      @simplenote.stubs(:email).returns("me@example.com")
      @index = @simplenote.get_index
    end
    
    should "return an Array" do
      @index.should be_kind_of(Array)
    end

    context "returned array" do
      should "contain a single Hash" do
        @index.length.should == 1
        @index[0].should be_kind_of(Hash)
      end
    end
  end
end
