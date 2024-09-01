defmodule Ecom.Factory do
  use ExMachina.Ecto, repo: Ecom.Repo

  use Ecom.ProductFactory
end
