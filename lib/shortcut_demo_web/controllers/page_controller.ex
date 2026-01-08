defmodule ShortcutDemoWeb.PageController do
  use ShortcutDemoWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
