FactoryGirl.define do

  sequence(:personalization_name) { |n| "Personalization-#{n}" }
  sequence(:personalization_description) { |n| "Description-#{n}" }

  factory :personalization_calculator, :class => Spree::Calculator::FlatRate do
    preferred_amount { rand(1..100) }
  end

  factory :product_personalization, :class => Spree::ProductPersonalization do
    name { generate(:personalization_name) }
    description { generate(:personalization_description) }
    required false
    kind 'text'
    limit 200
    calculator { |p| p.association(:personalization_calculator) }

    factory :product_personalization_with_option_value do
      transient do
        option_value_count 3
      end
      after(:create) do |personalization, evaluator|
        personalization.calculator.preferred_amount = 0
        create_list(:option_value_product_personalization, evaluator.option_value_count, product_personalization: personalization)
        personalization.reload
        personalization.kind = 'list'
        personalization.save!
      end
    end
  end

  factory :option_value_product_personalization, :class => Spree::OptionValueProductPersonalization do
    product_personalization
    option_value
    calculator { |p| p.association(:personalization_calculator) }
  end

  factory :product_with_personalizations, parent: :product do
    transient do
      personalization_count 3
    end
    after(:create) do |product, evaluator|
      create_list(:product_personalization, evaluator.personalization_count, product: product)
    end
  end

  factory :product_with_option_value_personalizations, parent: :product do
    transient do
      personalization_count 3
    end
    after(:create) do |product, evaluator|
      create_list(:product_personalization_with_option_value, evaluator.personalization_count, product: product)
    end
  end

  factory :variant_with_personalizations, parent: :variant do
    transient do
      personalization_count 3
    end
    after(:create) do |variant, evaluator|
      variant.product = create(:product_with_personalizations, personalization_count: evaluator.personalization_count)
      variant.save
    end
  end

end
