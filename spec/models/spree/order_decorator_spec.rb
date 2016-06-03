require 'spec_helper'

describe Spree::Order do

  context "#merge!" do
    let(:variant) { create(:variant_with_personalizations) }
    let (:product_personalizations) { variant.product.personalizations }
    let (:personalization_1) { { name: product_personalizations[0].name, value: 'Red' } }
    let (:personalization_2) { { name: product_personalizations[1].name, value: 'Happy Birthday' } }
    let(:order_1) { create(:order) }
    let(:order_2) { create(:order) }

    it "merges together two orders with line items for the same variant and personalization" do
      order_1.contents.add(variant, 1, { personalizations_attributes: [personalization_1, personalization_2] })
      order_2.contents.add(variant, 1, { personalizations_attributes: [personalization_1, personalization_2] })
      order_1.merge!(order_2)
      line_item = order_1.line_items.first

      expect(order_1.line_items.count).to eq(1)
      expect(line_item.quantity).to eq(2)
      expect(line_item.variant_id).to eq(variant.id)
      expect(line_item.personalizations.first.value).to eq(personalization_1[:value])
    end

    context "if first order had more personalizations than the second" do
      before do
        order_1.contents.add(variant, 1, { personalizations_attributes: [personalization_1, personalization_2] })
        order_2.contents.add(variant, 1, { personalizations_attributes: [personalization_1] })
      end

      it "does not merge together two orders with line items for the same variant but different personalization" do
        order_1.merge!(order_2)
        line_items = order_1.line_items
        line_item_1, line_item_2 = line_items.load

        expect(line_items.count).to eq(2)
        expect(line_items.pluck(:quantity)).to eq([1, 1])
        expect(line_items.pluck(:variant_id)).to eq([variant.id, variant.id])
        expect(line_item_1.personalizations.map(&:value).uniq).to eq [personalization_1[:value], personalization_2[:value]]
        expect(line_item_2.personalizations.map(&:value).uniq).to eq [personalization_1[:value]]
      end
    end

    context "if second order has more personalizations than the first" do
      before do
        order_1.contents.add(variant, 1, { personalizations_attributes: [personalization_1] })
        order_2.contents.add(variant, 1, { personalizations_attributes: [personalization_1, personalization_2] })
      end

      it "does not merge together two orders with line items for the same variant but different personalization" do
        order_1.merge!(order_2)
        line_items = order_1.line_items
        line_item_1, line_item_2 = line_items.load

        expect(line_items.count).to eq(2)
        expect(line_items.pluck(:quantity)).to eq([1, 1])
        expect(line_items.pluck(:variant_id)).to eq([variant.id, variant.id])
        expect(line_item_1.personalizations.map(&:value).uniq).to eq [personalization_1[:value]]
        expect(line_item_2.personalizations.map(&:value).uniq).to eq [personalization_1[:value], personalization_2[:value]]
      end
    end

    it "does not merge together two orders with line items for the same variant wo/w personalization" do
      order_1.contents.add(variant, 1)
      order_2.contents.add(variant, 1, { personalizations_attributes: [personalization_1] })
      order_1.merge!(order_2)
      line_items = order_1.line_items
      line_item_1, line_item_2 = line_items.load

      expect(line_items.count).to eq(2)
      expect(line_items.pluck(:quantity)).to eq([1, 1])
      expect(line_items.pluck(:variant_id)).to eq([variant.id, variant.id])
      expect(line_item_1.personalizations).to eq []
      expect(line_item_2.personalizations.first.value).to eq personalization_1[:value]
    end

    it "does not merge together two orders with line items for the same variant w/wo personalization" do
      order_1.contents.add(variant, 1, { personalizations_attributes: [personalization_2] })
      order_2.contents.add(variant, 1)
      order_1.merge!(order_2)
      line_items = order_1.line_items
      line_item_1, line_item_2 = line_items.load

      expect(line_items.count).to eq(2)
      expect(line_items.pluck(:quantity)).to eq([1, 1])
      expect(line_items.pluck(:variant_id)).to eq([variant.id, variant.id])
      expect(line_item_1.personalizations.first.value).to eq personalization_2[:value]
      expect(line_item_2.personalizations).to eq []
    end

  end

end
