defmodule ExCommerce.CustomerFactory do
  alias ExCommerce.Customer.Customer

  defmacro __using__(_opts) do
    quote do
      def customer_factory do
        %{
          email: Faker.Internet.email(),
          first_name: Faker.Person.first_name(),
          last_name: Faker.Person.last_name(),
          password: "hunter12",
        }
        |> then(&Customer.registration_changeset(%Customer{}, &1))
        |> Ecto.Changeset.apply_changes()
      end
    end
  end
end
