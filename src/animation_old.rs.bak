use nalgebra_glm as glm;

/// Quaternion for bone rotation
#[derive(Debug, Clone, Copy)]
pub struct Quaternion {
    pub x: f32,
    pub y: f32,
    pub z: f32,
    pub w: f32,
}

impl Quaternion {
    pub fn identity() -> Self {
        Self {
            x: 0.0,
            y: 0.0,
            z: 0.0,
            w: 1.0,
        }
    }

    /// Convert quaternion to rotation matrix (3x3)
    pub fn to_matrix(&self) -> glm::Mat3 {
        let x2 = self.x * self.x;
        let y2 = self.y * self.y;
        let z2 = self.z * self.z;
        let xy = self.x * self.y;
        let xz = self.x * self.z;
        let yz = self.y * self.z;
        let wx = self.w * self.x;
        let wy = self.w * self.y;
        let wz = self.w * self.z;

        glm::mat3(
            1.0 - 2.0 * (y2 + z2), 2.0 * (xy - wz), 2.0 * (xz + wy),
            2.0 * (xy + wz), 1.0 - 2.0 * (x2 + z2), 2.0 * (yz - wx),
            2.0 * (xz - wy), 2.0 * (yz + wx), 1.0 - 2.0 * (x2 + y2),
        )
    }
}

/// Bone state for current frame
#[derive(Debug, Clone)]
pub struct BoneState {
    pub object_id: u32,
    pub parent_id: i32,
    pub pivot_point: glm::Vec3,
    
    // Animated properties
    pub translation: glm::Vec3,
    pub rotation: Quaternion,
    pub scaling: glm::Vec3,
    pub visible: bool,
    
    // Computed absolute transforms
    pub abs_matrix: glm::Mat3,
    pub abs_vector: glm::Vec3,
    pub abs_visibility: bool,
    
    // Helper flag
    pub is_ready: bool,
}

impl BoneState {
    pub fn new(object_id: u32, parent_id: i32, pivot_point: [f32; 3]) -> Self {
        Self {
            object_id,
            parent_id,
            pivot_point: glm::vec3(pivot_point[0], pivot_point[1], pivot_point[2]),
            translation: glm::vec3(0.0, 0.0, 0.0),
            rotation: Quaternion::identity(),
            scaling: glm::vec3(1.0, 1.0, 1.0),
            visible: true,
            abs_matrix: glm::identity(),
            abs_vector: glm::vec3(0.0, 0.0, 0.0),
            abs_visibility: true,
            is_ready: false,
        }
    }

    /// Interpolate bone properties for given frame
    pub fn interpolate(&mut self, frame: f32) {
        // TODO: Get data from controllers/keyframes
        // For now, use test animation - simple rotation
        
        // Test animation: rotate around Z axis
        let angle = frame * 0.05; // Slow rotation in radians
        let half_angle = angle / 2.0;
        
        self.rotation = Quaternion {
            x: 0.0,
            y: 0.0,
            z: half_angle.sin(),
            w: half_angle.cos(),
        };
        
        // No translation for now
        self.translation = glm::vec3(0.0, 0.0, 0.0);
        
        // Unit scaling
        self.scaling = glm::vec3(1.0, 1.0, 1.0);
        
        // Visible by default
        self.abs_visibility = true;
        
        // Compute local matrix from rotation and scaling
        let rot_matrix = self.rotation.to_matrix();
        
        // Apply scaling to rotation matrix (scale each column)
        self.abs_matrix = glm::mat3(
            rot_matrix[(0, 0)] * self.scaling.x, 
            rot_matrix[(1, 0)] * self.scaling.x, 
            rot_matrix[(2, 0)] * self.scaling.x,
            
            rot_matrix[(0, 1)] * self.scaling.y, 
            rot_matrix[(1, 1)] * self.scaling.y, 
            rot_matrix[(2, 1)] * self.scaling.y,
            
            rot_matrix[(0, 2)] * self.scaling.z, 
            rot_matrix[(1, 2)] * self.scaling.z, 
            rot_matrix[(2, 2)] * self.scaling.z,
        );
        
        // Initial position: pivot + translation
        self.abs_vector = self.pivot_point + self.translation;
        
        self.is_ready = self.parent_id < 0;
    }

