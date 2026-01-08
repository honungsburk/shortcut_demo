defmodule ShortcutDemo.Repo do
  use Ecto.Repo,
    otp_app: :shortcut_demo,
    adapter: Ecto.Adapters.Postgres
end
