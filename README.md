# OptionsModel

An ActiveModel implementation that make easier to handle model which will be serialized in a real model.

support attribute:

- all types that `ActiveModel::Type` support
- typed array
- enum
- embeds one

## Usage

```ruby
class Person < OptionsModel::Base
  attribute :name, :string
  attribute :age, :integer

  validates :name, presence: true
end

class Book < OptionsModel::Base
  embeds_one :author, class_name: 'Person'

  attribute :title,     :string
  attribute :tags,      :string,   array:   true
  attribute :price,     :decimal,  default: 0
  attribute :bought_at, :datetime, default: -> { Time.new } 

  validates :title, presence: true
end
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'options_model'
```

And then execute:
```bash
$ bundle
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Please write unit test with your code if necessary.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
