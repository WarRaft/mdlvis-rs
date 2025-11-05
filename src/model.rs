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
    // Animation data
    pub vertex_groups: Vec<u8>,      // GNDX: Index into matrix_groups for each vertex
    pub matrix_groups: Vec<Vec<u32>>, // MTGC+MATS: Groups of bone indices
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
            vertex_groups: Vec::new(),
            matrix_groups: Vec::new(),
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
    pub shading_flags: Vec<ShadingFlags>, // Parsed shading flags
    pub alpha: f32,
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub enum ShadingFlags {
    Unshaded = 0x1,
    SphereEnvMap = 0x2,
    TwoSided = 0x10,
    Unfogged = 0x20,
    NoDepthTest = 0x40,
    NoDepthSet = 0x80,
}

impl ShadingFlags {
    /// Get all flags present in the bitfield
    pub fn from_bits(bits: u32) -> Vec<Self> {
        let mut flags = Vec::new();
        if bits & Self::Unshaded as u32 != 0 {
            flags.push(Self::Unshaded);
        }
        if bits & Self::SphereEnvMap as u32 != 0 {
            flags.push(Self::SphereEnvMap);
        }
        if bits & Self::TwoSided as u32 != 0 {
            flags.push(Self::TwoSided);
        }
        if bits & Self::Unfogged as u32 != 0 {
            flags.push(Self::Unfogged);
        }
        if bits & Self::NoDepthTest as u32 != 0 {
            flags.push(Self::NoDepthTest);
        }
        if bits & Self::NoDepthSet as u32 != 0 {
            flags.push(Self::NoDepthSet);
        }
        flags
    }

    /// Convert array of flags back to bitfield
    pub fn to_bits(flags: &[Self]) -> u32 {
        let mut bits = 0u32;
        for flag in flags {
            bits |= *flag as u32;
        }
        bits
    }

    /// Get human-readable name
    pub fn name(&self) -> &'static str {
        match self {
            Self::Unshaded => "Unshaded",
            Self::SphereEnvMap => "SphereEnv",
            Self::TwoSided => "TwoSided",
            Self::Unfogged => "Unfogged",
            Self::NoDepthTest => "NoDepthTest",
            Self::NoDepthSet => "NoDepthSet",
        }
    }
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
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
    pub replaceable_id: u32, // 0 = normal texture, 1 = team color, 2 = team glow, etc.
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
    pub bones: Vec<Bone>,
    pub helpers: Vec<Helper>,
    pub controllers: Vec<AnimationController>,
}

/// Animation controller data (keyframes)
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AnimationController {
    pub interpolation_type: u32, // 0=None, 1=Linear, 2=Hermite, 3=Bezier
    pub global_seq_id: i32,
    pub keyframes: Vec<Keyframe>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Keyframe {
    pub frame: i32,
    pub data: Vec<f32>,
    pub in_tan: Vec<f32>,
    pub out_tan: Vec<f32>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Sequence {
    pub name: String,
    pub start_frame: u32,
    pub end_frame: u32,
    pub rarity: Option<u32>,
    pub non_looping: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Bone {
    pub name: String,
    pub object_id: u32,
    pub parent_id: i32, // -1 means no parent
    pub pivot_point: [f32; 3],
    pub geoset_id: Option<u32>,
    pub geoset_anim_id: Option<u32>,
    // Animation controller indices (-1 if not animated)
    pub translation_idx: i32,
    pub rotation_idx: i32,
    pub scaling_idx: i32,
    pub visibility_idx: i32,
}

impl Default for Bone {
    fn default() -> Self {
        Self {
            name: String::new(),
            object_id: 0,
            parent_id: -1,
            pivot_point: [0.0, 0.0, 0.0],
            geoset_id: None,
            geoset_anim_id: None,
            translation_idx: -1,
            rotation_idx: -1,
            scaling_idx: -1,
            visibility_idx: -1,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Helper {
    pub name: String,
    pub object_id: u32,
    pub parent_id: i32, // -1 means no parent
    pub pivot_point: [f32; 3],
    // Animation controller indices
    pub translation_idx: i32,
    pub rotation_idx: i32,
    pub scaling_idx: i32,
    pub visibility_idx: i32,
}

impl Default for Helper {
    fn default() -> Self {
        Self {
            name: String::new(),
            object_id: 0,
            parent_id: -1,
            pivot_point: [0.0, 0.0, 0.0],
            translation_idx: -1,
            rotation_idx: -1,
            scaling_idx: -1,
            visibility_idx: -1,
        }
    }
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
            bones: Vec::new(),
            helpers: Vec::new(),
            controllers: Vec::new(),
        }
    }
}