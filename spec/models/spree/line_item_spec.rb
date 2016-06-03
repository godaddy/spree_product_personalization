require 'spec_helper'

describe Spree::LineItem do

  before do
    @quantity = 2
    @variant = create(:variant_with_personalizations, price: 15)
    @product = @variant.product
    @product_personalizations  = @variant.product.personalizations

    @product_personalization_with_option_value = create(:product_personalization_with_option_value)
    @product_personalization_with_option_value.product = @product
    @product_personalization_with_option_value.save

    @select_option_value_product_personalization = @product_personalizations[3].option_value_product_personalizations.sample

    @personalization_1 = { name: @product_personalizations[0].name, value: 'Red' }
    @personalization_2 = { name: @product_personalizations[1].name, value: 'Happy Birthday' }
    @personalization_4 = { name: @product_personalizations[3].name, value: 'hi', option_value_id: @select_option_value_product_personalization.option_value_id.to_s }
    @order = create(:order)
  end

  def get_params(personalization_attributes)
    options  = { personalizations_attributes: personalization_attributes }
    ActionController::Parameters.new(options).permit(:personalizations_attributes => Spree::LineItemPersonalization.permitted_attributes)
  end

  context "validation" do
    it "is invalid when required personalization is not set" do
      @product_personalizations[0].required = true
      line_item = @order.contents.add(@variant, @quantity, get_params([@personalization_2, @personalization_4]))
      expect(line_item.valid?).to eq false
      expect(line_item.errors.messages[:'personalizations.missing'].size > 0).to eq true
    end
  end

  context "#copy_personalizations" do
    context "if the product does not have any personalization" do
      it 'does not copy any personalizations even if personalization is passed' do
        original_line_items_count = @order.line_items.count
        line_item = @order.contents.add(create(:variant), @quantity, get_params([@personalization_1, @personalization_2]))
        @order.reload

        expect(@order.line_items.count).to eq(original_line_items_count + 1)
        expect(line_item.quantity).to eq(@quantity)
        expect(line_item.personalizations.first).to be_nil
      end
    end

    context "if the product has personalizations" do
      it 'copies the found the personalizations' do
        pp_1 = @product_personalizations[0]
        pp_1.update(limit: 45)
        pp_2 = @product_personalizations[1]
        pp_2.update(limit: 67)

        product_personalization_1_calc = @product_personalizations[0].calculator
        product_personalization_1_calc.preferred_amount = 5.0
        product_personalization_1_calc.save
        product_personalization_2_calc = @product_personalizations[1].calculator
        product_personalization_2_calc.preferred_amount = 7.0
        product_personalization_2_calc.save
        product_personalization_4_calc = @select_option_value_product_personalization.calculator
        product_personalization_4_calc.preferred_amount = 9.0
        product_personalization_4_calc.save

        original_line_items_count = @order.line_items.count
        random_personaliztion = { name: 'Not-Set-In-Product', value: 'some_value' }
        line_item = @order.contents.add(@variant, @quantity, get_params([@personalization_1, @personalization_2, @personalization_4, random_personaliztion]))
        @order.reload

        expect(@order.line_items.count).to eq(original_line_items_count + 1)
        expect(line_item.quantity).to eq(@quantity)
        expect(line_item.personalizations.count).to eq 3

        expect(line_item.personalizations.map(&:value).uniq).to eq [@personalization_1[:value], @personalization_2[:value], @select_option_value_product_personalization.option_value.name, 'some_value']
        expect(line_item.personalizations.map(&:name).uniq).to eq [@personalization_1[:name], @personalization_2[:name], @personalization_4[:name], 'Not-Set-In-Product']
        expect(line_item.personalizations.map(&:limit).uniq).to eq [45, 67, 200, 255]

        expect(line_item.personalizations.map(&:price).map(&:to_s)).to eq ["5.0", "7.0", "9.0", '']
        expect(line_item.personalizations.map(&:currency).compact.uniq).to eq ["USD"]
      end
    end
  end
end
