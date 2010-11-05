require 'spec_helper'

describe GeeweeConfig do
  it { should validate_presence_of :bloguri }
  it { should validate_presence_of :blogtitle }
  it { should validate_presence_of :post_count_per_page }
  it { should validate_presence_of :locale }
  it { should validate_numericality_of :post_count_per_page }

  GeeweeConfig::ACCEPTED_LOCALES.each do |l|
    it "should accept #{l} as locale" do should allow_value(l).for(:locale) end
  end

  context 'when not configured' do
    it 'should not have any entry' do
      GeeweeConfig.count.should be_zero
    end

    it 'should allow to create a new entry' do
      cfg = GeeweeConfig.new(Factory.attributes_for(:geewee_config))
      lambda do
        cfg.save.should be_true
      end.should change(GeeweeConfig, :count).from(0).to(1)
    end

    describe :already_configured? do
      it 'should be false' do
        GeeweeConfig.should_not be_already_configured
      end
    end

    describe :entry do
      it 'should return a dummy entry with blogtitle not blank' do
        GeeweeConfig.entry.should_not be_nil
        GeeweeConfig.entry.blogtitle.should_not be_blank
      end
    end
  end

  context 'when configured' do
    before :each do
      Factory.create :geewee_config
    end

    it 'should have exactly one entry' do
      GeeweeConfig.count.should == 1
    end

    it 'should not allow to create another entry' do
      cfg = GeeweeConfig.new(Factory.attributes_for(:geewee_config))
      lambda do
        cfg.save.should be_false
      end.should_not change(GeeweeConfig, :count)
    end

    describe :already_configured? do
      it 'should return true' do
        GeeweeConfig.should be_already_configured
      end
    end

    describe :entry do
      it 'should return the first entry' do
        GeeweeConfig.entry.should == GeeweeConfig.find(:first)
      end
    end
  end
end
