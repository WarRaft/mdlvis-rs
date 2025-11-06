use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Texture {
    pub filename: String,
    pub replaceable_id: u32, // 0 = normal texture, 1 = team color, 2 = team glow, etc.
    pub image_data: Option<Vec<u8>>,
    pub width: u32,
    pub height: u32,
}
