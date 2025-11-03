use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Vertex {
    pub position: [f32; 3],
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Normal {
    pub normal: [f32; 3],
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TexCoord {
    pub uv: [f32; 2],
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Face {
    pub vertices: [u32; 3],
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Geoset {
    pub vertices: Vec<Vertex>,
    pub normals: Vec<Normal>,
    pub tex_coords: Vec<TexCoord>,
    pub faces: Vec<Face>,
    pub material_id: Option<usize>,
    pub selection_group: usize,
    pub unselectable: bool,
    pub bounds_radius: f32,
    pub minimum_extent: [f32; 3],
    pub maximum_extent: [f32; 3],
}

impl Default for Geoset {
    fn default() -> Self {
        Self {
            vertices: Vec::new(),
            normals: Vec::new(),
            tex_coords: Vec::new(),
            faces: Vec::new(),
            material_id: None,
            selection_group: 0,
            unselectable: false,
            bounds_radius: 0.0,
            minimum_extent: [0.0; 3],
            maximum_extent: [0.0; 3],
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Material {
    pub layers: Vec<Layer>,
}

impl Default for Material {
    fn default() -> Self {
        Self {
            layers: Vec::new(),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Layer {
    pub texture_id: Option<usize>,
    pub filter_mode: FilterMode,
    pub alpha: f32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum FilterMode {
    Opaque,
    Transparent,
    Blend,
    Additive,
    AddAlpha,
    Modulate,
    Modulate2x,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Texture {
    pub filename: String,
    pub image_data: Option<Vec<u8>>,
    pub width: u32,
    pub height: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Model {
    pub name: String,
    pub geosets: Vec<Geoset>,
    pub materials: Vec<Material>,
    pub textures: Vec<Texture>,
    pub sequences: Vec<Sequence>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Sequence {
    pub name: String,
    pub start_frame: u32,
    pub end_frame: u32,
    pub rarity: Option<u32>,
    pub non_looping: bool,
}

impl Default for Sequence {
    fn default() -> Self {
        Self {
            name: String::new(),
            start_frame: 0,
            end_frame: 0,
            rarity: None,
            non_looping: false,
        }
    }
}

impl Default for Model {
    fn default() -> Self {
        Self {
            name: String::new(),
            geosets: Vec::new(),
            materials: Vec::new(),
            textures: Vec::new(),
            sequences: Vec::new(),
        }
    }
}