import argv
import gleam/io
import gleam/list
import gleam/string
import package_utilities
import printer

pub fn main() {
  case argv.load().arguments {
    ["install", package] -> package_utilities.install_package(package)
    ["uninstall", package] -> package_utilities.uninstall_package(package)
    ["help"] -> {
      print_usage()
      print_help()
    }
    ["version"] -> print_version()
    _ -> {
      print_usage()
      printer.tip("Use 'help' command for help!")
    }
  }
}

fn print_version() {
  io.println(printer.colorize(printer.Purple, "The Package Index v1.2.0"))
}

fn print_usage() {
  let usage = printer.colorize(printer.Green, "Usage: ")
  let usage_args = printer.colorize(printer.Purple, "[command] [...args]")

  io.println(usage <> usage_args)
}

fn print_help() {
  let commands = [
    #("install", "   <package>", "Install a package"),
    #("uninstall", " <package>", "Uninstall a package"),
    #("help", "", "Shows this screen"),
  ]

  let header = printer.colorize(printer.Green, "Commands:") <> "\n"
  let formatted_commands =
    commands
    |> list.map(fn(cmd) {
      let #(name, args, desc) = cmd
      let command = string.pad_end(name <> " " <> args, 20, " ")
      string.concat([
        "  ",
        printer.colorize(printer.Purple, command),
        "  ",
        printer.colorize(printer.Green, desc),
        "\n",
      ])
    })
    |> string.concat

  io.println(header <> formatted_commands)
}
