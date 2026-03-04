-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.python3_host_prog = "/Users/allan/.pyenv/shims/python3"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.autoindent = true
  end,
})

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
    {
      "preservim/nerdtree", -- GitHub repo for NERDTree
      cmd = "NERDTreeToggle", -- load only when you use the toggle command
      keys = { { "<D-b>", ":NERDTreeToggle<CR>", mode = "n", desc = "Toggle NERDTree" } },
      config = function()
        --vim.api.nvim_set_keymap("n", "<A-b>", ":NERDTreeToggle<CR>", { noremap = true, silent = true })
      end,
    },
    {
      "ibhagwan/fzf-lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        local fzf = require("fzf-lua")

        fzf.setup({
          winopts = {
            height = 0.85,
            width = 0.85,
            preview = {
              layout = "vertical",
            },
          },
          -- Fix NERDTree/fzf behavior (removing for now since it does not work)
          --[[actions = {
            files = {
              ["default"] = function(selected)
                -- If we're in NERDTree (or any sidebar), jump to last normal window
                if vim.bo.filetype == "nerdtree" then
                  vim.cmd("wincmd p")
                end

                -- Fallback: if still not in a normal buffer, create one
                if vim.bo.filetype == "nerdtree" then
                  vim.cmd("enew")
                end

                fzf.actions.file_edit(selected)
              end,
            },
          },--]]
        })

        -- Ctrl+P like VS Code
        vim.keymap.set("n", "<C-p>", fzf.files, { desc = "Find files" })

        -- Optional extras
        vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
        vim.keymap.set("n","<C-S-f>", function() require("fzf-lua").live_grep() end, { desc = "Live grep" })
      end,
    },
    --[[
    --{
      "numirias/semshi",
      build = ":UpdateRemotePlugins"
    }, 
    --]]
    -- add other plugins here as needed
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

print("Configuration loaded")
