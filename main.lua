vim.lsp.start({
    name = 'pg_lsp',
    cmd = {'escript.exe', 'C:\\Users\\geenk\\projects\\pg_lsp\\pg_lsp.escript'},
    root_dir = vim.fs.dirname(vim.fs.find({'mix.exs'})[1]),
})
