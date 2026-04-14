
# mac-dotfiles
An install script that contains profile settings a Mac-based system

Baseline configuration:
1. General
   * Settings > General
     * Dark Mode
     * Enable: "Automatically hide and show status bar"
   * Dock
     * Automatically hide and show the Dock
     * Disable "show recent apps" in dock
   * Keyboard
     * Remap Caps Lock => Cmd
     * [Increase key repeat rate](https://vimforvscode.com/enable-key-repeat-vim)
   * Mouse
     * [Mapping third party mouse to back/forward](https://sensible-side-buttons.archagon.net/)
   * [HomeBrew](https://brew.sh/)
2. Workflow setup
   * [yabai](https://github.com/koekeishiya/yabai) (tiling wm)
     * [Disable rootless](https://www.macworld.co.uk/how-to/how-turn-off-mac-os-x-system-integrity-protection-rootless-3638975/)
     * [Prevent re-ordering of desktop spaces](https://apple.stackexchange.com/questions/214348/how-to-prevent-mac-from-changing-the-order-of-desktops-spaces)
   * [skhd](https://github.com/koekeishiya/skhd) (hotkeys to setup wm to simulate i3wm)
   * [spacebar](https://github.com/cmacrae/spacebar) (adding topbar widget)
   * [Rectangle](https://rectangleapp.com/) (Windows-like keybinding)
3. Terminal setup
   * Client: [Ghostty](https://ghostty.org/)
   * Theme: Night Owl
   * Font: Dank Mono
   * zshrc + [oh my zsh config](https://ohmyz.sh/)
   * [Delete whole word, jumb forward and backward a word](https://medium.com/@jonnyhaynes/jump-forwards-backwards-and-delete-a-word-in-iterm2-on-mac-os-43821511f0a)
4. IDE setup
   * VS Code
     * Theme: Night Owl
     * Font: Dank Mono
     * Extensions
        * General
          * Github Pull Requests
          * GitLens
          * Live Share
          * Sort Lines
          * Vim
          * Prettier
          * LiveShare
          * footsteps
       * Ruby-related
         * erb
         * Rails i18n
         * Ruby
         * Ruby Language Colorization
         * Ruby Solargraph
         * ruby-rubocop
         * VSCode Ruby
         * Slim
      * Javascript-related
        * ESLint
        * ES6
      * Other
        * [Move navigation to the right](https://twitter.com/code/status/1346573944703348743?lang=en)
5. Vim Setup
   * Install plugins using [vim-plug package manager](https://opensource.com/article/20/2/how-install-vim-plugins)
   * Plugins:
     * [vim-auto-save](https://vimawesome.com/plugin/vim-auto-save)
6. Neovim Setup
   * Install [Neovim](https://neovim.io/) (recommended via Homebrew: `brew install neovim`)
   * Run `./install.sh` to symlink `config/nvim/` to `~/.config/nvim`
   * Plugin manager: [lazy.nvim](https://github.com/folke/lazy.nvim) (auto-bootstrapped on first launch)
   * Plugins:
     * [NERDTree](https://github.com/preservim/nerdtree) — file explorer (`<D-b>` to toggle)
     * [fzf-lua](https://github.com/ibhagwan/fzf-lua) — fuzzy finder (`<C-p>` for files, `<C-S-f>` for live grep, `<leader>fb` for buffers)
     * [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) — file icons (dependency of fzf-lua)
     * [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) — git diff signs in the gutter and current-line blame
   * Key settings:
     * Leader key: `Space`
     * Tab width: 2 spaces
     * Python host: managed via pyenv (`~/.pyenv/shims/python3`)
7. Claude Code Setup
   * Install the CLI: `npm install -g @anthropic-ai/claude-code` (requires Node.js; `brew install node` if needed)
   * Run `claude` once in any directory and sign in to complete first-time auth
   * Run `./install.sh` to symlink `config/claude/settings.json` and `config/claude/CLAUDE.md` into `~/.claude/`
     * `settings.json` — statusline command, notification hook (terminal bell), enabled plugins, and extra marketplaces
     * `CLAUDE.md` — global instructions (commit conventions, PR format, worktree rules)
   * Marketplaces (added automatically via `settings.json`, no manual step needed):
     * [compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin)
     * [recursechat/agent-workflow](https://github.com/recursechat/agent-workflow)
   * Plugins (enabled via `settings.json`, install on first launch with `/plugin`):
     * `rust-analyzer-lsp@claude-plugins-official` — Rust LSP integration
     * `ruby-lsp@claude-plugins-official` — Ruby LSP integration
     * `ghostty-notifications@recursechat-agent-workflow` — Ghostty terminal notifications
   * Per-project plugins (installed ad hoc, not in global config):
     * `superpowers@claude-plugins-official` — enabled in individual project checkouts
     * `compound-engineering@compound-engineering-plugin` — enabled in individual project checkouts
   * Local-only files (not tracked in this repo; create by hand if needed):
     * `~/.claude/clickup.conf` — ClickUp API token for the `clickup` skill
     * `~/.claude/statusline-command.sh` — referenced by `statusLine` in `settings.json`
8. Brave Browser Setup
   * Extensions
     * [BlockSite](https://mybrowseraddon.com/block-site.html)
     * [StrongBox Autofill](https://chromewebstore.google.com/detail/strongbox-autofill/mnilpkfepdibngheginihjpknnopchbn?hl=en-US)
     * [Vimium](https://chromewebstore.google.com/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb?hl=en)
     * [Picture-in-Picture](https://chromewebstore.google.com/detail/picture-in-picture-extens/hkgfoiooedgoejojocmhlaklaeopbecg?hl=en)
     * [UnTrap for YouTube](https://chromewebstore.google.com/detail/untrap-for-youtube/enboaomnljigfhfjfoalacienlhjlfil?hl=en-US)
     * [SocialFocus] (https://chromewebstore.google.com/detail/socialfocus-hide-distract/abocjojdmemdpiffeadpdnicnlhcndcg?hl=en-US)
     * Distill Web Monitor
9. Other Apps
   * Notion
   * Anki
   * PSequel/Azure Data Studio/DBeaver
   * Firefox Developer Edition
   * Brave Browser
   * MacVim
   * [foobar2000](https://www.foobar2000.org/mac)
   * [CCleaner](https://www.ccleaner.com/ccleaner-mac)
   * StrongBox
   * Dropbox (sync keepass)
