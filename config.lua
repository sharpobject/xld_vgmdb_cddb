local config = require("lapis.config")

config("development", {
  port = 8000,
  num_workers = 1,
  code_cache = "on"
})

config("production", {
  port = 8000,
  num_workers = 1,
  code_cache = "on"
})