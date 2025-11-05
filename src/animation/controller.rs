// Controller data handling
// Based on GetFrameData function from mdlDraw.pas

use super::types::*;

/// Get interpolated frame data from controller
/// Based on GetFrameData function in mdlDraw.pas (lines 776-960)
pub fn get_frame_data(
    controllers: &[Controller],
    controller_idx: i32,
    frame: i32,
) -> Vec<f32> {
    if controller_idx < 0 || controller_idx as usize >= controllers.len() {
        return vec![0.0; 4]; // Default values
    }

    let controller = &controllers[controller_idx as usize];
    controller.get_frame_data(frame)
}
