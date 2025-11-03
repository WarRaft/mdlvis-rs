use winit::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::Window,
};

mod app;
mod model;
mod parser;
mod renderer;
mod ui;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    env_logger::init();

    let event_loop = EventLoop::new()?;
    let window = event_loop.create_window(Window::default_attributes()
        .with_title("MDLVis-RS - Warcraft 3 Model Viewer")
        .with_inner_size(winit::dpi::LogicalSize::new(1200.0, 800.0)))?;

    let mut app = pollster::block_on(app::App::new(window))?;

    event_loop.run(move |event, elwt| {
        elwt.set_control_flow(ControlFlow::Poll);

        match event {
            Event::WindowEvent { event, .. } => {
                let response = app.handle_event(&event);
                if response.repaint {
                    app.window.request_redraw();
                }
                if response.exit {
                    elwt.exit();
                }
            }
            Event::AboutToWait => {
                if let Err(e) = app.render() {
                    eprintln!("Render error: {:?}", e);
                }
                app.window.request_redraw();
            }
            _ => {}
        }
    })?;

    Ok(())
}
