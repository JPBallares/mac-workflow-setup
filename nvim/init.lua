-- init.lua - Main Neovim configuration
-- Place this in ~/.config/nvim/init.lua

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.hlsearch = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- File-specific indentation for JS/TS files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false

-- Auto reload files when changed externally
vim.opt.autoread = true

-- Trigger autoread when cursor stops moving or entering buffer
vim.api.nvim_create_autocmd({"BufEnter", "CursorHold", "CursorHoldI", "FocusGained"}, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = {"*"},
})

-- Install lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin configuration
require("lazy").setup({
  -- Telescope with native fzf for optimized performance
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    dependencies = { 
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make"
      }
    },
    config = function()
      require("telescope").setup({
        pickers = {
          buffers = {
            initial_mode = "normal"
          }
        },
        defaults = {
          file_ignore_patterns = { 
            "node_modules", 
            ".git/", 
            "__pycache__/", 
            "%.pyc$",
            ".venv/",
            "venv/",
            "build/",
            "dist/"
          },
          mappings = {
            i = {
              ["<C-u>"] = false,
              ["<C-d>"] = false,
              ["<C-x>"] = require("telescope.actions").delete_buffer,
            },
            n = {
              ["<C-x>"] = require("telescope.actions").delete_buffer,
            }
          },
          layout_config = {
            horizontal = {
              preview_width = 0.6,
              width = 0.9,
            },
          },
          path_display = { "truncate" },
          sorting_strategy = "descending",
          layout_strategy = "horizontal",
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          }
        }
      })
      
      -- Load fzf extension
      require("telescope").load_extension("fzf")
      
      -- Keymaps for optimized fuzzy finding
      vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "Help tags" })
      vim.keymap.set("n", "<leader>fr", require("telescope.builtin").oldfiles, { desc = "Recent files" })
      
      -- Fast access keybinds (Terminal-compatible)
      vim.keymap.set("n", "<C-p>", require("telescope.builtin").find_files, { desc = "Quick file finder" })
      vim.keymap.set("n", "g/", require("telescope.builtin").live_grep, { desc = "Quick grep" })
    end,
  },

  -- Vim surround
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      -- Set normal LSP log level
      vim.lsp.set_log_level("warn")

      vim.keymap.set("n", "gs", function()
        require("nvim-navbuddy").open()
      end, { desc = "NavBuddy symbols" })

      -- Breadcrumbs on_attach function
      local on_attach = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          local navic = require("nvim-navic")
          navic.attach(client, bufnr)
        end
      end


      -- Mason setup
      require("mason").setup()
      
      require("mason-lspconfig").setup({
        ensure_installed = { "pylsp", "eslint", "ts_ls", "rust_analyzer" },
        automatic_installation = true,
        automatic_enable = {
          exclude = {
            "ts_ls",
            "pylsp",
          }
        }
      })

      -- Completion setup
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        }),
      })

      -- LSP settings
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")

      -- Python - Use pylsp with black, flake8, isort
      -- Try to find pylsp in local .venv first, then fall back to system local
      pylsp_cmd = "pylsp"
      local venv_pylsp = vim.fn.getcwd() .. "/.venv/bin/pylsp"
      if vim.fn.executable(venv_pylsp) == 1 then
        pylsp_cmd = venv_pylsp
      end

      lspconfig.pylsp.setup({
        cmd = { pylsp_cmd },
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          pylsp = {
            plugins = {
              -- Disable conflicting linters/formatters
              pycodestyle = { enabled = false },
              pyflakes = { enabled = false },
              autopep8 = { enabled = false },
              yapf = { enabled = false },
              pylint = { enabled = false },

              -- Enable external tools
              black = { enabled = true },
              flake8 = { enabled = true },
              isort = { enabled = true, profile = "black" },

              -- Keep completions
              rope_completion = { enabled = true },
              rope_autoimport = { enabled = true },
            }
          }
        }
      })

      -- JavaScript/TypeScript
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
          on_attach(client, bufnr)
        end,
      })

      -- Commenting this out as mason autostarts lsp
      -- Rust
      -- lspconfig.rust_analyzer.setup({
      --   capabilities = capabilities,
      --   settings = {
      --     ["rust-analyzer"] = {
      --       cargo = {
      --         allFeatures = true,
      --       },
      --     },
      --   },
      -- })

      -- LSP keymaps (set on LspAttach)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          local opts = { buffer = ev.buf }
          
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gw", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
          
          -- gh - Show diagnostics or hover (like Zed)
          vim.keymap.set("n", "gh", function()
            local line = vim.api.nvim_win_get_cursor(0)[1] - 1
            local diagnostics = vim.diagnostic.get(0, { lnum = line })
            
            if #diagnostics > 0 then
              -- Show diagnostics if any exist on current line
              vim.diagnostic.open_float(nil, { 
                focusable = false,
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                border = 'rounded',
                source = 'always',
                prefix = ' ',
                scope = 'cursor',
              })
            else
              -- Show hover documentation if no diagnostics
              vim.lsp.buf.hover()
            end
          end, { buffer = ev.buf, desc = "Show diagnostics or hover info" })
          
          -- Format on save for all files with LSP formatting
          if client and client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = ev.buf,
              callback = function()
                vim.lsp.buf.format({ async = false })
              end,
            })
          end
        end,
      })

    end,
  },

  -- Treesitter for better syntax highlighting and code navigation
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "vim", "vimdoc", "python", "javascript", "typescript", "rust" },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        fold = { enable = true },
      })
    end,
  },

  -- Icons (load early to ensure availability)
  {
    "echasnovski/mini.icons",
    version = false,
    priority = 500,
    config = function()
      require("mini.icons").setup({
        -- Ensure compatibility with other plugins
        style = 'glyph', -- or 'ascii' if you prefer
      })
      -- Make icons available immediately
      MiniIcons.mock_nvim_web_devicons()
    end,
  },

  -- File tree and class/function outline (gs functionality)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { 
      "nvim-tree/nvim-web-devicons",
      "echasnovski/mini.icons",
    },
    config = function()
      -- Disable netrw at the very start
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
          icons = {
            webdev_colors = true,
            git_placement = "before",
            modified_placement = "after",
            padding = " ",
            symlink_arrow = " ➛ ",
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
              modified = true,
            },
            glyphs = {
              default = "",
              symlink = "",
              bookmark = "",
              modified = "●",
              folder = {
                arrow_closed = "",
                arrow_open = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
          highlight_git = true,
          highlight_opened_files = "none",
          highlight_modified = "none",
        },
        filters = {
          dotfiles = false, -- Show dotfiles by default
          git_clean = false,
          no_buffer = false,
        },
        git = {
          enable = true,
        },
        modified = {
          enable = true,
        },
        -- Better colors for visibility
        on_attach = function(bufnr)
          local api = require('nvim-tree.api')
          
          local function opts(desc)
            return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end
          
          -- Default mappings
          api.config.mappings.default_on_attach(bufnr)
          
          -- Custom mappings
          vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
          vim.keymap.set('n', 'o', api.node.open.edit, opts('Open'))
          vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts('Open'))
          vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
          vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open: Horizontal Split'))
          vim.keymap.set('n', 't', api.node.open.tab, opts('Open: New Tab'))
        end,
      })
      
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
      
      -- Fix colors for better visibility
      vim.cmd([[
        highlight NvimTreeFolderName guifg=#7aa2f7
        highlight NvimTreeOpenedFolderName guifg=#7dcfff
        highlight NvimTreeFolderIcon guifg=#7aa2f7
        highlight NvimTreeIndentMarker guifg=#3b4261
        highlight NvimTreeNormal guibg=#1a1b26
        highlight NvimTreeVertSplit guifg=#1a1b26 guibg=#1a1b26
        highlight NvimTreeEndOfBuffer guifg=#1a1b26 guibg=#1a1b26
      ]])
    end,
  },

  -- Symbols outline for class/function tree (gs functionality)
  -- {
  --   "hedyhli/outline.nvim",
  --   lazy = true,
  --   cmd = { "Outline", "OutlineOpen" },
  --   keys = {
  --     { "gs", "<cmd>Outline<CR>", desc = "Toggle symbols outline" },
  --   },
  --   config = function()
  --     require("outline").setup({
  --       outline_window = {
  --         position = "right",
  --         width = 25,
  --         relative_width = true,
  --         -- Fix buffer naming conflict
  --         buf_name_fmt = function()
  --           return "[Outline] " .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
  --         end,
  --       },
  --       symbols = {
  --         filter = {
  --           'Class',
  --           'Function',
  --           'Method',
  --           'Constructor',
  --           'Enum',
  --           'Interface',
  --           'Module',
  --           'Namespace',
  --           'Package',
  --           'Struct',
  --         },
  --       },
  --       keymaps = {
  --         show_help = '?',
  --         close = {'<Esc>', 'q'},
  --         goto_location = '<Cr>',
  --         peek_location = 'o',
  --         goto_and_close = '<S-Cr>',
  --         restore_location = '<C-g>',
  --         hover_symbol = '<C-space>',
  --         toggle_preview = 'K',
  --         rename_symbol = 'r',
  --         code_actions = 'a',
  --         fold = 'h',
  --         unfold = 'l',
  --         fold_toggle = '<Tab>',
  --         fold_toggle_all = '<S-Tab>',
  --         fold_all = 'W',
  --         unfold_all = 'E',
  --         fold_reset = 'R',
  --         down_and_jump = '<C-j>',
  --         up_and_jump = '<C-k>',
  --       },
  --       providers = {
  --         priority = { 'lsp', 'coc', 'markdown', 'norg' },
  --         lsp = {
  --           blacklist_clients = {},
  --         },
  --       },
  --     })
  --   end,
  -- },

  -- Multiple cursor support (gl functionality for selecting duplicates)
  {
    "mg979/vim-visual-multi",
    config = function()
      -- gl will work for selecting multiple occurrences
      vim.keymap.set("n", "gl", "<Plug>(VM-Add-Cursor-At-Word)", { desc = "Add cursor at word" })
      vim.keymap.set("v", "gl", "<Plug>(VM-Visual-Cursors)", { desc = "Add cursors in visual mode" })
    end,
  },

  -- Tab management
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "tabs",
          separator_style = "slant",
          always_show_bufferline = false,
          show_buffer_close_icons = false,
          show_close_icon = false,
          color_icons = true,
        },
      })
      
      -- Tab navigation keymaps
      vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { desc = "New tab" })
      vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })
      vim.keymap.set("n", "<leader>to", ":tabonly<CR>", { desc = "Close other tabs" })
      vim.keymap.set("n", "<A-h>", ":tabprevious<CR>", { desc = "Previous tab" })
      vim.keymap.set("n", "<A-l>", ":tabnext<CR>", { desc = "Next tab" })
      vim.keymap.set("n", "<A-1>", "1gt", { desc = "Go to tab 1" })
      vim.keymap.set("n", "<A-2>", "2gt", { desc = "Go to tab 2" })
      vim.keymap.set("n", "<A-3>", "3gt", { desc = "Go to tab 3" })
      vim.keymap.set("n", "<A-4>", "4gt", { desc = "Go to tab 4" })
      vim.keymap.set("n", "<A-5>", "5gt", { desc = "Go to tab 5" })
    end,
  },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gitsigns = require('gitsigns')

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then
              vim.cmd.normal({"]c", bang = true})
            else
              gitsigns.nav_hunk("next")
            end
          end, { desc = "Next git hunk" })

          map("n", "[c", function()
            if vim.wo.diff then
              vim.cmd.normal({"[c", bang = true})
            else
              gitsigns.nav_hunk("prev")
            end
          end, { desc = "Previous git hunk" })

          -- Actions
          map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage hunk" })
          map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset hunk" })
          map("v", "<leader>hs", function() gitsigns.stage_hunk {vim.fn.line("."), vim.fn.line("v")} end, { desc = "Stage hunk" })
          map("v", "<leader>hr", function() gitsigns.reset_hunk {vim.fn.line("."), vim.fn.line("v")} end, { desc = "Reset hunk" })
          map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Stage buffer" })
          map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "Undo stage hunk" })
          map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Reset buffer" })
          map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview hunk" })
          map("n", "<leader>hb", function() gitsigns.blame_line{full=true} end, { desc = "Blame line" })
          map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Toggle blame" })
          map("n", "<leader>hd", gitsigns.diffthis, { desc = "Diff this" })
          map("n", "<leader>hD", function() gitsigns.diffthis("~") end, { desc = "Diff this ~" })
          map("n", "<leader>td", gitsigns.toggle_deleted, { desc = "Toggle deleted" })

          -- Text object
          map({"o", "x"}, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select hunk" })
        end
      })
    end,
  },

  -- Enhanced git commands
  {
    "tpope/vim-fugitive",
    config = function()
      vim.keymap.set("n", "<leader>gs", ":Git<CR>", { desc = "Git status" })
      vim.keymap.set("n", "<leader>gc", ":Git commit<CR>", { desc = "Git commit" })
      vim.keymap.set("n", "<leader>gp", ":Git push<CR>", { desc = "Git push" })
      vim.keymap.set("n", "<leader>gl", ":Git log<CR>", { desc = "Git log" })
      vim.keymap.set("n", "<leader>gb", ":Git blame<CR>", { desc = "Git blame" })
      vim.keymap.set("n", "<leader>gd", ":Gdiffsplit<CR>", { desc = "Git diff split" })
    end,
  },

  -- Merge conflict resolution
  {
    "rhysd/conflict-marker.vim",
    config = function()
      -- Conflict marker mappings
      vim.keymap.set("n", "<leader>co", ":ConflictMarkerOurselves<CR>", { desc = "Choose ours" })
      vim.keymap.set("n", "<leader>ct", ":ConflictMarkerThemselves<CR>", { desc = "Choose theirs" })
      vim.keymap.set("n", "<leader>cb", ":ConflictMarkerBoth<CR>", { desc = "Choose both" })
      vim.keymap.set("n", "<leader>cn", ":ConflictMarkerNone<CR>", { desc = "Choose none" })
      vim.keymap.set("n", "[x", ":ConflictMarkerPrevHunk<CR>", { desc = "Previous conflict" })
      vim.keymap.set("n", "]x", ":ConflictMarkerNextHunk<CR>", { desc = "Next conflict" })
      
      -- Highlight groups
      vim.cmd([[
        highlight ConflictMarkerBegin guibg=#2f628e
        highlight ConflictMarkerOurs guibg=#2e5016
        highlight ConflictMarkerTheirs guibg=#344f69
        highlight ConflictMarkerEnd guibg=#2f628e
        highlight ConflictMarkerCommonAncestorsHunk guibg=#754a81
      ]])
    end,
  },

  -- Which-key for discovering keybindings
  {
    "folke/which-key.nvim",
    event = "VimEnter",
    config = function()
      require("which-key").setup()
      require("which-key").add({
        { "<leader>f", group = "[F]ind" },
        { "<leader>f_", hidden = true },
        { "<leader>h", group = "[H]unk" },
        { "<leader>h_", hidden = true },
        { "<leader>g", group = "[G]it" },
        { "<leader>g_", hidden = true },
        { "<leader>t", group = "[T]ab/Toggle" },
        { "<leader>t_", hidden = true },
        { "<leader>c", group = "[C]onflict" },
        { "<leader>c_", hidden = true },
        { "<leader>s", group = "[S]ession" },
        { "<leader>s_", hidden = true },
      })
    end,
  },

  -- Session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
      options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" }
    },
    keys = {
      { "<leader>ss", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>sS", function() require("persistence").select() end, desc = "Select Session" },
      -- This one restore last session regardless of directory
      { "<leader>sl", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>sd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
      { "<leader>sw", function() require("persistence").save() end, desc = "Save Current Session" },
    },
  },

  -- Color scheme
  {
    "Shatur/neovim-ayu",
    priority = 1000,
    config = function()
      require("ayu").setup({
        mirage = false,
        overrides = {},
      })
      vim.cmd.colorscheme("ayu-dark")
    end,
  },
  
  -- Breadcrumbs
  {
    "SmiteshP/nvim-navic",
    dependencies = {
      "neovim/nvim-lspconfig",
    }
  },
  
  {
    "SmiteshP/nvim-navbuddy",
    dependencies = {
      "neovim/nvim-lspconfig",
      "SmiteshP/nvim-navic",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      lsp = { auto_attach = true },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { 
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local navic = require("nvim-navic")
  
      require("lualine").setup({
        options = {
          theme = "auto",
          component_separators = { left = '|', right = '|' },
          section_separators = { left = '', right = '' },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            { "filename", path = 1 },
            {
              function()
                return navic.get_location()
              end,
              cond = function()
                return navic.is_available()
              end,
            },
          },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  }

})

-- Additional keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic quickfix" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to upper window" })

-- Extra recognition for tf file
vim.filetype.add({ extension = { tf = "terraform" } })

-- Highlight when yanking text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Auto-save session on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
  desc = "Save session on exit",
  group = vim.api.nvim_create_augroup("session-save", { clear = true }),
  callback = function()
    require("persistence").save()
  end,
})

