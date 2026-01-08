# ShortcutDemo

Small Repo to explore how to implement shortcuts and a command palette using phoenix live view.


## Inspiration

- https://launchscout.com/blog/key-combination-events-with-phoenix-liveview
- https://github.com/elixir-saas/command_k/blob/master/lib/command_k.ex
- https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent


## Notes

- There is a bug so when you execute an action via the command palette and use enter key it doesn't work. But if you click on one it does and after that the enter key starts working. 
- another bug is that command palette autofocus on input only works the first time. After that it no longer autofocuses.