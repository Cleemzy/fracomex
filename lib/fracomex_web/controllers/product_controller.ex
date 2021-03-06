defmodule FracomexWeb.ProductController do
  use FracomexWeb, :controller

  alias Fracomex.Products

  def index(conn, _params) do
    # IO.inspect(get_session(conn, :user_id))
    render(
      conn,
      "product.html",
      layout: {FracomexWeb.LayoutView, "layout.html"},
      items: Products.list_items(),
      item_families: Products.list_families(),
      item_sub_families: Products.list_sub_families()
    )
  end
end
