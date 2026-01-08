defmodule ShortcutDemoWeb.ShortcutDemoLive do
  use ShortcutDemoWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
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

  def command_palette(assigns) do
    ~H"""
    <div>
      <h1>Command Palette</h1>
    </div>
    """
  end
end
