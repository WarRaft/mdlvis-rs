use super::CameraState;

/// Handles camera input and transformations
pub struct CameraController {
    state: CameraState,
    left_mouse_pressed: bool,
    middle_mouse_pressed: bool,
    right_mouse_pressed: bool,
    alt_pressed: bool,
    shift_pressed: bool,
    last_mouse_pos: Option<(f64, f64)>,
}

impl CameraController {
    pub fn new(state: CameraState) -> Self {
        Self {
            state,
            left_mouse_pressed: false,
            middle_mouse_pressed: false,
            right_mouse_pressed: false,
            alt_pressed: false,
            shift_pressed: false,
            last_mouse_pos: None,
        }
    }

    pub fn state(&self) -> &CameraState {
        &self.state
    }

    pub fn state_mut(&mut self) -> &mut CameraState {
        &mut self.state
    }

    /// Handle mouse button press/release
    pub fn on_mouse_button(&mut self, button: winit::event::MouseButton, pressed: bool) {
        match button {
            winit::event::MouseButton::Left => {
                self.left_mouse_pressed = pressed;
                if !pressed {
                    self.last_mouse_pos = None;
                }
            }
            winit::event::MouseButton::Middle => {
                self.middle_mouse_pressed = pressed;
                if !pressed {
                    self.last_mouse_pos = None;
                }
            }
            winit::event::MouseButton::Right => {
                self.right_mouse_pressed = pressed;
                if !pressed {
                    self.last_mouse_pos = None;
                }
            }
            _ => {}
        }
    }

    /// Handle modifier keys (Shift, Alt)
    pub fn on_modifiers(&mut self, shift: bool, alt: bool) {
        self.shift_pressed = shift;
        self.alt_pressed = alt;
    }

    /// Handle mouse movement with camera transformations
    pub fn on_mouse_move(&mut self, position: (f64, f64)) -> bool {
        let should_pan = self.middle_mouse_pressed || (self.shift_pressed && self.right_mouse_pressed);
        let should_rotate = self.right_mouse_pressed || (self.alt_pressed && self.left_mouse_pressed);

        let mut handled = false;

        if should_pan {
            if let Some(last_pos) = self.last_mouse_pos {
                let delta_x = position.0 - last_pos.0;
                let delta_y = position.1 - last_pos.1;
                self.pan(delta_x as f32, -delta_y as f32);
                handled = true;
            }
            self.last_mouse_pos = Some(position);
        } else if should_rotate {
            if let Some(last_pos) = self.last_mouse_pos {
                let delta_x = position.0 - last_pos.0;
                let delta_y = position.1 - last_pos.1;
                self.rotate(delta_x as f32, delta_y as f32);
                handled = true;
            }
            self.last_mouse_pos = Some(position);
        } else {
            self.last_mouse_pos = None;
        }

        handled
    }

    /// Rotate camera around target
    fn rotate(&mut self, delta_x: f32, delta_y: f32) {
        self.state.yaw -= delta_x * 0.01; // Inverted for natural rotation
        self.state.pitch += delta_y * 0.01;
        self.state.pitch = self.state.pitch.clamp(-1.5, 1.5);
    }

    /// Pan camera (move target)
    fn pan(&mut self, delta_x: f32, delta_y: f32) {
        // Calculate camera's right and up vectors
        let forward = nalgebra_glm::vec3(
            self.state.yaw.cos() * self.state.pitch.cos(),
            self.state.yaw.sin() * self.state.pitch.cos(),
            self.state.pitch.sin(),
        );
        let right = nalgebra_glm::normalize(&nalgebra_glm::cross(
            &forward,
            &nalgebra_glm::vec3(0.0, 0.0, 1.0),
        ));
        let up = nalgebra_glm::cross(&right, &forward);

        // Pan speed based on distance
        let pan_speed = self.state.distance * 0.001;

        // Move target
        self.state.target[0] += right.x * delta_x * pan_speed + up.x * delta_y * pan_speed;
        self.state.target[1] += right.y * delta_x * pan_speed + up.y * delta_y * pan_speed;
        self.state.target[2] += right.z * delta_x * pan_speed + up.z * delta_y * pan_speed;
    }

    /// Zoom camera
    pub fn zoom(&mut self, delta: f32, cursor_ndc: Option<[f32; 2]>, aspect: f32) {
        let zoom_factor = 1.0 - delta * 0.1;
        let new_distance = (self.state.distance * zoom_factor).clamp(10.0, 1000.0);

        if let Some(ndc) = cursor_ndc {
            // Zoom towards cursor position
            let forward = nalgebra_glm::normalize(&nalgebra_glm::vec3(
                self.state.yaw.cos() * self.state.pitch.cos(),
                self.state.yaw.sin() * self.state.pitch.cos(),
                self.state.pitch.sin(),
            ));
            let right = nalgebra_glm::normalize(&nalgebra_glm::cross(&forward, &nalgebra_glm::vec3(0.0, 0.0, 1.0)));
            let up = nalgebra_glm::cross(&right, &forward);

            // Calculate cursor direction
            let fov_scale = (45.0_f32.to_radians() / 2.0).tan();
            let cursor_dir = nalgebra_glm::normalize(&(
                forward + right * ndc[0] * fov_scale * aspect + up * ndc[1] * fov_scale
            ));

            // Move camera target towards cursor direction
            let distance_change = self.state.distance - new_distance;
            let target_offset = cursor_dir * distance_change * 0.5;

            self.state.target[0] += target_offset.x;
            self.state.target[1] += target_offset.y;
            self.state.target[2] += target_offset.z;
        }

        self.state.distance = new_distance;
    }

    /// Reset camera to defaults
    pub fn reset(&mut self) {
        self.state.reset();
        self.last_mouse_pos = None;
    }
}
