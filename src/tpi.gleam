import argv
import gleam/io
import package_utilities
import printer

pub const usage = "Usage: tpi [command] [...args]"

pub const help = "
Commands:
  install     Install a package
  uninstall   Uninstall a package
  help        Show this menu

Args:
  package     Package to install/uninstall
  help        Has no args
"

pub fn main() {
  case argv.load().arguments {
    ["install", package] -> package_utilities.install_package(package)
    ["uninstall", package] -> package_utilities.uninstall_package(package)
    ["help"] -> {
      io.print(usage)
      io.print(help)
    }
    _ -> {
      printer.info(usage)
      printer.tip("Use 'help' command for help!")
    }
  }
}
