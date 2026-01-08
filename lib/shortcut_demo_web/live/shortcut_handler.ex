defmodule ShortcutDemoWeb.Live.ShortcutHandler do
  @moduledoc """
  Provides default shortcut event handling for LiveViews.

  LiveViews can `use` this module to get automatic shortcut handling.
  They only need to implement `handle_action/2` for their specific actions.

  ## Example

      defmodule MyAppWeb.MyLive do
        use MyAppWeb, :live_view
        use MyAppWeb.Live.ShortcutHandler

        def handle_action(:my_action, socket) do
          # Handle the action
          {:noreply, socket}
        end
      end
  """
  import Phoenix.LiveView, only: [put_flash: 3]
  import Phoenix.Socket, only: [assign: 3]
  import Logger

  @doc """
  implements the handle_event/3 callback to handle keyboard shortcut events.

  Instead of implementing the handle_event/3 callback yourself,
  you can use this macro to automatically handle keyboard shortcut events.
  """
  defmacro handle_event_shortcuts() do
    quote do
      def handle_event("shortcut", %{"action_id" => action_id}, socket) do
        ShortcutDemoWeb.Live.ShortcutHandler.handle_event(action_id, socket)
      end
    end
  end

  @doc """
  Handles a shortcut event.

  ## Examples

    def handle_event("shortcut", %{"action_id" => action_id}, socket) do
      ShortcutDemoWeb.Live.ShortcutHandler.handle_action(action_id, socket)
    end
  """
  def handle_event(action_id, socket) do
    action_id_atom = String.to_existing_atom(action_id)
    socket = handle_action(action_id_atom, socket)
    {:noreply, socket}
  end

  # Implement all keyboard actions here

  defp handle_action(:open_command_palette, socket) do
    assign(socket, :modal, :command_palette)
  end

  defp handle_action(:close_modals, socket) do
    assign(socket, :modal, nil)
  end

  defp handle_action(:flash_success, socket) do
    socket
    |> put_flash(:info, "Success!")
  end

  defp handle_action(:flash_error, socket) do
    socket
    |> put_flash(:error, "Error!")
  end

  defp handle_action(:show_help, socket) do
    socket
  end

  defp handle_action(unknown, socket) do
    Logger.warning("Unknown shortcut: #{inspect(unknown)}")
    socket
  end
end
