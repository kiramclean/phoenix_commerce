defmodule PhoenixCommerce.RegisterTest do
  use PhoenixCommerce.ModelCase
  alias PhoenixCommerce.{Product, LineItem, Cart, Order, Register, Repo}

  setup do
    Repo.delete_all(Cart)
    Repo.delete_all(LineItem)
    Repo.delete_all(Product)

    {:ok, product} =
      Product.changeset(%Product{}, %{
        name: "Some product",
        description: "Product description",
        price: Decimal.new("25.20")
      }) |> Repo.insert

    {:ok, cart} = Cart.changeset(%Cart{}, %{}) |> Repo.insert

    {:ok, _line_item} =
      LineItem.changeset(%LineItem{}, %{
        product_id: product.id,
        cart_id: cart.id,
        quantity: 1
      }) |> Repo.insert

    {:ok, cart: cart}
  end

  test "ordering a cart introduces a new order with the cart's line items",
    %{cart: cart} do
      assert {:ok, order=%Order{}} = Register.order(cart)
      assert 1 = length(order.line_items)
  end

  @tag :external
  test "charging for an order through Stripe", %{cart: cart} do
    params = [
      number: "4111111111111111",
      exp_month: 10,
      exp_year: 2025,
      country: "US",
      name: "Phoenix Commerce",
      cvc: 123
    ]

    assert {:ok, charge} = Register.charge(cart, params)
    {:ok, fetched_charge} = Stripe.Charges.get(charge.id)
    assert fetched_charge.amount == 2_520
  end
end
