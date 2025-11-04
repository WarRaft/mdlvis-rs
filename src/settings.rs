use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Settings {
    pub show_skeleton: bool,
    pub wireframe_mode: bool,
    pub show_grid: bool,
    pub show_bounding_box: bool,
    pub far_plane: f32, // Distance culling/fog
    
    // Color settings
    pub team_color: [f32; 3], // RGB team color
    pub skybox_color: [f32; 3], // RGB background/skybox color  
    pub grid_major_color: [f32; 3], // RGB major grid lines (every 64 units)
    pub grid_minor_color: [f32; 3], // RGB minor grid lines (every 8 units)
    pub bounding_box_color: [f32; 3], // RGB bounding box color
}

impl Default for Settings {
    fn default() -> Self {
        Self {
            show_skeleton: true,
            wireframe_mode: false,
            show_grid: true,
            show_bounding_box: false,
            far_plane: 1000.0,
            
            // Default colors
            team_color: [1.0, 0.0, 0.0], // Red team color
            skybox_color: [0.3, 0.5, 0.8], // Light blue skybox
            grid_major_color: [0.2, 0.2, 0.2], // Dark gray major grid lines
            grid_minor_color: [0.4, 0.4, 0.4], // Light gray minor grid lines
            bounding_box_color: [1.0, 1.0, 0.0], // Yellow bounding box
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
