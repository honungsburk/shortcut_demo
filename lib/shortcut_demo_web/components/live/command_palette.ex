defmodule ShortcutDemoWeb.Live.CommandPalette do
  use ShortcutDemoWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <h1>Command Palette</h1>
    </div>
    """
  end
end
