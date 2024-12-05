defmodule ExCommerceWeb.CookieHelper do
  import Plug.Conn

  def put_quote_cookie(conn, quote_id) do
    put_resp_cookie(conn, "excommerce_quote_id", quote_id, max_age: 60 * 60 * 24 * 30)
  end

  def delete_quote_cookie(conn) do
    delete_resp_cookie(conn, "excommerce_quote_id")
  end
end
