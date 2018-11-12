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
                 %{"name" => "Reuben"},
                 %{"name" => "Croque Monsieur"},
                 %{"name" => "Muffuletta"},
                 %{"name" => "Bánh mì"},
                 %{"name" => "Vada Pav"},
                 %{"name" => "French Fries"},
                 %{"name" => "Papadum"},
                 %{"name" => "Pasta Salad"},
                 %{"name" => "Water"},
                 %{"name" => "Soft Drink"},
                 %{"name" => "Lemonade"},
                 %{"name" => "Masala Chai"},
                 %{"name" => "Vanilla Milkshake"},
                 %{"name" => "Chocolate Milkshake"}
                 # Rest of items
               ]
             }
           }
  end

  @query_by_name """
  {
    menuItems(matching: "reu") {
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
      menuItems(matching: 123){
        name
      }
    }
  """

  test "menuItems field returns errors when using a bad value" do
    response = get(build_conn(), "/api", query: @query_with_error)
    assert %{"errors" => [%{"message" => message}]} = json_response(response, 400)
    assert message == "Argument \"matching\" has invalid value 123."
  end

  @query_with_vars """
    query ($term: String){
      menuItems(matching: $term) {
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

end
