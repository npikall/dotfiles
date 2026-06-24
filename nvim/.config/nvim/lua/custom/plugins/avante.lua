vim.pack.add {
  'https://github.com/stevearc/dressing.nvim',
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
  {
    src = 'https://github.com/HakonHarnes/img-clip.nvim',
  },
  {
    src = 'https://github.com/yetone/avante.nvim',
  },
}

require('render-markdown').setup {
  file_types = { 'markdown', 'Avante' },
}

require('img-clip').setup {
  default = {
    embed_image_as_base64 = false,
    prompt_for_file_name = false,
    drag_and_drop = { insert_mode = true },
    use_absolute_path = true,
  },
}

require('avante').setup {
  provider = 'openai',
  providers = {
    openai = {
      endpoint = 'https://aqueduct.ai.datalab.tuwien.ac.at/v1',
      model = 'coding',
      api_key_name = 'AQUEDUCT_API_KEY',
      timeout = 30000,
      extra_request_body = {
        temperature = 0,
        max_tokens = 4096,
      },
    },
  },
}
