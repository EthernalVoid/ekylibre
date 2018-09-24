FactoryBot.define do
  factory :account do
    debtor { false }
    reconcilable { false }
    nature { 'general' }
    sequence(:name) { |n| "Compte 801 - #{n}" }
    sequence(:number) { |n| (801000 + n).to_s }
    number_is_valid { true }

    trait :client do
      sequence(:name) { |n| "Compte client #{n}" }
      sequence(:auxiliary_number) { |n| (10000 + n).to_s }
      nature { 'auxiliary' }
      centralizing_account_name { 'clients' }
    end

    trait :supplier do
      sequence(:name) { |n| "Compte fournisseur #{n}" }
      sequence(:auxiliary_number) { |n| (20000 + n).to_s }
      nature { 'auxiliary' }
      centralizing_account_name { 'suppliers' }
    end
  end
end
