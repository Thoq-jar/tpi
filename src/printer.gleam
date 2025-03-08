import gleam/io
import gleam/string

pub type Color {
  Red
  Yellow
  Green
  Purple
}

pub fn tip(tip) {
  io.println(colorize(Purple, "Tip: ") <> tip)
}

pub fn info(message) {
  io.println(colorize(Purple, "Info => ") <> message)
}

pub fn cmd(message) {
  io.println(colorize(Purple, "  Command => ") <> message)
}

pub fn warn(warning) {
  io.println(colorize(Yellow, "Warn => ") <> warning)
}

pub fn err(error) {
  io.println(colorize(Red, "Err => ") <> error)
}

pub fn sucess(message) {
  io.println(colorize(Green, "Sucess: ") <> message)
}

pub fn tpi_panic(panic_msg) {
  panic as string.concat([colorize(Red, "Fatal Error: "), panic_msg])
}

pub fn colorize(color, message) {
  case color {
    Red -> "\u{001b}[31m" <> message <> "\u{001b}[0m"
    Yellow -> "\u{001b}[33m" <> message <> "\u{001b}[0m"
    Green -> "\u{001b}[32m" <> message <> "\u{001b}[0m"
    Purple -> "\u{001b}[35m" <> message <> "\u{001b}[0m"
  }
}
