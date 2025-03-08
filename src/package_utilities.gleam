import erl_wrapper
import gleam/dict
import gleam/http/request
import gleam/httpc
import gleam/result
import gleam/string
import printer
import simplifile
import sorbet

pub fn install_package(package) {
  let is_http = string.starts_with(package, "http")
  let is_local =
    string.starts_with(package, "./") || string.starts_with(package, "/")

  case is_http, is_local {
    True, _ -> fetch_install(package)
    _, True -> disk_install(package)
    _, _ -> gleepkg_install(package)
  }
}

fn parse_package(contents) {
  let package = sorbet.parse(contents)
  let package_name = case package |> dict.get("name") {
    Ok(name) -> name
    Error(_) -> printer.tpi_panic("Package has no name!")
  }
  let package_version = case package |> dict.get("version") {
    Ok(version) -> version
    Error(_) -> printer.tpi_panic("Package has no version!")
  }
  let author = case package |> dict.get("author") {
    Ok(author) -> author
    Error(_) -> printer.tpi_panic("Package has no author!")
  }
  let commands = case package |> dict.get("commands") {
    Ok(commands) -> commands
    Error(_) -> printer.tpi_panic("Package has no commands!")
  }
  let uninstall = case package |> dict.get("uninstall") {
    Ok(uninstall) -> uninstall
    Error(_) -> printer.tpi_panic("Package has no uninstall instructions!")
  }
  #(package_name, package_version, author, commands, uninstall)
}

fn disk_install(path) {
  let contents = case simplifile.read(path) {
    Ok(contents) -> contents
    Error(_) -> printer.tpi_panic("Error reading file!")
  }

  let #(name, version, author, commands, _) = parse_package(contents)
  printer.info("Installing package: " <> name <> " ")
  printer.info("v" <> version)
  printer.info("By: " <> author)
  run_commands(commands |> string.split("\n"))
}

fn fetch_install(url) {
  printer.info("Downloading package...")
  let contents = case fetch_package(url) {
    Ok(contents) -> contents
    Error(_) -> "ERROR_FETCHING_PKG"
  }

  let #(name, version, author, commands, _) = parse_package(contents)
  printer.info("Installing package: " <> name <> " ")
  printer.info("v" <> version)
  printer.info("By: " <> author)
  run_commands(commands |> string.split("\n"))
}

fn gleepkg_install(package) {
  printer.info("Contacting gleepkg...")
  let url = "https://gleepkg.deno.dev/" <> package <> ".srb"
  fetch_install(url)
}

fn run_commands(commands) {
  case commands {
    [] -> Nil
    [command, ..rest] -> {
      printer.info("Running: " <> command)
      let result = erl_wrapper.run_os_cmd(command)
      case result != "" {
        True -> printer.info(result)
        False -> Nil
      }
      run_commands(rest)
    }
  }
}

fn fetch_package(package_url) {
  let assert Ok(base_req) = request.to(package_url)

  let req = request.prepend_header(base_req, "accept", "application/sorbet")

  use resp <- result.try(httpc.send(req))

  Ok(resp.body)
}

pub fn uninstall_package(package) {
  case package |> string.starts_with("http") {
    True -> fetch_uninstall(package)
    False -> disk_uninstall(package)
  }
}

fn disk_uninstall(path) {
  let contents = case simplifile.read(path) {
    Ok(contents) -> contents
    Error(_) -> printer.tpi_panic("Error reading file!")
  }

  let #(name, version, author, _, uninstall) = parse_package(contents)
  printer.info("Uninstalling package: " <> name <> " ")
  printer.info("v" <> version)
  printer.info("By: " <> author)
  run_commands(uninstall |> string.split("\n"))
}

fn fetch_uninstall(url) {
  printer.info("Downloading package...")
  let contents = case fetch_package(url) {
    Ok(contents) -> contents
    Error(_) -> "ERROR_FETCHING_PKG"
  }

  let #(name, version, author, _, uninstall) = parse_package(contents)
  printer.info("Uninstalling package: " <> name <> " ")
  printer.info("v" <> version)
  printer.info("By: " <> author)
  run_commands(uninstall |> string.split("\n"))
}
