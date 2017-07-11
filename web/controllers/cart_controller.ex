defmodule PhoenixCommerce.CartController do
  use PhoenixCommerce.Web, :controller

  alias PhoenixCommerce.{LineItem, Cart}

  plug :add_cart

  def add_cart(conn, _opts) do
    cart = case get_session(conn, :cart_uuid) do
      nil ->
        Repo.insert!(%Cart{})
      cart_uuid ->
        query = from c in Cart, where: c.uuid == ^cart_uuid
        Repo.one(query)
    end

    conn |> assign(:cart, cart) |> put_session(:cart_uuid, cart.uuid)
  end

  def show(conn, _params) do
    query =
      from li in LineItem,
      where: li.cart_id == ^conn.assigns[:cart].id,
      preload: [:product]

    line_items = Repo.all(query)

    render conn, "show.html", %{line_items: line_items}
  end

  def add(conn, %{"product" => %{"id" => product_id}}) do
    LineItem.changeset(%LineItem{}, %{
      product_id: product_id,
      cart_id: conn.assigns[:cart].id,
      quantity: 1
    }) |> Repo.insert!
    redirect conn, to: cart_path(conn, :show)
  end
end
