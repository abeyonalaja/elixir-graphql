defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    PlateSlate.Seeds.run()
  end

  @query """
    {
      menuItems {
        name
      }
    }
  """

  test "menuItems field returns menu items" do
    conn = build_conn()
    conn = get(conn, "/api", query: @query)
    assert json_response(conn, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Bánh mì"},
                 %{"name" => "Chocolate Milkshake"}, %{"name" => "Croque Monsieur"},
                 %{"name" => "French Fries"}, %{"name" => "Lemonade"},
                 %{"name" => "Masala Chai"}, %{"name" => "Muffuletta"}, %{"name" => "Papadum"},
                 %{"name" => "Pasta Salad"}, %{"name" => "Reuben"},
                 %{"name" => "Soft Drink"}, %{"name" => "Vada Pav"},
                 %{"name" => "Vanilla Milkshake"}, %{"name" => "Water"}
                 # Rest of items
               ]
             }
           }
  end

  @query_by_name """
  {
    menuItems(filter: {name: "reu"}) {
      name
    }
  }
  """

  test "menuItems field returns menu items filtered by name" do
    response = get(build_conn(), "/api", query: @query_by_name)
    assert json_response(response, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Reuben"}
               ]
             }

           }
  end

  @query_with_error """
    {
      menuItems(filter: {name: 123}){
        name
      }
    }
  """

  test "menuItems field returns errors when using a bad value" do
    response = get(build_conn(), "/api", query: @query_with_error)
    assert %{"errors" => [%{"message" => message}]} = json_response(response, 400)
    assert message == "Argument \"filter\" has invalid value {name: 123}.\nIn field \"name\": Expected type \"String\", found 123."
  end

  @query_with_vars """
    query ($term: String){
      menuItems(filter: {name: $term}) {
        name
      }
    }
  """
  @variables %{"term" => "reu"}
  test "menuItems field filters by name when using a variable" do
    response = get(build_conn(), "/api", query: @query_with_vars, variables: @variables)
    assert json_response(response, 200) == %{
             "data" => %{
               "menuItems" => [%{"name" => "Reuben"}]
             }
           }
  end

  @query_with_filter """
  {
    menuItems(filter: {category: "Sandwiches", tag: "Vegetarian"}){ name}
  }
  """
  test "menuItems field returns menuItems, filtering with a literal" do
    response = get(build_conn(), "/api", query: @query_with_filter)
    assert %{
      "data" => %{"menuItems" => [%{"name" => "Vada Pav"}]} == json_response(response, 200)
    }
  end

  @query_added_before """
  query ($filter: MenuItemFilter!) {
    menuItems(filter: $filter) {
      name
      addedOn
  } }
  """
  @variables %{
    filter: %{
      "addedBefore" => "2017-01-20"
    }
  }
  test "menuItems filtered by custom scalar" do
    sides = PlateSlate.Repo.get_by!(PlateSlate.Menu.Category, name: "Sides")
    %PlateSlate.Menu.Item{
      name: "Garlic Fries",
      added_on: ~D[2017-01-01],
      price: 2.50,
      category: sides
    }
    |> PlateSlate.Repo.insert!

    response = get(build_conn(), "/api", query: @query_added_before, variables: @variables)
    assert %{
      "data" => %{
        "menuItems" => [%{"name" => "Garlic Fries", "addedOn" => "2017-01-01"}]
      }
    }
  end

end
