// Skeleton bone calculations
// Based on InterpTBone and CalcTBone from mdlDraw.pas (lines 2134-2307)

use super::types::*;
use super::controller::*;
use super::interpolation::*;
use nalgebra_glm as glm;

/// Interpolate bone state for given frame
/// Based on InterpTBone procedure (mdlDraw.pas line 2134)
pub fn interp_bone(
    bone: &mut BoneState,
    frame: i32,
    controllers: &[Controller],
    pivot_points: &[glm::Vec3],
) {
    // Bone is ready if it has no parent
    bone.is_ready = bone.parent < 0;

    // Get pivot point for this bone
    let pivot = if (bone.object_id as usize) < pivot_points.len() {
        pivot_points[bone.object_id as usize]
    } else {
        glm::vec3(0.0, 0.0, 0.0)
    };

    // Translation
    if bone.translation_idx < 0 {
        // No translation animation - use pivot point
        bone.abs_vector = pivot;
    } else {
        // Get animated translation
        let data = get_frame_data(controllers, bone.translation_idx, frame);
        bone.abs_vector = glm::vec3(
            data[0] + pivot.x,
            data[1] + pivot.y,
            data[2] + pivot.z,
        );
    }

    // Rotation
    if bone.rotation_idx < 0 {
        // No rotation animation - identity quaternion
        bone.abs_quaternion = glm::quat_identity();
    } else {
        // Get animated rotation (quaternion)
        let data = get_frame_data(controllers, bone.rotation_idx, frame);
        bone.abs_quaternion = glm::quat(data[3], data[0], data[1], data[2]);
    }

    // Scaling
    if bone.scaling_idx < 0 {
        // No scaling animation - uniform scale of 1
        bone.abs_scaling = glm::vec3(1.0, 1.0, 1.0);
    } else {
        // Get animated scaling
        let data = get_frame_data(controllers, bone.scaling_idx, frame);
        bone.abs_scaling = glm::vec3(data[0], data[1], data[2]);
    }

    // Visibility
    if bone.visibility_idx < 0 {
        bone.visible = true;
    } else {
        let data = get_frame_data(controllers, bone.visibility_idx, frame);
        bone.visible = data[0] > 0.2; // Threshold from original code
    }

    // Convert quaternion to rotation matrix
    bone.abs_matrix = quaternion_to_matrix(&bone.abs_quaternion);

    // Apply scaling to matrix (each column scaled by corresponding component)
    bone.abs_matrix = apply_scaling_to_matrix(&bone.abs_matrix, &bone.abs_scaling);

    // TODO: Apply billboard transformation if needed
    // if bone.is_billboarded { ... }
}

/// Calculate absolute transformation from parent
/// Based on CalcAbsolute procedure (mdlDraw.pas line 2195)
pub fn calc_absolute(
    parent: &BoneState,
    child: &mut BoneState,
    pivot_points: &[glm::Vec3],
) {
    // Get parent pivot point
    let parent_pivot = if (parent.object_id as usize) < pivot_points.len() {
        pivot_points[parent.object_id as usize]
    } else {
        glm::vec3(0.0, 0.0, 0.0)
    };

    // 1. Multiply rotation matrices
    if !child.is_billboarded {
        child.abs_matrix = mul_matrices(&parent.abs_matrix, &child.abs_matrix);
    } else {
        // For billboarded objects, only apply parent scaling
        let identity = glm::identity::<f32, 3>();
        let scaled = apply_scaling_to_matrix(&identity, &parent.abs_scaling);
        child.abs_matrix = mul_matrices(&scaled, &child.abs_matrix);
    }

    // 2. Transform child position by parent
    // Subtract parent pivot
    let local_pos = child.abs_vector - parent_pivot;

    // Transform by parent matrix
    let transformed = parent.abs_matrix * local_pos;

    // Add parent position
    child.abs_vector = parent.abs_vector + transformed;

    // 3. Combine visibility
    child.visible = child.visible && parent.visible;
}

/// Recursively calculate bone transformation hierarchy
/// Based on CalcTBone procedure (mdlDraw.pas line 2237)
pub fn calc_bone(
    bone_idx: usize,
    bones: &mut [BoneState],
    helpers: &mut [BoneState],
    controllers: &[Controller],
    pivot_points: &[glm::Vec3],
    frame: i32,
) {
    // Check if already calculated
    if bone_idx < bones.len() && bones[bone_idx].is_ready {
        return;
    }
    if bone_idx >= bones.len() {
        let helper_idx = bone_idx - bones.len();
        if helper_idx < helpers.len() && helpers[helper_idx].is_ready {
            return;
        }
    }

    // Get current bone
    let (is_helper, current_idx) = if bone_idx < bones.len() {
        (false, bone_idx)
    } else {
        (true, bone_idx - bones.len())
    };

    let parent_id = if is_helper {
        if current_idx >= helpers.len() {
            return;
        }
        helpers[current_idx].parent
    } else {
        if current_idx >= bones.len() {
            return;
        }
        bones[current_idx].parent
    };

    // No parent - already ready
    if parent_id < 0 {
        if is_helper {
            helpers[current_idx].is_ready = true;
        } else {
            bones[current_idx].is_ready = true;
        }
        return;
    }

    // Calculate parent first (recursive)
    let parent_idx = parent_id as usize;
    calc_bone(parent_idx, bones, helpers, controllers, pivot_points, frame);

    // Get parent bone (this is tricky - need to handle bones vs helpers)
    let parent_bone = if parent_idx < bones.len() {
        bones[parent_idx].clone()
    } else {
        let helper_idx = parent_idx - bones.len();
        if helper_idx < helpers.len() {
            helpers[helper_idx].clone()
        } else {
            return;
        }
    };

    // Calculate absolute transformation
    if is_helper {
        calc_absolute(&parent_bone, &mut helpers[current_idx], pivot_points);
        helpers[current_idx].is_ready = true;
    } else {
        calc_absolute(&parent_bone, &mut bones[current_idx], pivot_points);
        bones[current_idx].is_ready = true;
    }
}
