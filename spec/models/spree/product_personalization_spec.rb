RSpec.describe Spree::ProductPersonalization do

  let(:count) { 5 }
  let(:attributes) do
    attrs = []
    count.times { attrs << {
      name:         FactoryBot.generate(:personalization_name),
      description:  FactoryBot.generate(:personalization_description),
      required:     [true, false].sample,
      limit:        rand(10...1000),
      calculator_attributes: {
        type:             "Spree::Calculator::FlatRate",
        preferred_amount: Money.new(rand(100...500)).to_s
      }
    }}
    attrs
  end
  let(:options) do
    { personalizations_attributes: attributes }
  end
  let(:params) { ActionController::Parameters.new(options).permit(personalizations_attributes: Spree::ProductPersonalization.permitted_attributes) }

  describe "Validations" do
    before do
      @target = FactoryBot.build(:product_personalization)
      expect(@target.valid?).to eq true
    end

    it "fails when name is too short" do
      @target.name = ""
      expect(@target.valid?).to eq false
    end

    it "fails when name is too long" do
      @target.name = "a" * (Spree::ProductPersonalization::LABEL_LIMIT + 1)
      expect(@target.valid?).to eq false
    end

    it "fails when description is too long" do
      @target.description = "a" * (Spree::ProductPersonalization::DESCRIPTION_LIMIT + 1)
      expect(@target.valid?).to eq false
    end

    it "fails when limit is too small" do
      @target.limit = 0
      expect(@target.valid?).to eq false
    end

    it "fails when limit is too big" do
      @target.limit = Spree::ProductPersonalization::TEXT_LIMIT + 1
      expect(@target.valid?).to eq false
    end

    it "fails when price is negative" do
      @target.calculator.preferred_amount = -1.0
      expect(@target.valid?).to eq false
    end

    context "attribute kind" do
      it 'should be invalid for empty value' do
        @target.kind = nil
        expect(@target.valid?).to eq false
        expect(@target.errors.full_messages.first).to eq "Kind  is not a valid type of personalization"
      end

      it 'should be invalid for bad values' do
        @target.kind = "random"
        expect(@target.valid?).to eq false
        expect(@target.errors.full_messages.first).to eq "Kind random is not a valid type of personalization"
      end

      it 'should be valid for a valid value' do
        @target.kind = "text"
        expect(@target.valid?).to eq true
        @target.kind = "list"
        option_value_product_personalization = FactoryBot.build(:option_value_product_personalization, product_personalization: @target)
        @target.option_value_product_personalizations << option_value_product_personalization
        expect(@target.valid?).to eq true
      end
    end

    context "#check_kind" do
      context "if of kind 'text'" do
        before do
          @target.kind = 'text'
        end

        it 'should be valid if option values are absent' do
          @target.option_value_product_personalizations = []
          expect(@target.valid?).to eq true
        end

        it 'should be invalid if option values are present' do
          option_value_product_personalization = FactoryBot.build(:option_value_product_personalization, product_personalization: @target)
          @target.option_value_product_personalizations << option_value_product_personalization
          expect(@target.valid?).to eq false
          expect(@target.errors.full_messages.first).to include 'en.spree.errors.personalization_text_cannot_have_options'
        end
      end

      context "if of kind 'list'" do
        before do
          @target.kind = 'list'
        end

        it 'should be invalid if option values are absent' do
          @target.option_value_product_personalizations = []
          expect(@target.valid?).to eq false
          expect(@target.errors.full_messages.first).to include 'en.spree.errors.personalization_options_should_have_options'
        end

        it 'should be valid if option values are present' do
          option_value_product_personalization = FactoryBot.build(:option_value_product_personalization, product_personalization: @target)
          @target.option_value_product_personalizations << option_value_product_personalization
          expect(@target.valid?).to eq true
        end
      end
    end
  end

  it "saves personalization" do
    product = FactoryBot.build(:product, shipping_category: FactoryBot.create(:shipping_category))
    product.attributes = params
    product.save!

    expect(product.personalizations).to be
    expect(product.personalizations.count).to eq(count)
    product.personalizations.each_with_index do |t, i|
      s = attributes[i]
      expect(t.name).to eq(s[:name])
      expect(t.description).to eq(s[:description])
      expect(t.required).to eq(s[:required])
      expect(t.limit).to eq(s[:limit])
      expect(t.calculator.preferred_amount).to eq(BigDecimal.new(s[:calculator_attributes][:preferred_amount]))
    end
  end

  it "updates personalization" do
    product = FactoryBot.create(:product_with_personalizations, personalization_count: count)
    product.personalizations.each_with_index do |t, i|
      s = attributes[i]
      s[:id] = t.id
      s[:calculator_attributes][:id] = t.calculator.id
    end
    product.update_attributes(params)
    product.reload

    product.personalizations.each_with_index do |t, i|
      s = attributes[i]
      expect(t.name).to eq(s[:name])
      expect(t.description).to eq(s[:description])
      expect(t.required).to eq(s[:required])
      expect(t.limit).to eq(s[:limit])
      expect(t.calculator.preferred_amount).to eq(BigDecimal.new(s[:calculator_attributes][:preferred_amount]))
    end
  end

  it "allows destroy personalization" do
    product = FactoryBot.create(:product_with_personalizations, personalization_count: count)
    product.personalizations.each_with_index do |t, i|
      s = attributes[i]
      s[:id] = t.id
      s[:calculator_attributes][:id] = t.calculator.id
    end
    pp_id = product.personalizations.first.id
    calc_id = product.personalizations.first.calculator.id
    attributes[0][:_destroy] = true
    product.update_attributes(params)
    product.reload

    expect(product.personalizations.count).to eq(count-1)
    expect(Spree::ProductPersonalization.find_by(id: pp_id)).to be_nil
    expect(Spree::Calculator::FlatRate.find_by(id: calc_id)).to be_nil
  end

  it "return increase price" do
    personalization = FactoryBot.create(:product_personalization)
    expect(personalization.increase_price).to eq(personalization.calculator.preferred_amount)

    personalization = FactoryBot.create(:product_personalization_with_option_value)
    personalization.option_value_product_personalizations.each_with_index do |o, i|
      expect(personalization.increase_price(i)).to eq(o.calculator.preferred_amount)
    end
  end

end
