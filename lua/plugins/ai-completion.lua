return {
  "milanglacier/minuet-ai.nvim",
  lazy = true,
  config = function(_, opts)
    require("minuet").setup(opts)
  end,
  opts = {
    provider = "openai_fim_compatible",
    context_window = 512,
    provider_options = {
      openai_fim_compatible = {
        api_key = "TERM",
        name = "Ollama",
        end_point = "http://localhost:11434/v1/completions",
        model = "qwen2.5-coder:14b",
        optional = {
          max_tokens = 56,
          top_p = 0.9,
        },
      },
    },
  },
}
