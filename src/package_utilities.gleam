import erl_wrapper
import gleam/dict
import gleam/http/request
import gleam/httpc
import gleam/io
import gleam/result
import gleam/string
import printer
import simplifile
import sorbet

pub fn install_package(package) {
  case package |> string.starts_with("http") {
    True -> fetch_install(package)
    False -> disk_install(package)
  }
}

fn disk_install(path) {
  let contents = case simplifile.read(path) {
    Ok(contents) -> contents
    Error(_) -> printer.tpi_panic("Error reading file!")
  }

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

  printer.info("Installing package: " <> package_name <> " ")
  printer.info("v" <> package_version)
  printer.info("By: " <> author)
  run_commands(commands |> string.split("\n"))
}

fn fetch_install(url) {
  let contents = case fetch_package(url) {
    Ok(contents) -> contents
    Error(_) -> "ERROR_FETCHING_PKG"
  }

  io.println(contents)
  // let package = sorbet.parse(contents)
  // let package_name = case package |> dict.get("name") {
  //   Ok(name) -> name
  //   Error(_) -> panic as "Package has no name!"
  // }
  // let package_version = case package |> dict.get("version") {
  //   Ok(version) -> version
  //   Error(_) -> panic as "Package has no version!"
  // }
  // let author = case package |> dict.get("author") {
  //   Ok(author) -> author
  //   Error(_) -> panic as "Package has no author!"
  // }
  // let commands = case package |> dict.get("commands") {
  //   Ok(commands) -> commands
  //   Error(_) -> panic as "Package has no commands!"
  // }

  // io.print("Installing package: " <> package_name <> " ")
  // io.println("v" <> package_version)
  // io.println("By: " <> author)
  // run_commands(commands |> string.split("\n"))
}

fn run_commands(commands) {
  case commands {
    [] -> Nil
    [command, ..rest] -> {
      printer.info("Running: " <> command)
      printer.cmd(erl_wrapper.run_os_cmd(command))
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
  printer.info("Package: " <> package)
}
