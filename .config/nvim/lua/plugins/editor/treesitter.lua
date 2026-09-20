---Lazy plugin specification for nvim-treesitter on Neovim 0.12 and newer.
---NOTE: https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md
local parsers = {
	"rust",
	"python",
	"elixir",
	"haskell",
	--
	"bash",
	"c",
	"diff",
	--
	"gitignore",
	"godot_resource",
	--
	"lua",
	"luadoc",
	--
	"make",
	"markdown",
	"markdown_inline",
	"query",
	--
	"requirements",
	--
	"vim",
	"vimdoc",
	--
	"toml",
	"yaml",
	--
	"jsdoc",
	"json",
	"javascript",
	"typescript",
	"tsx",
	"jsx",
	"html",
}

---Return the Tree-sitter language associated with a buffer's filetype.
---@param bufnr integer Buffer whose filetype should be resolved.
---@return string|nil language Configured parser language, if supported.
local function configured_language(bufnr)
	local language = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
	if language == nil or not vim.tbl_contains(parsers, language) then
		return nil
	end

	return language
end

---Enable Tree-sitter highlighting and indentation for a configured buffer.
---@param event { buf: integer } FileType autocommand event.
local function enable_treesitter(event)
	local language = configured_language(event.buf)
	if language == nil then
		return
	end

	-- Parser installation is asynchronous, so a newly installed parser may only
	-- become available the next time its filetype is opened.
	local started = pcall(vim.treesitter.start, event.buf, language)
	if not started then
		return
	end

	local has_indents, indent_query = pcall(vim.treesitter.query.get, language, "indents")
	if has_indents and indent_query ~= nil then
		vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
end

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").install(parsers)

		vim.api.nvim_create_autocmd("FileType", {
			desc = "Enable Tree-sitter features for configured languages",
			group = vim.api.nvim_create_augroup("config-treesitter", { clear = true }),
			callback = enable_treesitter,
		})
	end,
}
