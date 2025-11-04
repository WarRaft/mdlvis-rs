/// Material system for handling different material types and their rendering properties
use bytemuck::{Pod, Zeroable};
use crate::model::FilterMode;

/// Material uniform data that matches WGSL structure
#[repr(C)]
#[derive(Copy, Clone, Pod, Zeroable)]
pub struct MaterialUniform {
    pub team_color_and_flags: [f32; 4], // team_color.xyz + use_team_color
    pub material_type_and_wireframe: [f32; 4], // filter_mode + wireframe_mode + padding
    pub extra_padding: [f32; 4], // Additional padding for alignment
}

impl MaterialUniform {
    /// Create material uniform for normal rendering (no team color)
    pub fn normal(wireframe_mode: bool, filter_mode: FilterMode) -> Self {
        Self {
            team_color_and_flags: [1.0, 1.0, 1.0, 0.0], // white color, no team color
            material_type_and_wireframe: [
                filter_mode_to_f32(filter_mode),
                if wireframe_mode { 1.0 } else { 0.0 },
                0.0,
                0.0
            ],
            extra_padding: [0.0, 0.0, 0.0, 0.0],
        }
    }

    /// Create material uniform for team color rendering
    pub fn team_color(team_color: [f32; 3], wireframe_mode: bool, filter_mode: FilterMode) -> Self {
        Self {
            team_color_and_flags: [team_color[0], team_color[1], team_color[2], 1.0], // team color enabled
            material_type_and_wireframe: [
                filter_mode_to_f32(filter_mode),
                if wireframe_mode { 1.0 } else { 0.0 },
                0.0,
                0.0
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