defmodule ExCommerce.Factory do
  use ExMachina.Ecto, repo: ExCommerce.Repo

  use ExCommerce.{ProductFactory, QuoteFactory, QuoteItemFactory, CustomerFactory, AddressFactory}
end
