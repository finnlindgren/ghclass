# If we are given a single repo directory check if it is a repo or a directory of repos
repo_dir_helper = function(repo_dir) {
  arg_is_chr(repo_dir)

  if (length(repo_dir) == 1 & !fs::dir_exists(fs::path(repo_dir[1],".git"))) {
    dir = fs::dir_ls(repo_dir, type="directory")
  } else {
    dir = repo_dir
  }

  fs::path_real(dir)
}

censor_token = function(msg, replacement = "", prefix="", suffix="") {
  pattern = paste0(prefix, github_get_token(), suffix)
  sub(pattern, replacement, msg)
}

run_git = function(git = require_git(), cmd, args = character(), verbose=FALSE) {
  stopifnot(!missing(cmd))

  res = processx::run(
    git, args  = c(cmd, args), error_on_status = FALSE, echo = verbose, echo_cmd = verbose
  )

  err_msg = res[["stderr"]]
  err_msg = sub("fatal: ", "", err_msg)
  err_msg = sub("^\\s|\\s$", "", err_msg)
  err_msg = censor_token(err_msg, suffix="@")

  if (res[["status"]] != 0)
    stop(err_msg)

  res
}