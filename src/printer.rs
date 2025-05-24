use colored::*;

#[derive(Debug, Clone, Copy)]
#[allow(dead_code)]
pub enum Color {
    Red,
    Yellow,
    Green,
    Purple,
}

pub fn tip(tip: &str) {
    println!("{}{}", "·Tip: ".purple(), tip);
}

pub fn info(message: &str) {
    println!("{}{}", "TPI·Info => ".purple(), message);
}

pub fn cmd(message: &str) {
    println!("{}{}", "  ·Command => ".purple(), message);
}

pub fn err(error: &str) {
    println!("{}{}", "TPI·Fail => ".red(), error);
}

pub fn success(message: &str) {
    println!("{}{}", "TPI·Success: ".green(), message);
}

pub fn colorize(color: Color, message: &str) -> String {
    match color {
        Color::Red => message.red().to_string(),
        Color::Yellow => message.yellow().to_string(),
        Color::Green => message.green().to_string(),
        Color::Purple => message.purple().to_string(),
    }
}
