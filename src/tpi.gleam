import argv
import gleam/io
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
  io.println(printer.colorize(printer.Purple, "TPI v1.2.0"))
}

fn print_usage() {
  let usage = printer.colorize(printer.Green, "Usage: ")
  let usage_args = printer.colorize(printer.Purple, "[command] [...args]")

  io.println(usage <> usage_args)
}

// it looks gross in code but good in terminal
// shut up
fn print_help() {
  let commands =
    string.concat([printer.colorize(printer.Green, "Commands:"), "\n"])
  let install =
    string.concat([
      printer.colorize(printer.Purple, "  install     <package> "),
      printer.colorize(printer.Green, "     Install a package"),
      "\n",
    ])
  let uninstall =
    string.concat([
      printer.colorize(printer.Purple, "  uninstall   <package>"),
      printer.colorize(printer.Green, "      Uninstall a package"),
      "\n",
    ])
  let help =
    string.concat([
      printer.colorize(printer.Purple, "  help"),
      printer.colorize(
        printer.Green,
        "                       Shows this screen",
      ),
      "\n",
    ])

  io.println(string.concat([commands, install, uninstall, help]))
}
