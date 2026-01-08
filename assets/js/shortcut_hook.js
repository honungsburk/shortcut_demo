const ShortcutHook = {
  mounted() {
    this.shortcuts = []
    this.sequenceBuffer = []
    this.sequenceTimeout = null
    this.sequenceTimeoutMs = 500

    this.handleEvent("shortcut_config", ({ shortcuts }) => {
      this.shortcuts = shortcuts || []
    })

    this.keydownHandler = (e) => {
      if (this.shouldIgnoreEvent(e)) {
        return
      }

      const key = this.normalizeKey(e.key)
      const modifiers = this.getModifiers(e)

      if (this.tryMatchChord(key, modifiers, e)) {
        return
      }

      if (this.tryMatchSequence(key, e)) {
        return
      }
    }

    document.addEventListener("keydown", this.keydownHandler)
  },

  destroyed() {
    if (this.keydownHandler) {
      document.removeEventListener("keydown", this.keydownHandler)
    }
    if (this.sequenceTimeout) {
      clearTimeout(this.sequenceTimeout)
    }
  },

  shouldIgnoreEvent(e) {
    const tagName = e.target.tagName.toLowerCase()
    const isInput = tagName === "input" || tagName === "textarea"
    const isContentEditable = e.target.contentEditable === "true"
    return isInput || isContentEditable
  },

  normalizeKey(key) {
    const keyMap = {
      " ": "space",
      "ArrowUp": "arrowup",
      "ArrowDown": "arrowdown",
      "ArrowLeft": "arrowleft",
      "ArrowRight": "arrowright",
      "Escape": "escape",
      "Enter": "enter",
      "Tab": "tab",
      "Backspace": "backspace",
      "Delete": "delete"
    }
    return keyMap[key] || key.toLowerCase()
  },

  getModifiers(e) {
    const modifiers = []
    if (e.ctrlKey) modifiers.push("ctrl")
    if (e.shiftKey) modifiers.push("shift")
    if (e.altKey) modifiers.push("alt")
    if (e.metaKey) modifiers.push("meta")
    return modifiers.sort()
  },

  tryMatchChord(key, modifiers, e) {
    for (const spec of this.shortcuts) {
      for (const shortcut of spec.shortcuts) {
        if (shortcut.type === "chord") {
          const shortcutModifiers = (shortcut.modifiers || []).sort()
          if (
            shortcut.key === key &&
            this.arraysEqual(shortcutModifiers, modifiers)
          ) {
            e.preventDefault()
            e.stopPropagation()
            this.pushEvent("shortcut", { action_id: spec.action_id })
            return true
          }
        }
      }
    }
    return false
  },

  tryMatchSequence(key, e) {
    this.sequenceBuffer.push(key)

    if (this.sequenceTimeout) {
      clearTimeout(this.sequenceTimeout)
    }

    for (const spec of this.shortcuts) {
      for (const shortcut of spec.shortcuts) {
        if (shortcut.type === "sequence") {
          const sequence = shortcut.keys.map(k => this.normalizeKey(k))
          if (this.sequenceMatches(sequence)) {
            e.preventDefault()
            e.stopPropagation()
            this.sequenceBuffer = []
            if (this.sequenceTimeout) {
              clearTimeout(this.sequenceTimeout)
              this.sequenceTimeout = null
            }
            this.pushEvent("shortcut", { action_id: spec.action_id })
            return true
          }
        }
      }
    }

    this.sequenceTimeout = setTimeout(() => {
      this.sequenceBuffer = []
    }, this.sequenceTimeoutMs)

    return false
  },

  sequenceMatches(sequence) {
    if (this.sequenceBuffer.length < sequence.length) {
      return false
    }

    const recent = this.sequenceBuffer.slice(-sequence.length)
    return this.arraysEqual(recent, sequence)
  },

  arraysEqual(a, b) {
    if (a.length !== b.length) return false
    return a.every((val, idx) => val === b[idx])
  }
}

export default ShortcutHook
