return {
	"johnseth97/codex.nvim",
	lazy = true,
	cmd = { "Codex", "CodexToggle" },
	keys = {
		{ "<leader>cc", function() require("codex").toggle() end, desc = "Toggle Codex", mode = { "n", "t" } },
	},
	opts = {
		keymaps = {
			toggle = nil,
			quit = "<C-q>",
		},
		border = "double",
		width = 0.33,
		height = 0.8,
		model = nil,
		autoinstall = false, -- codex already in ~/.local/bin
		panel = true, -- side-panel (vertical split) like claude/opencode setup
		use_buffer = false,
	},
	config = function(_, opts)
		local codex = require("codex")
		codex.setup(opts)

		-- Plugin hardcodes the panel to the right; move it to the left like claudecode
		local orig_open = codex.open
		codex.open = function(...)
			orig_open(...)
			if opts.panel and vim.bo.filetype == "codex" then
				vim.cmd("wincmd H")
				vim.api.nvim_win_set_width(0, math.floor(vim.o.columns * opts.width))
			end
		end

		-- herdr/tmux navigation inside codex terminal
		vim.api.nvim_create_autocmd("TermOpen", {
			callback = function(ev)
				if not vim.api.nvim_buf_get_name(ev.buf):find("codex") then return end
				local nav = require("meon.util.herdr-nav").nav
				local esc = vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, false, true)
				local function tnav(wincmd, dir)
					return function()
						vim.api.nvim_feedkeys(esc, "n", false)
						vim.schedule(function() nav(wincmd, dir) end)
					end
				end
				local o = { buffer = ev.buf, silent = true }
				vim.keymap.set("t", "<C-h>", tnav("h", "left"), o)
				vim.keymap.set("t", "<C-j>", tnav("j", "down"), o)
				vim.keymap.set("t", "<C-k>", tnav("k", "up"), o)
				vim.keymap.set("t", "<C-l>", tnav("l", "right"), o)
			end,
		})
	end,
}