-- Auto-restore session on startup
vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Restore session on startup",
  group = vim.api.nvim_create_augroup("session-restore", { clear = true }),
  callback = function()
    local args = vim.fn.argv()
    local is_git = vim.fn.expand("%:t") == "COMMIT_EDITMSG"

    -- True if: no args or first arg is a directory
    local restore_allowed = #args == 0 or vim.fn.filereadable(args[1]) == 0

    if restore_allowed and not is_git then
      vim.schedule(function()
        require("persistence").load()
      end)
    end
  end,
})

-- Better visibility for line numbers
vim.cmd([[
  highlight LineNr guifg=#6272a4
  highlight CursorLineNr guifg=#f8f8f2 gui=bold
]])

-- Custom surround command for visual selection command line
vim.api.nvim_create_user_command('Surround', function(opts)
  local char = opts.args
  if char == '' then
    char = vim.fn.input('Surround with: ')
  end
  if char == '' then return end
  
  -- Handle special cases for paired characters
  local pairs = {
    ['('] = { '(', ')' },
    [')'] = { '(', ')' },
    ['['] = { '[', ']' },
    [']'] = { '[', ']' },
    ['{'] = { '{', '}' },
    ['}'] = { '{', '}' },
    ['<'] = { '<', '>' },
    ['>'] = { '<', '>' },
  }
  
  local left_char, right_char
  if pairs[char] then
    left_char, right_char = pairs[char][1], pairs[char][2]
  else
    left_char, right_char = char, char
  end
  
  -- Escape special regex characters
  local function escape_regex(str)
    return str:gsub('[%(%)%.%+%-%*%?%[%]%^%$%%]', '%%%1')
  end
  
  -- Add surrounding characters
  vim.cmd(string.format("'<,'>s/^/%s/", escape_regex(left_char)))
  vim.cmd(string.format("'<,'>s/$/%s/", escape_regex(right_char)))
end, { 
  range = true, 
  nargs = '?',
  desc = "Surround visual selection with character(s)"
})

