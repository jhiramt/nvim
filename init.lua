-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.diagnostic.enable = true
vim.diagnostic.config({
  virtual_lines = true,
})

-- Open netrw's explorer (netrw is bundled with Neovim 0.10+)
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("n", "<leader>gn", ":Gen<CR>")

-- [[ Install `lazy.nvim` plugin manager ]]
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },


  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets
          -- This step is not supported in many windows environments
          -- Remove the below condition to re-enable on windows
          if vim.fn.has 'win32' == 1 then
            return
          end
          return 'make install_jsregexp'
        end)(),
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',

      -- Adds a number of user-friendly snippets
      -- 'rafamadriz/friendly-snippets',
    },
  },

  { -- Useful plugin to show you pending keybinds.
      'folke/which-key.nvim',
      event = 'VimEnter', -- Sets the loading event to 'VimEnter'
      config = function() -- This is the function that runs, AFTER loading
        require('which-key').setup()
        -- Document existing key chains
        require('which-key').add {
          { '<leader>s', group = '[S]earch' },
          { '<leader>w', group = '[W]orkspace' },
          { '<leader>t', group = '[T]oggle' },
          { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        }
      end,
    },

  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>hb', function()
          gs.blame_line { full = false }
        end, { desc = 'git blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>hD', function()
          gs.diffthis '~'
        end, { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- NOTE: `main = 'ibl'` is required on ibl v3. Without it lazy.nvim resolves the
    -- deprecated v2 entrypoint, whose setup() only raises a migration error.
    main = 'ibl',
    -- See `:help ibl`
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    -- The `master` branch is archived (final commit: "announce archiving of
    -- master branch", v0.10.0) and is incompatible with Neovim 0.12's
    -- treesitter API -- its `set-lang-from-info-string!` injection directive
    -- throws "attempt to call method 'range' (a nil value)" whenever an LSP
    -- hover float is rendered. `main` is the maintained rewrite.
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false, -- upstream: "This plugin does not support lazy-loading."
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
    },
    build = ':TSUpdate',
  },

-- vimtex
'lervag/vimtex',

  -- Custom Parameters (with defaults)

{
    "David-Kunz/gen.nvim",
    opts = {
        model = "mistral:7b", -- The default model to use.
        quit_map = "q", -- set keymap to close the response window
        retry_map = "<c-r>", -- set keymap to re-send the current prompt
        accept_map = "<c-cr>", -- set keymap to replace the previous selection with the last result
        host = "localhost", -- The host running the Ollama service.
        port = "11434", -- The port on which the Ollama service is listening.
        display_mode = "float", -- The display mode. Can be "float" or "split" or "horizontal-split".
        show_prompt = true, -- Shows the prompt submitted to Ollama.
        show_model = true, -- Displays which model you are using at the beginning of your chat session.
        no_auto_close = false, -- Never closes the window automatically.
        file = false, -- Write the payload to a temporary file to keep the command short.
        hidden = false, -- Hide the generation window (if true, will implicitly set `prompt.replace = true`), requires Neovim >= 0.10
        init = function(options) pcall(io.popen, "ollama serve > /dev/null 2>&1 &") end,
        -- Function to initialize Ollama
        command = function(options)
            local body = {model = options.model, stream = true}
            return "curl --silent --no-buffer -X POST http://" .. options.host .. ":" .. options.port .. "/api/chat -d $body"
        end,
        -- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
        -- This can also be a command string.
        -- The executed command must return a JSON object with { response, context }
        -- (context property is optional).
        -- list_models = '<omitted lua function>', -- Retrieves a list of model names
        debug = false -- Prints errors and the command which is run.
    }
},

}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!





-- set theme
vim.cmd 'colorscheme habamod'

-- set linebreak
vim.cmd "set lbr"


-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers defaultcolor
vim.wo.number = true

 -- Enable relative line numbers
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = false

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
-- NOTE: `goto_prev`/`goto_next` are deprecated and go away in 0.13; use `jump`.
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -1 }
end, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = 1 }
end, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end
vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- NOTE: this is NOT deferred. `install_dir` is prepended to 'runtimepath' by
-- setup(), and a FileType autocmd registered on the next event-loop tick would
-- miss the first buffer when running `nvim {filename}` -- leaving that file
-- with no highlighting at all.
require('nvim-treesitter').setup {
  -- Parsers and queries live here now, not in the plugin directory.
  -- The 18 languages below are installed with :TSInstall (upstream removed
  -- `ensure_installed`; there is no auto-install on this branch).
  install_dir = vim.fn.stdpath('data') .. '/site',
}

-- Highlighting is provided by Neovim, not by nvim-treesitter, and is opt-in:
-- Neovim 0.12 does not start a highlighter on its own. Without this, every
-- token falls back to Normal and code renders in a single flat colour.
vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'bash', 'c', 'cpp', 'diff', 'go', 'html', 'javascript', 'lua', 'luadoc',
    'markdown', 'python', 'query', 'rust', 'tsx', 'typescript', 'vim', 'vimdoc',
  },
  callback = function()
    vim.treesitter.start()
  end,
})

