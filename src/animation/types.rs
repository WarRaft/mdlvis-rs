// Animation data types
// Based on Delphi mdlwork.pas types

use nalgebra_glm as glm;

/// Controller item - single keyframe data
/// From TContItem in mdlwork.pas
#[derive(Debug, Clone)]
pub struct ControllerItem {
    pub frame: i32,                    // Frame number
    pub data: Vec<f32>,                // Data (translation, rotation, scaling, etc.)
    pub in_tan: Vec<f32>,              // In tangent (for Hermite/Bezier interpolation)
    pub out_tan: Vec<f32>,             // Out tangent
}

/// Controller type enumeration
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ControllerType {
    Translation,    // ctTranslation
    Rotation,       // ctRotation
    Scaling,        // ctScaling
    Alpha,          // ctAlpha
    DontInterp,     // Don't interpolate - use nearest frame
    Linear,         // Linear interpolation
    Hermite,        // Hermite (smooth) interpolation
    Bezier,         // Bezier interpolation
}

/// Animation controller
/// From TController in mdlwork.pas
#[derive(Debug, Clone)]
pub struct Controller {
    pub cont_type: ControllerType,     // Type of controller
    pub global_seq_id: i32,            // ID of global sequence (-1 if none)
    pub items: Vec<ControllerItem>,    // Keyframes
}

impl Controller {
    pub fn new(cont_type: ControllerType) -> Self {
        Self {
            cont_type,
            global_seq_id: -1,
            items: Vec::new(),
        }
    }

    /// Get frame data using interpolation
    pub fn get_frame_data(&self, frame: i32) -> Vec<f32> {
        if self.items.is_empty() {
            return vec![0.0; 4]; // Default values
        }

        // Find surrounding keyframes
        let mut before_idx = None;
        let mut after_idx = None;

        for (i, item) in self.items.iter().enumerate() {
            if item.frame <= frame {
                before_idx = Some(i);
            }
            if item.frame >= frame && after_idx.is_none() {
                after_idx = Some(i);
                break;
            }
        }

        // Handle edge cases
        let before_idx = match before_idx {
            Some(idx) => idx,
            None => {
                // Before first frame - use first frame data (base pose)
                return self.items[0].data.clone();
            }
        };

        let after_idx = match after_idx {
            Some(idx) => idx,
            None => {
                // After last frame - use last frame data
                return self.items.last().unwrap().data.clone();
            }
        };

        // Exact frame match
        if before_idx == after_idx {
            return self.items[before_idx].data.clone();
        }

        // Interpolate between frames
        let before = &self.items[before_idx];
        let after = &self.items[after_idx];
        let t = (frame - before.frame) as f32 / (after.frame - before.frame) as f32;

        match self.cont_type {
            ControllerType::DontInterp => before.data.clone(),
            ControllerType::Linear | ControllerType::Translation | 
            ControllerType::Scaling | ControllerType::Alpha => {
                // Linear interpolation
                before.data.iter().zip(after.data.iter())
                    .map(|(b, a)| b + (a - b) * t)
                    .collect()
            }
            ControllerType::Rotation => {
                // SLERP for quaternions
                if before.data.len() >= 4 && after.data.len() >= 4 {
                    let q1 = glm::quat(before.data[3], before.data[0], before.data[1], before.data[2]);
                    let q2 = glm::quat(after.data[3], after.data[0], after.data[1], after.data[2]);
                    let result = glm::quat_slerp(&q1, &q2, t);
                    vec![result.i, result.j, result.k, result.w]
                } else {
                    before.data.clone()
                }
            }
            ControllerType::Hermite | ControllerType::Bezier => {
                // Hermite/Bezier interpolation using tangents
                // Simplified - can be improved with actual Hermite formula
                let t2 = t * t;
                let t3 = t2 * t;
                let h1 = 2.0 * t3 - 3.0 * t2 + 1.0;
                let h2 = -2.0 * t3 + 3.0 * t2;
                let h3 = t3 - 2.0 * t2 + t;
                let h4 = t3 - t2;

                before.data.iter().enumerate().map(|(i, b)| {
                    let a = after.data.get(i).copied().unwrap_or(0.0);
                    let out_t = before.out_tan.get(i).copied().unwrap_or(0.0);
                    let in_t = after.in_tan.get(i).copied().unwrap_or(0.0);
                    h1 * b + h2 * a + h3 * out_t + h4 * in_t
                }).collect()
            }
        }
    }
}

/// Bone transformation state
/// From TBone in mdlwork.pas
#[derive(Debug, Clone)]
pub struct BoneState {
    pub name: String,
    pub object_id: i32,
    pub parent: i32,                   // Parent bone ID (-1 if root)
    
    // Controller indices (-1 if no animation)
    pub translation_idx: i32,
    pub rotation_idx: i32,
    pub scaling_idx: i32,
    pub visibility_idx: i32,
    
    // Billboard flags
    pub is_billboarded: bool,
    pub billboard_lock_x: bool,
    pub billboard_lock_y: bool,
    pub billboard_lock_z: bool,
    pub camera_anchored: bool,
    
    // Current animated values (computed)
    pub is_ready: bool,                // True if already calculated this frame
    pub abs_quaternion: glm::Quat,     // Absolute rotation quaternion
    pub abs_matrix: glm::Mat3,         // Absolute rotation matrix (with scaling)
    pub abs_vector: glm::Vec3,         // Absolute position
    pub abs_scaling: glm::Vec3,        // Absolute scaling
    pub visible: bool,                 // Visibility flag
}

impl Default for BoneState {
    fn default() -> Self {
        Self {
            name: String::new(),
            object_id: 0,
            parent: -1,
            translation_idx: -1,
            rotation_idx: -1,
            scaling_idx: -1,
            visibility_idx: -1,
            is_billboarded: false,
            billboard_lock_x: false,
            billboard_lock_y: false,
            billboard_lock_z: false,
            camera_anchored: false,
            is_ready: false,
            abs_quaternion: glm::quat_identity(),
            abs_matrix: glm::identity(),
            abs_vector: glm::vec3(0.0, 0.0, 0.0),
            abs_scaling: glm::vec3(1.0, 1.0, 1.0),
            visible: true,
        }
    }
}

impl BoneState {
    pub fn new(name: String, object_id: i32) -> Self {
        Self {
            name,
            object_id,
            ..Default::default()
        }
    }
}

/// Texture animation data
/// From TTextureAnim in mdlwork.pas
#[derive(Debug, Clone)]
pub struct TextureAnim {
    pub translation_graph: i32,
    pub rotation_graph: i32,
    pub scaling_graph: i32,
}

impl Default for TextureAnim {
    fn default() -> Self {
        Self {
            translation_graph: -1,
            rotation_graph: -1,
            scaling_graph: -1,
        }
    }
}

/// Geoset animation (color/alpha animation for geosets)
/// From mdlwork.pas GeosetAnims
#[derive(Debug, Clone)]
pub struct GeosetAnim {
    pub geoset_id: i32,
    pub alpha: f32,
    pub is_alpha_static: bool,
    pub alpha_graph: i32,
    pub color: glm::Vec3,
    pub is_color_static: bool,
    pub color_graph: i32,
}

impl Default for GeosetAnim {
    fn default() -> Self {
        Self {
            geoset_id: -1,
            alpha: 1.0,
            is_alpha_static: true,
            alpha_graph: -1,
            color: glm::vec3(1.0, 1.0, 1.0),
            is_color_static: true,
            color_graph: -1,
        }
    }
}
