use winit::{
    event::Event,
    event_loop::{ControlFlow, EventLoop},
    window::Window,
};

mod app;
mod material_system;
mod model;
mod parser;
mod pipeline_system;
mod renderer;
mod settings;
mod texture_loader;
mod texture_system;
mod ui;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    env_logger::init();

    // Parse command line arguments
    let args: Vec<String> = std::env::args().collect();
    let model_path = if args.len() > 1 {
        Some(args[1].clone())
    } else {
        None
    };

    let event_loop = EventLoop::new()?;
    let window = event_loop.create_window(Window::default_attributes()
        .with_title("MDLVis-RS - Warcraft 3 Model Viewer")
        .with_inner_size(winit::dpi::LogicalSize::new(1200.0, 800.0)))?;

    // Create tokio runtime for async texture loading
    let rt = tokio::runtime::Runtime::new()?;
    let mut app = rt.block_on(app::App::new(window))?;
    
    // Load model if provided as command line argument
    if let Some(path) = model_path {
        if let Err(e) = rt.block_on(app.load_model(&path)) {
            eprintln!("Failed to load model '{}': {}", path, e);
        }
    }

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
