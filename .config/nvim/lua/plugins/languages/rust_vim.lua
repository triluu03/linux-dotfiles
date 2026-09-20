---Lazy plugin specification for rust.vim.
return {
	"rust-lang/rust.vim",
	ft = "rust",
	init = function()
		vim.g.rustfmt_autosave = 1
	end,
}
