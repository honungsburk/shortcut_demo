defmodule ShortcutDemo.Shortcuts do
  @moduledoc """
  Registry for keyboard shortcuts and their associated actions.

  Shortcuts can be:
  - Sequences: `["k", "k"]` - keys pressed in sequence
  - Chords: `%{modifiers: [:ctrl], key: "k"}` - modifier keys + key pressed together
  - Single keys: `%{key: "k"}` - single key press

  Multiple shortcuts can be registered for the same action.
  """

  @type shortcut :: list(String.t()) | %{key: String.t(), modifiers: [atom()] | nil}
  @type action_id :: atom()
  @type shortcut_spec :: %{
          shortcuts: [shortcut()],
          action_id: action_id(),
          description: String.t(),
          category: atom()
        }

  @shortcuts [
    %{
      shortcuts: [
        %{modifiers: [:ctrl], key: "k"},
        %{modifiers: [:meta], key: "k"}
      ],
      action_id: :open_command_palette,
      description: "Open command palette",
      category: :navigation
    },
    %{
      shortcuts: [
        %{modifiers: [:ctrl], key: "s"},
        %{modifiers: [:meta], key: "s"}
      ],
      action_id: :flash_success,
      description: "Flash success",
      category: :feedback
    },
    %{
      shortcuts: [
        %{modifiers: [:ctrl], key: "e"},
        %{modifiers: [:meta], key: "e"}
      ],
      action_id: :flash_error,
      description: "Flash error",
      category: :feedback
    },
    %{
      shortcuts: [
        %{modifiers: [:ctrl], key: "h"},
        %{modifiers: [:meta], key: "h"}
      ],
      action_id: :show_help,
      description: "Show keyboard shortcut help",
      category: :help
    }
  ]

  @doc """
  Returns all registered shortcuts.
  """
  def all, do: @shortcuts

  @doc """
  Returns shortcuts formatted for JavaScript consumption.

  Converts Elixir atoms to strings and normalizes the format.
  """
  def to_js_format do
    @shortcuts
    |> Enum.map(fn spec ->
      %{
        shortcuts: Enum.map(spec.shortcuts, &normalize_shortcut/1),
        action_id: to_string(spec.action_id),
        description: spec.description,
        category: to_string(spec.category)
      }
    end)
  end

  defp normalize_shortcut(shortcut) when is_list(shortcut) do
    %{type: "sequence", keys: shortcut}
  end

  defp normalize_shortcut(%{key: key, modifiers: modifiers}) when is_list(modifiers) do
    %{
      type: "chord",
      key: key,
      modifiers: Enum.map(modifiers, &Atom.to_string/1)
    }
  end

  defp normalize_shortcut(%{key: key}) do
    %{
      type: "chord",
      key: key,
      modifiers: []
    }
  end
end
