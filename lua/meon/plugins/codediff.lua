-- Close the first open CodeDiff tab, if any. Returns true when one was closed.
local function close_open_diff()
	-- Plugin lazy-loads; if the session module was never required, nothing is open.
	local session = package.loaded["codediff.ui.lifecycle.session"]
	if not session then
		return false
	end

	for tabpage in pairs(session.get_active_diffs()) do
		if vim.api.nvim_tabpage_is_valid(tabpage) then
			return require("codediff.ui.lifecycle").close(tabpage) ~= false
		end
	end

	return false
end

-- Open `cmd`, or close the existing CodeDiff tab if one is already up.
local function toggle(cmd)
	return function()
		if not close_open_diff() then
			vim.cmd(cmd)
		end
	end
end

return {
	"esmuellert/codediff.nvim",
	cmd = "CodeDiff",
	keys = {
		{
			"<leader>gv",
			toggle("CodeDiff origin/main..."),
			desc = "CodeDiff vs origin/main (PR diff)",
		},
	},
	opts = {
		diff = {
			layout = "inline", -- unified diff in one window instead of side-by-side
		},
		keymaps = {
			view = {
				next_hunk = "n",
				prev_hunk = "p",
				next_file = "N",
				prev_file = "P",
			},
		},
	},
}
