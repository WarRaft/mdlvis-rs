/// Camera state with position and orientation
#[derive(Debug, Clone)]
pub struct CameraState {
    pub yaw: f32,
    pub pitch: f32,
    pub distance: f32,
    pub target: [f32; 3],
    pub default_yaw: f32,
    pub default_pitch: f32,
    pub default_distance: f32,
    pub default_target: [f32; 3],
}

impl CameraState {
    pub fn new(yaw: f32, pitch: f32, distance: f32, target: [f32; 3]) -> Self {
        Self {
            yaw,
            pitch,
            distance,
            target,
            default_yaw: yaw,
            default_pitch: pitch,
            default_distance: distance,
            default_target: target,
        }
    }

    pub fn reset(&mut self) {
        self.yaw = self.default_yaw;
        self.pitch = self.default_pitch;
        self.distance = self.default_distance;
        self.target = self.default_target;
    }

    pub fn get_orientation(&self) -> (f32, f32) {
        (self.yaw, self.pitch)
    }
}

impl Default for CameraState {
    fn default() -> Self {
        Self::new(0.0, 0.3, 800.0, [0.0, 0.0, 0.0])
    }
}
