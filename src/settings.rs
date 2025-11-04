use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Settings {
    pub show_skeleton: bool,
    pub wireframe_mode: bool,
    pub show_grid: bool,
    pub far_plane: f32, // Distance culling/fog
}

impl Default for Settings {
    fn default() -> Self {
        Self {
            show_skeleton: true,
            wireframe_mode: false,
            show_grid: true,
            far_plane: 1000.0,
        }
    }
}

impl Settings {
    pub fn load() -> Self {
        confy::load("mdlvis-rs", "settings").unwrap_or_else(|e| {
            eprintln!("Failed to load settings: {}, using defaults", e);
            Self::default()
        })
    }

    pub fn save(&self) {
        if let Err(e) = confy::store("mdlvis-rs", "settings", self) {
            eprintln!("Failed to save settings: {}", e);
        }
    }
}
