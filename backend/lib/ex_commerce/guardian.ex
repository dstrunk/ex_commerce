defmodule ExCommerce.Guardian do
  use Guardian, otp_app: :ex_commerce

  def subject_for_token(%{id: id}, _claims) do
    sub = to_string(id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => id}) do
    user = ExCommerce.Account.get_user!(id)
    {:ok, user}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
