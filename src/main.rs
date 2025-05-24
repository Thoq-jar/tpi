mod package_utilities;
mod printer;

use std::env;
use printer::{Color, colorize};

fn print_version() {
    println!("{}", colorize(Color::Purple, format!("The Package Index v{}", env!("CARGO_PKG_VERSION")).as_str()));
}

fn print_usage() {
    let usage = colorize(Color::Green, "Usage: ");
    let usage_args = colorize(Color::Purple, "[command] [...args]");
    println!("{}{}", usage, usage_args);
}

fn print_help() {
    let commands = [
        ("install", "   <package>", "Install a package"),
        ("uninstall", " <package>", "Uninstall a package"),
        ("upgrade", "", "Upgrade packages"),
        ("help", "", "Shows this screen"),
        ("version", "", "Shows version of cli"),
    ];

    let header = format!("{}\n", colorize(Color::Green, "Commands:"));
    let formatted_commands: String = commands
        .iter()
        .map(|(name, args, desc)| {
            let command = format!("{} {}", name, args);
            format!(
                "  {:<20}  {}\n",
                colorize(Color::Purple, &command),
                colorize(Color::Green, desc)
            )
        })
        .collect();

    print!("{}{}", header, formatted_commands);
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let result = match args.get(1).map(String::as_str) {
        Some("install") => {
            args.get(2)
                .map(|package| package_utilities::install_package(package))
                .unwrap_or_else(|| {
                    print_usage();
                    printer::tip("Use 'help' command for help!");
                    Ok(())
                })
        }
        Some("uninstall") => {
            args.get(2)
                .map(|package| package_utilities::uninstall_package(package))
                .unwrap_or_else(|| {
                    print_usage();
                    printer::tip("Use 'help' command for help!");
                    Ok(())
                })
        }
        Some("upgrade") => package_utilities::upgrade(),
        Some("help") => {
            print_usage();
            print_help();
            Ok(())
        }
        Some("version") => {
            print_version();
            Ok(())
        }
        _ => {
            print_usage();
            printer::tip("Use 'help' command for help!");
            Ok(())
        }
    };

    if let Err(e) = result {
        printer::err(&format!("{:#}", e));
        std::process::exit(1);
    }
}