-- Copy relative path command
vim.api.nvim_create_user_command('CopyRelativePath', function()
  local relative_path = vim.fn.expand('%')
  if relative_path == '' then
    print('No file in buffer')
    return
  end
  vim.fn.setreg('+', relative_path)
  print('Copied: ' .. relative_path)
end, { desc = 'Copy relative path to clipboard' })

-- Copy path with line number command
vim.api.nvim_create_user_command('CopyPathLineNumber', function()
  local relative_path = vim.fn.expand('%')
  if relative_path == '' then
    print('No file in buffer')
    return
  end
  local line_number = vim.fn.line('.')
  local path_with_line = relative_path .. ':' .. line_number
  vim.fn.setreg('+', path_with_line)
  print('Copied: ' .. path_with_line)
end, { desc = 'Copy relative path with line number to clipboard' })

-- Custom command for removing surrounding characters
vim.api.nvim_create_user_command('Unsurround', function(opts)
  local char = opts.args
  if char == '' then
    char = vim.fn.input('Remove surround: ')
  end
  if char == '' then return end
  
  -- Handle special cases for paired characters
  local pairs = {
    ['('] = { '%(', '%)', '(', ')' },
    [')'] = { '%(', '%)', '(', ')' },
    ['['] = { '%[', '%]', '[', ']' },
    [']'] = { '%[', '%]', '[', ']' },
    ['{'] = { '%{', '%}', '{', '}' },
    ['}'] = { '%{', '%}', '{', '}' },
    ['<'] = { '<', '>', '<', '>' },
    ['>'] = { '<', '>', '<', '>' },
  }
  
  local left_pattern, right_pattern
  if pairs[char] then
    left_pattern, right_pattern = pairs[char][1], pairs[char][2]
  else
    -- Escape special regex characters for non-paired chars
    local escaped = char:gsub('[%(%)%.%+%-%*%?%[%]%^%$%%]', '%%%1')
    left_pattern, right_pattern = escaped, escaped
  end
  
  -- Remove surrounding characters (first and last occurrence)
  vim.cmd(string.format("'<,'>s/^%s//", left_pattern))
  vim.cmd(string.format("'<,'>s/%s$//", right_pattern))
end, { 
  range = true, 
  nargs = '?',
  desc = "Remove surrounding characters from visual selection"
})
