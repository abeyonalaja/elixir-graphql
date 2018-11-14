# ---
# Excerpted from "Craft GraphQL APIs in Elixir with Absinthe",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/wwgraphql for more book information.
# ---
defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema
  alias PlateSlateWeb.Resolvers
  alias PlateSlate.{Menu, Repo}
  import Ecto.Query



  query do
    field :menu_items, list_of(:menu_item) do
      arg :filter, :menu_item_filter
      arg :order, type: :sort_order, default_value: :asc
      resolve &Resolvers.Menu.menu_items/3
    end
  end

  enum :sort_order do
    value :asc
    value :desc
  end

  @desc "Filtering options for the menu item list"
  input_object :menu_item_filter do
    @desc "matching a name"
    field :name, :string

    @desc "Matching a category name"
    field :category, :string

    @desc "Matching a tag"
    field :tag, :string

    @desc "Priced above a value"
    field :priced_above, :float

    @desc "Priced below a value"
    field :priced_below, :float
  end

  scalar :date do
    parse fn input ->
      # << Parsing logic here >>
      case Date.from_iso8601(input.value) do
        {:ok, date} -> {:ok, date}
        _ -> :error
      end
    end

    serialize fn date ->
      Date.to_iso8601(date)
    end
  end

  @desc "The list of available items on the menu"
  object :menu_item do
    field(:id, :id)
    field(:name, :string)
    field(:description, :string)
    field :added_on, :date
    # <<We'll add fields soon>>
  end
end
