// Main animation system
// Based on CalcAnimCoords from mdlDraw.pas (line 2310)

use super::skeleton::*;
use super::types::*;
use crate::model::model::Model;
use nalgebra_glm as glm;

/// Main animation system
pub struct AnimationSystem {
    pub bones: Vec<BoneState>,
    pub helpers: Vec<BoneState>,
    pub controllers: Vec<Controller>,
    pub pivot_points: Vec<glm::Vec3>,
    pub texture_anims: Vec<TextureAnim>,
    pub geoset_anims: Vec<GeosetAnim>,
    current_frame: f32,
}

impl AnimationSystem {
    pub fn new() -> Self {
        Self {
            bones: Vec::new(),
            helpers: Vec::new(),
            controllers: Vec::new(),
            pivot_points: Vec::new(),
            texture_anims: Vec::new(),
            geoset_anims: Vec::new(),
            current_frame: 0.0,
        }
    }

    /// Update animation to specific frame
    /// Based on CalcAnimCoords procedure (mdlDraw.pas line 2310)
    pub fn update(&mut self, frame: f32) {
        self.current_frame = frame;
        let frame_int = frame as i32;

        // Reset all "IsReady" flags
        for bone in &mut self.bones {
            bone.is_ready = false;
        }
        for helper in &mut self.helpers {
            helper.is_ready = false;
        }

        // 1. Interpolate all bones/helpers to current frame
        // a. Interpolate all skeleton objects
        for i in 0..self.helpers.len() {
            interp_bone(
                &mut self.helpers[i],
                frame_int,
                &self.controllers,
                &self.pivot_points,
            );
        }
        for i in 0..self.bones.len() {
            interp_bone(
                &mut self.bones[i],
                frame_int,
                &self.controllers,
                &self.pivot_points,
            );
        }

        // b. Calculate absolute transformations (hierarchy)
        for i in 0..self.helpers.len() {
            calc_bone(
                self.bones.len() + i,
                &mut self.bones,
                &mut self.helpers,
                &self.controllers,
                &self.pivot_points,
                frame_int,
            );
        }
        for i in 0..self.bones.len() {
            calc_bone(
                i,
                &mut self.bones,
                &mut self.helpers,
                &self.controllers,
                &self.pivot_points,
                frame_int,
            );
        }
    }

    /// Reset all bones to base (T-pose) state
    /// Sets frame to 0 and recalculates all transformations
    pub fn reset_to_base_pose(&mut self) {
        self.current_frame = 0.0;

        // Reset all "IsReady" flags
        for bone in &mut self.bones {
            bone.is_ready = false;
        }
        for helper in &mut self.helpers {
            helper.is_ready = false;
        }

        // Interpolate to frame 0 (base pose)
        for i in 0..self.helpers.len() {
            interp_bone(
                &mut self.helpers[i],
                0,
                &self.controllers,
                &self.pivot_points,
            );
        }
        for i in 0..self.bones.len() {
            interp_bone(&mut self.bones[i], 0, &self.controllers, &self.pivot_points);
        }

        // Calculate absolute transformations
        for i in 0..self.helpers.len() {
            calc_bone(
                self.bones.len() + i,
                &mut self.bones,
                &mut self.helpers,
                &self.controllers,
                &self.pivot_points,
                0,
            );
        }
        for i in 0..self.bones.len() {
            calc_bone(
                i,
                &mut self.bones,
                &mut self.helpers,
                &self.controllers,
                &self.pivot_points,
                0,
            );
        }
    }

    /// Get bone by index
    pub fn get_bone(&self, index: usize) -> Option<&BoneState> {
        self.bones.get(index)
    }

    /// Get all bones
    pub fn get_bones(&self) -> &[BoneState] {
        &self.bones
    }

    /// Add a bone
    pub fn add_bone(&mut self, bone: BoneState) {
        self.bones.push(bone);
    }

    /// Add a helper
    pub fn add_helper(&mut self, helper: BoneState) {
        self.helpers.push(helper);
    }

    /// Add a controller
    pub fn add_controller(&mut self, controller: Controller) -> i32 {
        let idx = self.controllers.len() as i32;
        self.controllers.push(controller);
        idx
    }

    /// Add a pivot point
    pub fn add_pivot_point(&mut self, point: glm::Vec3) {
        self.pivot_points.push(point);
    }

    /// Set pivot points
    pub fn set_pivot_points(&mut self, points: Vec<glm::Vec3>) {
        self.pivot_points = points;
    }

