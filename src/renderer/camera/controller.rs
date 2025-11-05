use super::CameraState;

/// Handles camera input and transformations
pub struct CameraController {
    state: CameraState,
    left_mouse_pressed: bool,
    middle_mouse_pressed: bool,
    right_mouse_pressed: bool,
    alt_pressed: bool,
    shift_pressed: bool,
    control_pressed: bool,
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
            control_pressed: false,
            last_mouse_pos: None,
        }
    }

    pub fn state(&self) -> &CameraState {
        &self.state
    }

    pub fn is_shift_pressed(&self) -> bool {
        self.shift_pressed
    }

    pub fn is_control_pressed(&self) -> bool {
        self.control_pressed
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

    /// Handle modifier keys (Shift, Alt, Control)
    pub fn on_modifiers(&mut self, shift: bool, alt: bool, control: bool) {
        self.shift_pressed = shift;
        self.alt_pressed = alt;
        self.control_pressed = control;
    }

    /// Handle mouse movement with camera transformations
    pub fn on_mouse_move(&mut self, position: (f64, f64)) -> bool {
        let should_pan =
            self.middle_mouse_pressed || (self.shift_pressed && self.right_mouse_pressed);
        let should_rotate =
            self.right_mouse_pressed || (self.alt_pressed && self.left_mouse_pressed);

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
        self.state.pitch -= delta_y * 0.01; // Inverted vertical axis
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

        // Move target (inverted vertical axis)
        self.state.target[0] += right.x * delta_x * pan_speed - up.x * delta_y * pan_speed;
        self.state.target[1] += right.y * delta_x * pan_speed - up.y * delta_y * pan_speed;
        self.state.target[2] += right.z * delta_x * pan_speed - up.z * delta_y * pan_speed;
    }

    /// Two-finger pan gesture (trackpad - ONLY camera control method)
    pub fn on_pan_gesture(&mut self, delta_x: f32, delta_y: f32, control: bool, shift: bool) {
        if control {
            // Control + pan = zoom from viewport center (simple distance change)
            self.simple_zoom(-delta_y * 0.5);
        } else if shift {
            // Shift + pan = pan (move viewport center / target)
            self.pan(delta_x, delta_y);
        } else {
            // Just pan = rotate around GRID CENTER (0,0,0)
            self.rotate_around_grid_center(delta_x, delta_y);
        }
    }

    /// Simple zoom - just change distance, no cursor bullshit
    pub fn simple_zoom(&mut self, delta: f32) {
        let zoom_factor = 1.0 - delta * 0.1;
        self.state.distance = (self.state.distance * zoom_factor).clamp(10.0, 1000.0);
    }

    /// Rotate camera around grid center (0,0,0) instead of current target
    fn rotate_around_grid_center(&mut self, delta_x: f32, delta_y: f32) {
        // Save current target offset from grid center
        let offset_x = self.state.target[0];
        let offset_y = self.state.target[1];
        let offset_z = self.state.target[2];

        // Temporarily set target to grid center for rotation
        self.state.target = [0.0, 0.0, 0.0];

        // Perform rotation around grid center
        self.rotate(delta_x, delta_y);

        // Restore target offset (rotate the offset vector too)
        // Calculate rotation of the offset vector
        let cos_yaw = (-delta_x * 0.01).cos();
        let sin_yaw = (-delta_x * 0.01).sin();

        let rotated_x = offset_x * cos_yaw - offset_y * sin_yaw;
        let rotated_y = offset_x * sin_yaw + offset_y * cos_yaw;

        self.state.target[0] = rotated_x;
        self.state.target[1] = rotated_y;
        self.state.target[2] = offset_z; // Z не меняется при горизонтальном вращении
    }

    /// Reset camera to defaults
    pub fn reset(&mut self) {
        self.state.reset();
        self.last_mouse_pos = None;
    }
}
