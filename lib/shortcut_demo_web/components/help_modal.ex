defmodule ShortcutDemoWeb.Components.HelpModal do
  @moduledoc """
  Renders a modal displaying all keyboard shortcuts organized by category.
  """
  use ShortcutDemoWeb, :html

  import ShortcutDemoWeb.CoreComponents

  alias Phoenix.LiveView.JS
  alias ShortcutDemo.Shortcuts

  attr :on_close, :any, required: true, doc: "JS command or event to close the modal"

  def help_modal(assigns) do
    shortcuts = Shortcuts.all()
    shortcuts_by_category = Enum.group_by(shortcuts, & &1.category)

    assigns =
      assigns
      |> assign(:shortcuts_by_category, shortcuts_by_category)

    ~H"""
    <div
      id="help-modal"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
      phx-click={@on_close}
      phx-key="escape"
      phx-window-keydown={@on_close}
    >
      <div class="bg-base-100 rounded-lg shadow-xl max-w-2xl w-full mx-4 max-h-[80vh] overflow-hidden flex flex-col">
        <div class="flex items-center justify-between p-6 border-b border-base-300">
          <h2 class="text-2xl font-bold">Keyboard Shortcuts</h2>
          <button
            type="button"
            class="btn btn-ghost btn-sm btn-circle"
            phx-click={@on_close}
            aria-label="Close"
          >
            <.icon name="hero-x-mark" class="size-5" />
          </button>
        </div>

        <div class="overflow-y-auto p-6">
          <div :for={{category, shortcuts} <- @shortcuts_by_category} class="mb-8 last:mb-0">
            <h3 class="text-lg font-semibold mb-4 capitalize text-base-content/80">
              {String.replace(to_string(category), "_", " ")}
            </h3>
            <div class="space-y-3">
              <div
                :for={shortcut_spec <- shortcuts}
                class="flex items-center justify-between p-3 bg-base-200 rounded-lg hover:bg-base-300 transition-colors"
              >
                <span class="text-base flex-1">{shortcut_spec.description}</span>
                <div class="flex items-center gap-2 flex-wrap justify-end">
                  <div
                    :for={{shortcut, index} <- Enum.with_index(shortcut_spec.shortcuts)}
                    class="flex items-center gap-2"
                  >
                    <.shortcut_keys shortcut={shortcut} />
                    <span
                      :if={index < length(shortcut_spec.shortcuts) - 1}
                      class="text-base-content/50 text-sm"
                    >
                      or
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp shortcut_keys(assigns) do
    keys = format_shortcut_keys(assigns.shortcut)
    assigns = assign(assigns, :keys, keys)

    ~H"""
    <.shortcut keys={@keys} />
    """
  end

  defp format_shortcut_keys(shortcut) when is_list(shortcut) do
    Enum.map(shortcut, &String.capitalize/1)
  end

  defp format_shortcut_keys(%{key: key, modifiers: modifiers}) when is_list(modifiers) do
    modifier_keys =
      modifiers
      |> Enum.map(fn
        :ctrl -> "Ctrl"
        :meta -> "Meta"
        :alt -> "Alt"
        :shift -> "Shift"
        mod -> String.capitalize(to_string(mod))
      end)

    modifier_keys ++ [String.capitalize(key)]
  end

  defp format_shortcut_keys(%{key: key}) do
    [String.capitalize(key)]
  end
end
