use std::ffi::c_void;
use std::sync::Mutex;

/// Temporary unsafe global registry for AppHandler pointer.
/// This stores the raw pointer as usize to satisfy Sync requirements
/// for a global static. This is a hack for quick refactoring and must
/// be removed after.
static HANDLER_PTR: Mutex<Option<usize>> = Mutex::new(None);

/// Register raw pointer to the handler. Caller must guarantee pointer validity
/// until `unregister()` is called.
pub fn register(ptr: *mut c_void) {
    let mut g = HANDLER_PTR.lock().unwrap();
    *g = Some(ptr as usize);
}

pub fn unregister() {
    let mut g = HANDLER_PTR.lock().unwrap();
    *g = None;
}

/// Return raw pointer if registered
pub fn get_raw() -> Option<*mut c_void> {
    let g = HANDLER_PTR.lock().unwrap();
    g.map(|u| u as *mut c_void)
}
