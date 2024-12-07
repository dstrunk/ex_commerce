defmodule ExCommerceWeb.Resolvers.CustomerResolver do
  alias ExCommerce.Customer

  def customer(_parent, args, %{context: context}) do
    with {:ok, customer} <- get_current_customer(context) do
      case args do
        %{add_address: params} ->
          add_address(customer, params)

        %{update_address: params} ->
          update_address(customer, params)
      end
    end
  end

  defp add_address(customer, params) do
    Customer.create_address(Map.put(params, :customer_id, customer.id))
  end

  defp update_address(%{id: customer_id} = customer, %{address_id: address_id} = params) do
    case Customer.get_address!(address_id) do
      %{customer_id: ^customer_id} = address ->
        Customer.change_address(address, params)
      _ ->
        {:error, "Address not found"}
    end
  end

  defp get_current_customer(context) do
    case Map.get(context, :current_customer) do
      nil -> {:error, "Customer is not logged in"}
      customer -> {:ok, customer}
    end
  end
end
