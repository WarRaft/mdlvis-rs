mod geoset;
mod texture;
mod animation;
mod skeleton;

pub use geoset::*;
pub use texture::*;
pub use animation::*;
pub use skeleton::*;

// Re-export material types from the material module
pub use crate::material::{Material, Layer, FilterMode, ShadingFlags};

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Model {
    pub name: String,
    pub geosets: Vec<Geoset>,
    pub materials: Vec<Material>,
    pub textures: Vec<Texture>,
    pub sequences: Vec<Sequence>,
    pub bones: Vec<Bone>,
    pub helpers: Vec<Helper>,
    pub controllers: Vec<AnimationController>,
}

impl Default for Model {
    fn default() -> Self {
        Self {
            name: String::new(),
            geosets: Vec::new(),
            materials: Vec::new(),
            textures: Vec::new(),
            sequences: Vec::new(),
            bones: Vec::new(),
            helpers: Vec::new(),
            controllers: Vec::new(),
        }
    }
}
