defmodule ShortcutDemoWeb.ShortcutDemoLive do
  use ShortcutDemoWeb, :live_view
  import ShortcutDemoWeb.Live.ShortcutHandler
  import Logger

  def mount(_params, _session, socket) do
    {:ok, assign(socket, modal: nil, show_command_palette: false)}
  end

  handle_event_shortcuts()

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, modal: nil)}
  end

  def handle_event(event, _params, socket) do
    Logger.warning("Unknown shortcut event: #{inspect(event)}")
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} modal={@modal}>
      <div class="flex flex-col items-center justify-center text-center mt-20">
        <h1 class="text-5xl font-bold mb-2">Shortcut Demo</h1>
        <p class="text-xl text-base-content/70 mb-8">
          Try using your keyboard! Here are some shortcuts:
        </p>
        <div class="space-y-2 mb-8 max-w-md">
          <div class="bg-base-200 p-4 rounded-lg">
            <.shortcut keys={["Ctrl", "K"]} />
            <span class="ml-2 text-base">Open command palette</span>
          </div>
          <div class="bg-base-200 p-4 rounded-lg">
            <.shortcut keys={["/"]} />
            <span class="ml-2 text-base">Focus search</span>
          </div>
          <div class="bg-base-200 p-4 rounded-lg">
            <.shortcut keys={["?"]} />
            <span class="ml-2 text-base">Show keyboard shortcut help</span>
          </div>
        </div>
        <p class="text-base text-base-content/60">
          Your keyboard can do more! Try out the shortcuts above and see the actions on this page.
        </p>
      </div>
    </Layouts.app>
    """
  end

  #   <.live_component
  #   :if={@show_command_palette}
  #   module={ShortcutDemoWeb.Live.CommandPalette}
  #   id="command-palette"
  #   show={@show_command_palette}
  # />
end
