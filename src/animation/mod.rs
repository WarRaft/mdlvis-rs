// Animation system module
// Based on original Delphi mdlwork.pas and mdlDraw.pas

pub mod types;
pub mod controller;
pub mod interpolation;
pub mod skeleton;
pub mod system;

pub use types::*;
pub use controller::*;
pub use interpolation::*;
pub use skeleton::*;
pub use system::AnimationSystem;
