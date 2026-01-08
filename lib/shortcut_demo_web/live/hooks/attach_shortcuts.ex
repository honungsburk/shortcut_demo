defmodule ShortcutDemoWeb.Live.Hooks.AttachShortcuts do
  @moduledoc """
  on_mount hook that automatically pushes shortcut configuration to the client.

  This hook eliminates the need to manually call push_shortcut_config in each LiveView's mount/3.
  """

  alias ShortcutDemo.Shortcuts
  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    shortcuts = Shortcuts.to_js_format()
    socket = push_event(socket, "shortcut_config", %{shortcuts: shortcuts})
    {:cont, socket}
  end
end