    /// Add texture animation
    pub fn add_texture_anim(&mut self, anim: TextureAnim) -> i32 {
        let idx = self.texture_anims.len() as i32;
        self.texture_anims.push(anim);
        idx
    }

    /// Add geoset animation
    pub fn add_geoset_anim(&mut self, anim: GeosetAnim) {
        self.geoset_anims.push(anim);
    }

    /// Get current frame
    pub fn get_current_frame(&self) -> f32 {
        self.current_frame
    }

    /// Get number of bones
    pub fn bone_count(&self) -> usize {
        self.bones.len()
    }

    /// Get number of helpers
    pub fn helper_count(&self) -> usize {
        self.helpers.len()
    }
}

impl Default for AnimationSystem {
    fn default() -> Self {
        Self::new()
    }
}

impl AnimationSystem {
    /// Initialize animation system from model
    /// Parse bones, helpers, pivot points, and controllers from model data
    pub fn init_from_model(&mut self, model: &Model) {
        use std::collections::HashMap;

        // Clear existing data
        self.bones.clear();
        self.helpers.clear();
        self.controllers.clear();
        self.pivot_points.clear();

        // Create ObjectID -> Index mapping
        // This is critical because parent_id is an ObjectID, not an array index
        let mut object_id_to_index: HashMap<i32, usize> = HashMap::new();

        // Map bones: ObjectID -> index in bones array
        for (idx, bone) in model.bones.iter().enumerate() {
            object_id_to_index.insert(bone.object_id as i32, idx);
        }

        // Map helpers: ObjectID -> index (offset by bones.len())
        for (idx, helper) in model.helpers.iter().enumerate() {
            object_id_to_index.insert(helper.object_id as i32, model.bones.len() + idx);
        }

        // Load pivot points from model
        for bone in &model.bones {
            self.pivot_points.push(glm::vec3(
                bone.pivot_point[0],
                bone.pivot_point[1],
                bone.pivot_point[2],
            ));
        }

        for helper in &model.helpers {
            self.pivot_points.push(glm::vec3(
                helper.pivot_point[0],
                helper.pivot_point[1],
                helper.pivot_point[2],
            ));
        }

        // Load controllers from model
        for model_controller in &model.controllers {
            let cont_type = match model_controller.interpolation_type {
                0 => ControllerType::DontInterp,
                1 => ControllerType::Linear,
                2 => ControllerType::Hermite,
                3 => ControllerType::Bezier,
                _ => ControllerType::Linear,
            };

            let mut controller = Controller {
                cont_type,
                global_seq_id: model_controller.global_seq_id,
                items: Vec::new(),
            };

            for kf in &model_controller.keyframes {
                controller.items.push(ControllerItem {
                    frame: kf.frame,
                    data: kf.data.clone(),
                    in_tan: kf.in_tan.clone(),
                    out_tan: kf.out_tan.clone(),
                });
            }

            self.controllers.push(controller);
        }

        // Create BoneState for each bone
        for bone in &model.bones {
            let mut bone_state = BoneState::new(bone.name.clone(), bone.object_id as i32);

            // CRITICAL: Convert parent ObjectID to index
            bone_state.parent = if bone.parent_id >= 0 {
                match object_id_to_index.get(&bone.parent_id) {
                    Some(&idx) => idx as i32,
                    None => -1,
                }
            } else {
                -1
            };

            bone_state.translation_idx = bone.translation_idx;
            bone_state.rotation_idx = bone.rotation_idx;
            bone_state.scaling_idx = bone.scaling_idx;
            bone_state.visibility_idx = bone.visibility_idx;
            self.bones.push(bone_state);
        }

        // Create BoneState for each helper
        for helper in &model.helpers {
            let mut helper_state = BoneState::new(helper.name.clone(), helper.object_id as i32);

            // CRITICAL: Convert parent ObjectID to index
            helper_state.parent = if helper.parent_id >= 0 {
                match object_id_to_index.get(&helper.parent_id) {
                    Some(&idx) => idx as i32,
                    None => -1,
                }
            } else {
                -1
            };

            helper_state.translation_idx = helper.translation_idx;
            helper_state.rotation_idx = helper.rotation_idx;
            helper_state.scaling_idx = helper.scaling_idx;
            helper_state.visibility_idx = helper.visibility_idx;
            self.helpers.push(helper_state);
        }

        println!(
            "Animation system initialized: {} bones, {} helpers, {} pivot points, {} controllers",
            self.bones.len(),
            self.helpers.len(),
            self.pivot_points.len(),
            self.controllers.len()
        );
    }
}
