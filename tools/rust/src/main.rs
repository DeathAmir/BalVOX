use std::{env, fs};

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        println!("BalVOX telemetry validator 0.2.0");
        println!("Usage: balvox-telemetry <settings.json>");
        return;
    }
    let path = &args[1];
    match fs::read_to_string(path) {
        Ok(data) => match data.parse::<serde_json::Value>() {
            Ok(value) => {
                let quality = value.get("quality").and_then(|v| v.as_i64()).unwrap_or(1);
                let speed = value.get("speed").and_then(|v| v.as_f64()).unwrap_or(16.0);
                println!("VALID quality={} camera_speed={:.1}", quality, speed);
            }
            Err(error) => {
                eprintln!("INVALID JSON: {}", error);
                std::process::exit(2);
            }
        },
        Err(error) => {
            eprintln!("Cannot read settings: {}", error);
            std::process::exit(1);
        }
    }
}
