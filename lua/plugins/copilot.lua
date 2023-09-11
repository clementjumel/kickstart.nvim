-- Copilot.vim
--
-- Vim implementation of GitHub's Copilot.
-- Invoke `:Copilot setup` when using for the first time.

return {
  'github/copilot.vim',
  event = 'InsertEnter',
  init = function()
    local AcceptOneWord = function()
      vim.fn['copilot#Accept'] ''
      local bar = vim.fn['copilot#TextQueuedForInsertion']()
      return vim.fn.split(bar, [[[ .]\zs]])[1]
    end

    vim.keymap.set('i', '<s-tab>', AcceptOneWord, { expr = true, remap = false, desc = 'copilot#AcceptOneWord()' })
  end,
}