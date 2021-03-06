require 'spec_helper'
require 'rate_limiter'

describe RateLimiter do
  let(:user) { Fabricate(:user) }
  let(:rate_limiter) { RateLimiter.new(user, "peppermint-butler", 2, 60) }

  context 'disabled' do
    before do
      expect(RateLimiter).to receive(:disabled?).at_least(:once).and_return(true)
      rate_limiter.performed!
      rate_limiter.performed!
    end

    it "returns true for can_perform?" do
      expect(rate_limiter.can_perform?).to eq true
    end

    it "doesn't raise an error on performed!" do
      expect(lambda { rate_limiter.performed! }).to_not raise_error
    end
  end

  context 'enabled' do
    before do
      expect(RateLimiter).to receive(:disabled?).at_least(:once).and_return(false)
      rate_limiter.clear!
    end

    context 'never done' do
      it "should perform right away" do
        expect(rate_limiter.can_perform?).to eq true
      end

      it "performs without an error" do
        expect(lambda { rate_limiter.performed! }).to_not raise_error
      end
    end

    context "multiple calls" do
      before do
        rate_limiter.performed!
        rate_limiter.performed!
      end

      it "returns false for can_perform when the limit has been hit" do
        expect(rate_limiter.can_perform?).to eq false
      end

      it "raises an error the third time called" do
        expect(lambda { rate_limiter.performed! }).to raise_error(RateLimiter::LimitExceeded)
      end

      context "as an admin" do

        it "returns true for can_perform if the user is an admin" do
          user.admin = true
          expect(rate_limiter.can_perform?).to eq true
        end

        it "doesn't raise an error when an admin performs the task" do
          user.admin = true
          expect(lambda { rate_limiter.performed! }).to_not raise_error
        end
      end

      context "rollback!" do
        before do
          rate_limiter.rollback!
        end

        it "returns true for can_perform since there is now room" do
          expect(rate_limiter.can_perform?).to eq true
        end

        it "raises no error now that there is room" do
          expect(lambda { rate_limiter.performed! }).to_not raise_error
        end
      end
    end
  end
end