-- Treesitter indentation is experimental upstream, so it is enabled only where
-- the builtin is weak. c/cpp/lua deliberately keep cindent and their own
-- indent rules.
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'bash', 'html', 'markdown', 'python' },
  callback = function(args)
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- Textobjects moved to their own plugin, and setup() now takes options only --
-- every keymap has to be declared explicitly. They are registered per buffer so
-- they stay scoped to these filetypes, matching the old `enable = true`.
require('nvim-treesitter-textobjects').setup {
  select = { lookahead = true }, -- automatically jump forward to textobj, like targets.vim
  move = { set_jumps = true },   -- whether to set jumps in the jumplist
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'bash', 'c', 'cpp', 'diff', 'go', 'html', 'javascript', 'lua', 'luadoc',
    'markdown', 'python', 'query', 'rust', 'tsx', 'typescript', 'vim', 'vimdoc',
  },
  callback = function(args)
    local buf = args.buf

    local function selmap(lhs, q, desc)
      for _, mode in ipairs { 'x', 'o' } do
        vim.keymap.set(mode, lhs, function()
          require('nvim-treesitter-textobjects.select')
            .select_textobject(q, 'textobjects', mode == 'x' and 'v' or 'o')
        end, { buffer = buf, desc = desc, silent = true })
      end
    end

    local function mvmap(lhs, mod, q, desc)
      vim.keymap.set('n', lhs, function()
        require('nvim-treesitter-textobjects.move')[mod](q, 'textobjects')
      end, { buffer = buf, desc = desc, silent = true })
    end

    local function swmap(lhs, mod, q, desc)
      vim.keymap.set('n', lhs, function()
        require('nvim-treesitter-textobjects.swap')[mod](q)
      end, { buffer = buf, desc = desc, silent = true })
    end

    -- You can use the capture groups defined in textobjects.scm
    selmap('aa', '@parameter.outer', 'parameter outer')
    selmap('ia', '@parameter.inner', 'parameter inner')
    selmap('af', '@function.outer', 'function outer')
    selmap('if', '@function.inner', 'function inner')
    selmap('ac', '@class.outer', 'class outer')
    selmap('ic', '@class.inner', 'class inner')

    mvmap(']m', 'goto_next_start', '@function.outer', 'next function start')
    mvmap(']]', 'goto_next_start', '@class.outer', 'next class start')
    mvmap(']M', 'goto_next_end', '@function.outer', 'next function end')
    mvmap('][', 'goto_next_end', '@class.outer', 'next class end')
    mvmap('[m', 'goto_previous_start', '@function.outer', 'prev function start')
    mvmap('[[', 'goto_previous_start', '@class.outer', 'prev class start')
    mvmap('[M', 'goto_previous_end', '@function.outer', 'prev function end')
    mvmap('[]', 'goto_previous_end', '@class.outer', 'prev class end')

    swmap('<leader>a', 'swap_next', '@parameter.inner', 'swap next parameter')
    swmap('<leader>A', 'swap_previous', '@parameter.inner', 'swap previous parameter')
  end,
})

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local map = function(mode, keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
  end
  local nmap = function(keys, func, desc)
    map('n', keys, func, desc)
  end
  local xmap = function(keys, func, desc)
    map('x', keys, func, desc)
  end

  local code_action = function()
    vim.lsp.buf.code_action { context = { only = { 'quickfix', 'refactor', 'source' } } }
  end

  nmap('grn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('gra', code_action, '[C]ode [A]ction')
  xmap('gra', code_action, '[C]ode [A]ction')

  nmap('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('grt', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('gO', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
  nmap('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

  -- Lesser used LSP functionality
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })

  if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, bufnr) then
    nmap('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }, { bufnr = bufnr })
    end, '[T]oggle Inlay [H]ints')
  end
end

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. Per-server `settings`
--  and other keys are passed straight to `vim.lsp.config`, so consult the language server's
--  own documentation. The default filetypes and root markers come from nvim-lspconfig.
local servers = {
  clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- NOTE: this is `ts_ls`, not `tsserver` -- nvim-lspconfig renamed it, and only
  -- lspconfig server names are valid in `ensure_installed` (it maps to the
  -- `typescript-language-server` mason package).
  ts_ls = {
    -- The upstream data config also lists `javascript.jsx` and `typescript.tsx`,
    -- which no filetype detection ever produces; they make `:checkhealth vim.lsp`
    -- warn. The real ones are `javascriptreact` / `typescriptreact`.
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  },

  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        workspace = {
          checkThirdParty = false,
          -- Tell lua_ls about Neovim's own runtime so it resolves `vim.*` here.
          library = { vim.env.VIMRUNTIME },
        },
        telemetry = { enable = false },
        -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
        -- diagnostics = { disable = { 'missing-fields' } },
      },
    },
  },
}

-- NOTE: mason-lspconfig v2 dropped the `handlers` API, so servers are configured through
-- Neovim's native `vim.lsp.config`. These MUST be registered before the `setup()` call
-- below, which enables the servers -- config added afterwards never reaches a client that
-- is already running.
vim.lsp.config('*', {
  capabilities = capabilities,
})

for server_name, server_config in pairs(servers) do
  vim.lsp.config(server_name, server_config)
end

-- NOTE: `on_attach` is deliberately NOT set via `vim.lsp.config('*')`. Per `:help
-- lsp-config-merge`, the '*' config has the *lowest* priority, so any server whose
-- `lsp/<name>.lua` defines its own `on_attach` (clangd, pyright, eslint, texlab,
-- ts_ls, ...) would silently drop ours. Driving it from `LspAttach` instead runs for
-- every server and composes with a server's own `on_attach` instead of replacing it.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      on_attach(client, args.buf)
    end
  end,
})

local server_names = vim.tbl_keys(servers)

-- Ensure the servers above are installed and enabled
require('mason-lspconfig').setup {
  ensure_installed = server_names,
  automatic_enable = server_names,
}
-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
