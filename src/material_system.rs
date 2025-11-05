/// Material system for handling different material types and their rendering properties
use bytemuck::{Pod, Zeroable};
use crate::model::FilterMode;

/// Material uniform data that matches WGSL structure
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
pub struct MaterialUniform {
    pub team_color: [f32; 4], // team_color.rgb + replaceable_id (0=none, 1=team_color, 2=team_glow)
    pub material_type_and_wireframe: [f32; 4], // filter_mode + wireframe_mode + layer_alpha + shading_flags
    pub extra_padding: [f32; 4], // Padding for alignment
}

impl MaterialUniform {
    /// Create material uniform for rendering
    pub fn new(team_color: [f32; 3], replaceable_id: u32, wireframe_mode: bool, filter_mode: FilterMode, layer_alpha: f32, shading_flags: u32) -> Self {
        Self {
            team_color: [
                team_color[0],
                team_color[1],
                team_color[2],
                replaceable_id as f32,
            ],
            material_type_and_wireframe: [
                filter_mode_to_f32(filter_mode),
                if wireframe_mode { 1.0 } else { 0.0 },
                layer_alpha,
                shading_flags as f32,
            ],
            extra_padding: [0.0, 0.0, 0.0, 0.0],
        }
    }
}

/// Convert FilterMode enum to f32 for shader
fn filter_mode_to_f32(filter_mode: FilterMode) -> f32 {
    match filter_mode {
        FilterMode::Opaque => 0.0,
        FilterMode::Transparent => 1.0,
        FilterMode::Blend => 2.0,
        FilterMode::Additive => 3.0,
        FilterMode::AddAlpha => 4.0,
        FilterMode::Modulate => 5.0,
        FilterMode::Modulate2x => 6.0,
    }
}