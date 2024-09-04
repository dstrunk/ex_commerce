defmodule ExCommerce.Quote do
  import Ecto.Query, warn: false
  alias ExCommerce.Repo

  alias ExCommerce.Sales.Quote

  def get_quote!(id), do: Repo.get!(Quote, id) |> Repo.preload(:items)
end
