require 'spec_helper'

describe Page do
  before :each do
    @page = Factory.create :page
  end

  it { should validate_presence_of   :title }
  it { should validate_presence_of   :body  }
  it { should validate_uniqueness_of :title }

  describe :modified_since_created? do
    it 'should return true if updated_at is different from created_at' do
      @page.should_not be_modified_since_created
      Timecop.travel 1.year.from_now
      @page.body = 'still here one year later!'
      @page.save!
      @page.reload
      @page.should be_modified_since_created
    end
  end
end
