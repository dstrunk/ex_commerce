defmodule ExCommerce.Customer.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @derive {Jason.Encoder, except: [:password, :password_hash, :new_password, :new_password_confirmation]}
  schema "customers" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password, :string, virtual: true
    field :new_password, :string, virtual: true
    field :new_password_confirmation, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  def registration_changeset(customer, attrs) do
    customer
    |> cast(attrs, [:email, :first_name, :last_name, :password])
    |> validate_required([:email, :first_name, :last_name])
    |> validate_email()
    |> validate_password(:password)
    |> hash_password()
  end

  def update_changeset(customer, attrs) do
    customer
    |> cast(attrs, [:email, :first_name, :last_name, :password, :new_password, :new_password_confirmation])
    |> validate_required([:first_name, :last_name])
    |> validate_email()
    |> validate_current_password(customer.password_hash)
    |> validate_new_password()
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, field) do
    changeset
    |> validate_required([field])
    |> validate_length(field, min: 8, max: 72)
  end

  defp validate_current_password(changeset, stored_hash) do
    case get_change(changeset, :password) do
      nil -> add_error(changeset, :password, "can't be blank")
      password ->
        if Argon2.verify_pass(password, stored_hash) do
          changeset
        else
          add_error(changeset, :password, "is not valid")
        end
    end
  end

  defp validate_new_password(changeset) do
    case get_change(changeset, :new_password) do
      nil -> changeset
      _ ->
        changeset
        |> validate_password(:new_password)
        |> validate_confirmation(:new_password, message: "does not match new password")
        |> hash_new_password()
    end
  end

  defp hash_password(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password ->
        put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))
    end
  end

  defp hash_new_password(changeset) do
    case get_change(changeset, :new_password) do
      nil -> changeset
      new_password ->
        changeset
        |> put_change(:password_hash, Argon2.hash_pwd_salt(new_password))
        |> delete_change(:password)
        |> delete_change(:new_password)
        |> delete_change(:new_password_confirmation)
    end
  end
end
