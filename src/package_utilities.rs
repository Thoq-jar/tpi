use anyhow::{Context, Result};
use reqwest::blocking::Client;
use sorbet_kvp::sorbet;
use std::{
    fs::{self},
    process::Command,
};
use tempfile::tempdir;

use crate::printer;

pub fn get_package_list() -> String {
    if cfg!(target_os = "windows") {
        String::from(r"C:\ProgramData\tpi\packages")
    } else {
        String::from("/var/lib/tpi/packages")
    }
}

pub fn install_package(package: &str) -> Result<()> {
    let package_list = get_package_list();

    let is_http = package.starts_with("http");
    let is_local = package.starts_with("./") || package.starts_with("/");

    match (is_http, is_local) {
        (true, _) => fetch_install(package)?,
        (_, true) => disk_install(package)?,
        _ => gleepkg_install(package)?,
    }

    let package_lists = fs::read_to_string(&package_list).unwrap_or_default();

    if sorbet::check_file_extension(package.to_string()) && !package_lists.contains(package) {
        let new_contents = if package_lists.is_empty() {
            package.to_string()
        } else {
            format!("{}\n{}", package_lists.trim(), package)
        };
        fs::write(&package_list, format!("{}\n", new_contents))
            .context("Failed to update package list!")?;
    }

    printer::success(&format!("Installed package: {}!", package));
    Ok(())
}

pub fn upgrade() -> Result<()> {
    printer::info("Upgrading packages...");

    let package_list = get_package_list();
    let package_lists = fs::read_to_string(&package_list).unwrap_or_default();
    let packages: Vec<&str> = package_lists.lines().collect();

    for package in packages {
        if !package.is_empty() {
            printer::info(&format!("Upgrading: {}", package));
            install_package(package)?;
            printer::success(&format!("Upgraded: {}!", package));
        }
    }

    printer::success("Upgraded all packages!");
    Ok(())
}

fn parse_package(
    contents: &str,
) -> Result<(String, String, String, String, String, String, String)> {
    let package = sorbet::parse(contents.to_string());

    let get_field = |field: &str| -> Result<String> {
        package
            .get(field)
            .cloned()
            .context(format!("Package has no {}!", field))
    };

    Ok((
        get_field("name")?,
        get_field("version")?,
        get_field("author")?,
        get_field("unix_deps")?,
        get_field("win_deps")?,
        get_field("commands")?,
        get_field("uninstall")?,
    ))
}

fn disk_install(path: &str) -> Result<()> {
    let contents = fs::read_to_string(path).context("Error reading file!")?;
    let (name, version, author, unix_deps, win_deps, commands, _) = parse_package(&contents)?;

    printer::info(format!("Installing dependencies for {}...", name).as_str());
    if cfg!(target_os = "windows") {
        run_commands(&win_deps)?;
    } else {
        run_commands(&unix_deps)?;
    }

    printer::info(&format!("Installing package: {}", name));
    printer::info(&format!("v{}", version));
    printer::info(&format!("By: {}", author));
    printer::info("Installing dependencies...");
    run_commands(&commands)?;
    Ok(())
}

fn fetch_install(url: &str) -> Result<()> {
    printer::info("Downloading package...");
    let contents = {
        let resp = fetch_package(url)?;
        if resp.to_lowercase().contains("not found") {
            printer::err("Package not found!");
            printer::tip(
                "If you're trying to install a local package, it must be prefixed with './' or '/'",
            );
            std::process::exit(1);
        }

        resp
    };

    let (name, version, author, unix_deps, win_deps, commands, _) = parse_package(&contents)?;

    printer::info(format!("Installing dependencies for {}...", name).as_str());
    if cfg!(target_os = "windows") {
        run_commands(&win_deps)?;
    } else {
        run_commands(&unix_deps)?;
    }

    printer::info(&format!("Installing package: {}", name));
    printer::info(&format!("v{}", version));
    printer::info(&format!("By: {}", author));

    run_commands(&commands)?;
    Ok(())
}

fn gleepkg_install(package: &str) -> Result<()> {
    printer::info("Contacting gleepkg...");
    let url = format!("https://gleepkg.deno.dev/{}.srb", package);
    fetch_install(&url)
}

fn run_commands(commands: &str) -> Result<()> {
    let temp_dir = tempdir()?;
    std::env::set_current_dir(&temp_dir)?;

    for line in commands.lines() {
        if !line.is_empty() {
            for cmd in line.split(',').map(|s| s.trim()) {
                if !cmd.is_empty() {
                    printer::cmd(&format!("{}", cmd));
                    let output = Command::new("sh")
                        .arg("-c")
                        .arg(cmd)
                        .output()
                        .context("Failed to execute command")?;

                    if !output.stdout.is_empty() {
                        printer::cmd(&String::from_utf8_lossy(&output.stdout));
                    }
                }
            }
        }
    }
    Ok(())
}

fn fetch_package(package_url: &str) -> Result<String> {
    let client = Client::new();
    let response = client
        .get(package_url)
        .header("accept", "application/sorbet")
        .send()?;

    Ok(response.text()?)
}

pub fn uninstall_package(package: &str) -> Result<()> {
    if !package.ends_with(".srb") && !package.ends_with(".sorbet") {
        let package_list = get_package_list();
        let package_lists = fs::read_to_string(&package_list).unwrap_or_default();
        let packages: Vec<&str> = package_lists.lines().filter(|&p| p != package).collect();

        let new_contents = packages.join("\n");
        fs::write(&package_list, format!("{}\n", new_contents))
            .context("Failed to update package list!")?;
    }

    if package.starts_with("http") {
        fetch_uninstall(package)?;
    } else {
        disk_uninstall(package)?;
    }

    printer::success(&format!("Uninstalled package: {}!", package));
    Ok(())
}

fn disk_uninstall(path: &str) -> Result<()> {
    let contents = fs::read_to_string(path).context("Error reading file!")?;
    let (name, version, author, _, _, _, uninstall) = parse_package(&contents)?;

    printer::info(&format!("Uninstalling package: {}", name));
    printer::info(&format!("v{}", version));
    printer::info(&format!("By: {}", author));
    run_commands(&uninstall)?;
    Ok(())
}

fn fetch_uninstall(url: &str) -> Result<()> {
    printer::info("Downloading package...");
    let contents = fetch_package(url)?;
    let (name, version, author, _, _, _, uninstall) = parse_package(&contents)?;

    printer::info(&format!("Uninstalling package: {}", name));
    printer::info(&format!("v{}", version));
    printer::info(&format!("By: {}", author));
    run_commands(&uninstall)?;
    Ok(())
}
