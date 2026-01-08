defmodule ShortcutDemoWeb.Components.Live.CommandPalette do
  use ShortcutDemoWeb, :live_component

  alias ShortcutDemo.Shortcuts

  def update(assigns, socket) do
    # #endregion
    shortcuts = Shortcuts.all()
    search_query = assigns[:search_query] || ""

    filtered = filtered_shortcuts(shortcuts, search_query)

    socket =
      socket
      |> assign(assigns)
      |> assign(:shortcuts, shortcuts)
      |> assign(:search_query, search_query)
      |> assign(:filtered_shortcuts, filtered)
      |> assign(:selected_index, if(filtered == [], do: nil, else: 0))

    {:ok, socket}
  end

  def handle_event("search", %{"search" => search_query}, socket) do
    filtered = filtered_shortcuts(socket.assigns.shortcuts, search_query)

    {:noreply,
     socket
     |> assign(:search_query, search_query)
     |> assign(:filtered_shortcuts, filtered)
     |> assign(:selected_index, if(filtered == [], do: nil, else: 0))}
  end

  def handle_event("execute_action", %{"action_id" => action_id}, socket) do
    send(self(), {:execute_action, String.to_existing_atom(action_id)})
    {:noreply, socket}
  end

  def handle_event("close", _params, socket) do
    send(self(), :close_command_palette)
    {:noreply, socket}
  end

  def handle_event("key-event", %{"key" => key}, socket) do
    case key do
      "Escape" ->
        send(self(), :close_command_palette)

      "Enter" ->
        index = socket.assigns.selected_index || 0

        case Enum.at(socket.assigns.filtered_shortcuts, index) do
          nil ->
            {:noreply, socket}

          shortcut_spec ->
            IO.inspect(shortcut_spec, label: "shortcut_spec")
            send(self(), {:execute_action, shortcut_spec.action_id})
            {:noreply, socket}
        end

      key when key in ["ArrowDown", "ArrowUp"] ->
        filtered_count = length(socket.assigns.filtered_shortcuts)

        if filtered_count == 0 do
          {:noreply, assign(socket, :selected_index, nil)}
        else
          new_index =
            case key do
              "ArrowDown" ->
                current = socket.assigns.selected_index || -1
                if current >= filtered_count - 1, do: 0, else: current + 1

              "ArrowUp" ->
                current = socket.assigns.selected_index || 0
                if current <= 0, do: filtered_count - 1, else: current - 1
            end

          {:noreply, assign(socket, :selected_index, new_index)}
        end

      _ ->
        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div
      id="command-palette"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
      phx-target={@myself}
    >
      <div
        phx-window-keydown="key-event"
        id="command-palette-container"
        class="bg-base-100 rounded-lg shadow-xl max-w-2xl w-full mx-4 max-h-[80vh] overflow-hidden flex flex-col"
        phx-click-away="close"
        phx-target={@myself}
      >
        <div class="p-4 border-b border-base-300">
          <form
            class="relative"
            phx-change="search"
            phx-target={@myself}
            phx-debounce="100"
          >
            <.icon
              name="hero-magnifying-glass"
              class="absolute left-3 top-1/2 -translate-y-1/2 size-5 text-base-content/50"
            />
            <input
              type="text"
              id="command-palette-search"
              name="search"
              value={@search_query}
              autofocus
              placeholder="Search commands..."
              class="w-full pl-10 pr-4 py-3 bg-base-200 border border-base-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
            />
          </form>
        </div>

        <div class="overflow-y-auto p-2" id="command-palette-results">
          <div
            :for={{shortcut_spec, index} <- Enum.with_index(@filtered_shortcuts)}
            class={[
              "flex items-center justify-between p-3 rounded-lg transition-colors cursor-pointer group",
              if(@selected_index == index,
                do: "bg-primary/20 border border-primary/50",
                else: "hover:bg-base-200"
              )
            ]}
            phx-click="execute_action"
            phx-target={@myself}
            phx-value-action_id={shortcut_spec.action_id}
            data-action-id={shortcut_spec.action_id}
            data-index={index}
          >
            <div class="flex-1">
              <div class="font-medium text-base">{shortcut_spec.description}</div>
              <div class="text-sm text-base-content/60 capitalize mt-1">
                {String.replace(to_string(shortcut_spec.category), "_", " ")}
              </div>
            </div>
            <div class="flex items-center gap-2 flex-wrap justify-end ml-4">
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
          <div
            :if={@filtered_shortcuts == []}
            class="p-8 text-center text-base-content/60"
          >
            No commands found
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

  defp filtered_shortcuts(shortcuts, search_query) when search_query == "" do
    shortcuts
  end

  defp filtered_shortcuts(shortcuts, search_query) do
    query = String.downcase(search_query)

    Enum.filter(shortcuts, fn spec ->
      description = String.downcase(spec.description)
      category = String.downcase(to_string(spec.category))
      action_id = String.downcase(to_string(spec.action_id))

      String.contains?(description, query) or
        String.contains?(category, query) or
        String.contains?(action_id, query)
    end)
  end
end
