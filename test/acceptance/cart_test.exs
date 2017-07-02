defmodule PhoenixCommerce.Acceptance.CartTest do
  use PhoenixCommerce.AcceptanceCase

  alias PhoenixCommerce.Product
  alias PhoenixCommerce.LineItem
  alias PhoenixCommerce.Repo

  @upload %Plug.Upload{path: Path.relative_to_cwd("test/files/fishing.jpg"),
    filename: "fishing.jpg", content_type: "image/jpg"}

  setup do
    Repo.delete_all(Product)
    Repo.delete_all(LineItem)

    {:ok, product} =
      Product.changeset(%Product{}, %{
        name: "Some product",
        description: "Product description",
        price: Decimal.new("25.20"),
        image: @upload
      }) |> Repo.insert

    {:ok, product: product}
  end

  test "/cart - shows an empty cart" do
    navigate_to "/cart"

    assert visible_text(heading) == "Your cart"
    assert length(line_items()) == 0
  end

  test "adding product to a cart shows product in cart", %{product: product} do
    navigate_to "/products/#{product.id}"
    click(add_to_cart_button())

    navigate_to "/cart"
    assert length(line_items()) == 1
    assert visible_text(hd(line_items())) =~ ~r/#{product.name}/
  end

  def heading, do: find_element(:css, "h2")
  def cart, do: find_element(:css, ".cart")
  def cart_table, do: find_within_element(cart(), :css, "table")
  def cart_tbody, do: find_within_element(cart_table(), :css, "tbody")
  def line_items, do: find_all_within_element(cart_tbody(), :css, "tr")
  def add_to_cart_button, do: find_element(:css, "button[type=submit].add-to-cart")
end