    /// Calculate absolute transforms by combining with parent
    pub fn calculate_absolute(&mut self, parent: &BoneState) {
        if self.is_ready {
            return;
        }

        // Combine rotation matrices
        self.abs_matrix = parent.abs_matrix * self.abs_matrix;

        // Transform position relative to parent
        let rel_pos = self.abs_vector - parent.pivot_point;
        self.abs_vector = parent.abs_vector + parent.abs_matrix * rel_pos;

        // Combine visibility
        self.abs_visibility = self.abs_visibility && parent.abs_visibility;

        self.is_ready = true;
    }
}

/// Animation system for skeletal animation
pub struct AnimationSystem {
    pub bone_states: Vec<BoneState>,
}

impl AnimationSystem {
    pub fn new() -> Self {
        Self {
            bone_states: Vec::new(),
        }
    }

    /// Initialize bone states from model
    pub fn init_from_model(&mut self, model: &crate::model::Model) {
        self.bone_states.clear();
        
        // Create bone states
        for bone in &model.bones {
            let state = BoneState::new(bone.object_id, bone.parent_id, bone.pivot_point);
            self.bone_states.push(state);
        }
    }

    /// Update animation for current frame
    pub fn update(&mut self, frame: f32) {
        // Reset ready flags
        for bone in &mut self.bone_states {
            bone.is_ready = false;
        }

        // 1. Interpolate all bones
        for bone in &mut self.bone_states {
            bone.interpolate(frame);
        }

        // 2. Calculate absolute transforms (recursive)
        for i in 0..self.bone_states.len() {
            self.calculate_bone_recursive(i);
        }
    }

    fn calculate_bone_recursive(&mut self, index: usize) {
        if self.bone_states[index].is_ready {
            return;
        }

        let parent_id = self.bone_states[index].parent_id;
        
        if parent_id < 0 {
            // Root bone - already ready
            self.bone_states[index].is_ready = true;
            return;
        }

        // Find parent index
        let parent_index = self.bone_states.iter()
            .position(|b| b.object_id == parent_id as u32);

        if let Some(parent_idx) = parent_index {
            // Calculate parent first
            self.calculate_bone_recursive(parent_idx);
            
            // Clone parent to avoid borrow issues
            let parent = self.bone_states[parent_idx].clone();
            
            // Calculate this bone
            self.bone_states[index].calculate_absolute(&parent);
        } else {
            // Parent not found - treat as root
            self.bone_states[index].is_ready = true;
        }
    }

    /// Apply bone transforms to vertices
    pub fn transform_vertices(
        &self,
        original_vertices: &[[f32; 3]],
        vertex_groups: &[usize],
        bone_groups: &[Vec<u32>],
        pivot_points: &[[f32; 3]],
    ) -> Vec<[f32; 3]> {
        let mut transformed = vec![[0.0f32; 3]; original_vertices.len()];

        for (i, vertex) in original_vertices.iter().enumerate() {
            let group_idx = vertex_groups[i];
            if group_idx >= bone_groups.len() {
                // No bone group - use original position
                transformed[i] = *vertex;
                continue;
            }

            let bones_in_group = &bone_groups[group_idx];
            if bones_in_group.is_empty() {
                transformed[i] = *vertex;
                continue;
            }

            // Transform vertex by each bone in group and average
            let mut sum = glm::vec3(0.0, 0.0, 0.0);
            
            for &bone_id in bones_in_group {
                // Find bone state
                if let Some(bone) = self.bone_states.iter().find(|b| b.object_id == bone_id) {
                    // Transform vertex
                    let pivot = glm::vec3(pivot_points[bone_id as usize][0], 
                                         pivot_points[bone_id as usize][1], 
                                         pivot_points[bone_id as usize][2]);
                    let v = glm::vec3(vertex[0], vertex[1], vertex[2]);
                    let rel = v - pivot;
                    let transformed_v = bone.abs_vector + bone.abs_matrix * rel;
                    sum += transformed_v;
                }
            }

            // Average
            let count = bones_in_group.len() as f32;
            let result = sum / count;
            transformed[i] = [result.x, result.y, result.z];
        }

        transformed
    }
}
