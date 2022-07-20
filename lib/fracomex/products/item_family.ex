defmodule Fracomex.Products.ItemFamily do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:item_family_id, :string, autogenerate: false}
  schema "item_families" do
    field :caption, :string

  end

  @doc false
  def changeset(item_family, attrs) do
    item_family
    |> cast(attrs, [:item_family_id, :caption])
    |> validate_required([:item_family_id, :caption])
  end

  def update_changeset(item_family, attrs) do
    item_family
    |> cast(attrs, [:caption])
  end
end
