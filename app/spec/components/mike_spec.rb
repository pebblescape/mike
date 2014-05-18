require 'spec_helper'
require 'mike'

describe Mike do
  # context 'base_url' do
  #   context 'when https is off' do
  #     before do
  #       SiteSetting.expects(:use_https?).returns(false)
  #     end

  #     it 'has a non https base url' do
  #       Mike.base_url.should == "http://foo.com"
  #     end
  #   end

  #   context 'when https is on' do
  #     before do
  #       SiteSetting.expects(:use_https?).returns(true)
  #     end

  #     it 'has a non-ssl base url' do
  #       Mike.base_url.should == "https://foo.com"
  #     end
  #   end

  #   context 'with a non standard port specified' do
  #     before do
  #       SiteSetting.stubs(:port).returns(3000)
  #     end

  #     it "returns the non standart port in the base url" do
  #       Mike.base_url.should == "http://foo.com:3000"
  #     end
  #   end
  # end

  context "#enable_readonly_mode" do
    it "adds a key in redis and publish a message through the message bus" do
      $redis.expects(:set).with(Mike.readonly_mode_key, 1)
      MessageBus.expects(:publish).with(Mike.readonly_channel, true)
      Mike.enable_readonly_mode
    end
  end

  context "#disable_readonly_mode" do
    it "removes a key from redis and publish a message through the message bus" do
      $redis.expects(:del).with(Mike.readonly_mode_key)
      MessageBus.expects(:publish).with(Mike.readonly_channel, false)
      Mike.disable_readonly_mode
    end
  end

  context "#readonly_mode?" do
    it "returns true when the key is present in redis" do
      $redis.expects(:get).with(Mike.readonly_mode_key).returns("1")
      Mike.readonly_mode?.should == true
    end

    it "returns false when the key is not present in redis" do
      $redis.expects(:get).with(Mike.readonly_mode_key).returns(nil)
      Mike.readonly_mode?.should == false
    end
  end

  context "#handle_exception" do
    class TempLogger
      attr_accessor :exception, :context
      def handle_exception(exception, context)
        self.exception = exception
        self.context = context
      end
    end
    
    it "should not fail when called" do
      logger = TempLogger.new
      exception = StandardError.new

      Mike.handle_exception(exception, nil, logger)
      logger.exception.should == exception
    end
  end
end
