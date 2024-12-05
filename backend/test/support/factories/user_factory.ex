defmodule ExCommerce.UserFactory do
  alias ExCommerce.Account.User

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %User{
          email: Faker.Internet.email(),
          first_name: Faker.Person.first_name(),
          last_name: Faker.Person.last_name(),
          password: 'hunter12',
        }
      end
    end
  end
end
