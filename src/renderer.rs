use std::sync::Arc;
use wgpu::util::DeviceExt;
use crate::model::Model;

#[repr(C)]
#[derive(Copy, Clone, Debug, bytemuck::Pod, bytemuck::Zeroable)]
struct Vertex {
    position: [f32; 3],
    normal: [f32; 3],
}

impl Vertex {
    fn desc() -> wgpu::VertexBufferLayout<'static> {
        wgpu::VertexBufferLayout {
            array_stride: std::mem::size_of::<Vertex>() as wgpu::BufferAddress,
            step_mode: wgpu::VertexStepMode::Vertex,
            attributes: &[
                wgpu::VertexAttribute {
                    offset: 0,
                    shader_location: 0,
                    format: wgpu::VertexFormat::Float32x3,
                },
                wgpu::VertexAttribute {
                    offset: std::mem::size_of::<[f32; 3]>() as wgpu::BufferAddress,
                    shader_location: 1,
                    format: wgpu::VertexFormat::Float32x3,
                },
            ],
        }
    }
}

#[repr(C)]
#[derive(Copy, Clone, Debug, bytemuck::Pod, bytemuck::Zeroable)]
struct LineVertex {
    position: [f32; 3],
    color: [f32; 3],
}

impl LineVertex {
    fn desc() -> wgpu::VertexBufferLayout<'static> {
        wgpu::VertexBufferLayout {
            array_stride: std::mem::size_of::<LineVertex>() as wgpu::BufferAddress,
            step_mode: wgpu::VertexStepMode::Vertex,
            attributes: &[
                wgpu::VertexAttribute {
                    offset: 0,
                    shader_location: 0,
                    format: wgpu::VertexFormat::Float32x3,
                },
                wgpu::VertexAttribute {
                    offset: std::mem::size_of::<[f32; 3]>() as wgpu::BufferAddress,
                    shader_location: 1,
                    format: wgpu::VertexFormat::Float32x3,
                },
            ],
        }
    }
}

pub struct Renderer {
    surface: wgpu::Surface<'static>,
    device: wgpu::Device,
    queue: wgpu::Queue,
    config: wgpu::SurfaceConfiguration,
    render_pipeline: wgpu::RenderPipeline,
    line_pipeline: wgpu::RenderPipeline,
    vertex_buffer: wgpu::Buffer,
    index_buffer: wgpu::Buffer,
    num_indices: u32,
    line_vertex_buffer: wgpu::Buffer,
    num_lines: u32,
    camera_buffer: wgpu::Buffer,
    camera_bind_group: wgpu::BindGroup,
    camera_yaw: f32,
    camera_pitch: f32,
    camera_distance: f32,
}

impl Renderer {
    pub async fn new(window: &Arc<winit::window::Window>) -> Result<Self, Box<dyn std::error::Error>> {
        let size = window.inner_size();

        // The instance is a handle to our GPU
        let instance = wgpu::Instance::new(wgpu::InstanceDescriptor {
            backends: wgpu::Backends::all(),
            ..Default::default()
        });

        // The surface is the part of the window we draw to
        let surface = instance.create_surface(window)?;
        let surface = unsafe { std::mem::transmute::<wgpu::Surface<'_>, wgpu::Surface<'static>>(surface) };

        // Adapter is a handle to the GPU
        let adapter = instance.request_adapter(
            &wgpu::RequestAdapterOptions {
                power_preference: wgpu::PowerPreference::default(),
                compatible_surface: Some(&surface),
                force_fallback_adapter: false,
            },
        ).await.unwrap();

        let (device, queue) = adapter.request_device(
            &wgpu::DeviceDescriptor {
                required_features: wgpu::Features::empty(),
                required_limits: wgpu::Limits::default(),
                label: None,
                memory_hints: wgpu::MemoryHints::default(),
            },
            None,
        ).await.unwrap();

        let surface_caps = surface.get_capabilities(&adapter);
        let surface_format = surface_caps.formats.iter()
            .copied()
            .find(|f| f.is_srgb())
            .unwrap_or(surface_caps.formats[0]);

        let config = wgpu::SurfaceConfiguration {
            usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
            format: surface_format,
            width: size.width,
            height: size.height,
            present_mode: surface_caps.present_modes[0],
            alpha_mode: surface_caps.alpha_modes[0],
            view_formats: vec![],
            desired_maximum_frame_latency: 2,
        };
        surface.configure(&device, &config);

        // Create dummy buffers for now
        let vertex_buffer = device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("Vertex Buffer"),
            size: 0,
            usage: wgpu::BufferUsages::VERTEX,
            mapped_at_creation: false,
        });

        let index_buffer = device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("Index Buffer"),
            size: 0,
            usage: wgpu::BufferUsages::INDEX,
            mapped_at_creation: false,
        });

        let shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
            label: Some("Shader"),
            source: wgpu::ShaderSource::Wgsl(include_str!("shader.wgsl").into()),
        });

        // Create camera uniform buffer
        let camera_buffer = device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("Camera Buffer"),
            size: 64, // mat4x4<f32>
            usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });

        let camera_bind_group_layout = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
            label: Some("Camera Bind Group Layout"),
            entries: &[wgpu::BindGroupLayoutEntry {
                binding: 0,
                visibility: wgpu::ShaderStages::VERTEX,
                ty: wgpu::BindingType::Buffer {
                    ty: wgpu::BufferBindingType::Uniform,
                    has_dynamic_offset: false,
                    min_binding_size: None,
                },
                count: None,
            }],
        });

        let camera_bind_group = device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("Camera Bind Group"),
            layout: &camera_bind_group_layout,
            entries: &[wgpu::BindGroupEntry {
                binding: 0,
                resource: camera_buffer.as_entire_binding(),
            }],
        });

        let render_pipeline_layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
            label: Some("Render Pipeline Layout"),
            bind_group_layouts: &[&camera_bind_group_layout],
            push_constant_ranges: &[],
        });

        let render_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("Render Pipeline"),
            layout: Some(&render_pipeline_layout),
            vertex: wgpu::VertexState {
                module: &shader,
                entry_point: Some("vs_main"),
                buffers: &[Vertex::desc()],
                compilation_options: wgpu::PipelineCompilationOptions::default(),
            },
            fragment: Some(wgpu::FragmentState {
                module: &shader,
                entry_point: Some("fs_main"),
                targets: &[Some(wgpu::ColorTargetState {
                    format: config.format,
                    blend: Some(wgpu::BlendState::REPLACE),
                    write_mask: wgpu::ColorWrites::ALL,
                })],
                compilation_options: wgpu::PipelineCompilationOptions::default(),
            }),
            primitive: wgpu::PrimitiveState {
                topology: wgpu::PrimitiveTopology::TriangleList,
                strip_index_format: None,
                front_face: wgpu::FrontFace::Cw,
                cull_mode: None,
                polygon_mode: wgpu::PolygonMode::Fill,
                unclipped_depth: false,
                conservative: false,
            },
            depth_stencil: Some(wgpu::DepthStencilState {
                format: wgpu::TextureFormat::Depth32Float,
                depth_write_enabled: true,
                depth_compare: wgpu::CompareFunction::Less,
                stencil: wgpu::StencilState::default(),
                bias: wgpu::DepthBiasState::default(),
            }),
            multisample: wgpu::MultisampleState {
                count: 1,
                mask: !0,
                alpha_to_coverage_enabled: false,
            },
            multiview: None,
            cache: None,
        });

        // Create line rendering pipeline
        let line_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("Line Pipeline"),
            layout: Some(&render_pipeline_layout),
            vertex: wgpu::VertexState {
                module: &shader,
                entry_point: Some("vs_line"),
                buffers: &[LineVertex::desc()],
                compilation_options: wgpu::PipelineCompilationOptions::default(),
            },
            fragment: Some(wgpu::FragmentState {
                module: &shader,
                entry_point: Some("fs_line"),
                targets: &[Some(wgpu::ColorTargetState {
                    format: config.format,
                    blend: Some(wgpu::BlendState::REPLACE),
                    write_mask: wgpu::ColorWrites::ALL,
                })],
                compilation_options: wgpu::PipelineCompilationOptions::default(),
            }),
            primitive: wgpu::PrimitiveState {
                topology: wgpu::PrimitiveTopology::LineList,
                strip_index_format: None,
                front_face: wgpu::FrontFace::Cw,
                cull_mode: None,
                polygon_mode: wgpu::PolygonMode::Fill,
                unclipped_depth: false,
                conservative: false,
            },
            depth_stencil: Some(wgpu::DepthStencilState {
                format: wgpu::TextureFormat::Depth32Float,
                depth_write_enabled: true,
                depth_compare: wgpu::CompareFunction::Less,
                stencil: wgpu::StencilState::default(),
                bias: wgpu::DepthBiasState::default(),
            }),
            multisample: wgpu::MultisampleState {
                count: 1,
                mask: !0,
                alpha_to_coverage_enabled: false,
            },
            multiview: None,
            cache: None,
        });

        // Create axes and grid
        let mut line_vertices = Vec::new();
        
        // Axes (thick main lines from -200 to 200)
        // X axis - Red
        line_vertices.push(LineVertex { position: [-200.0, 0.0, 0.0], color: [1.0, 0.0, 0.0] });
        line_vertices.push(LineVertex { position: [200.0, 0.0, 0.0], color: [1.0, 0.0, 0.0] });
        // Y axis - Green
        line_vertices.push(LineVertex { position: [0.0, -200.0, 0.0], color: [0.0, 1.0, 0.0] });
        line_vertices.push(LineVertex { position: [0.0, 200.0, 0.0], color: [0.0, 1.0, 0.0] });
        // Z axis - Blue
        line_vertices.push(LineVertex { position: [0.0, 0.0, -200.0], color: [0.0, 0.0, 1.0] });
        line_vertices.push(LineVertex { position: [0.0, 0.0, 200.0], color: [0.0, 0.0, 1.0] });
        
        // Extra thick endings for axes
        line_vertices.push(LineVertex { position: [0.0, 0.0, 200.0], color: [0.0, 0.0, 1.0] });
        line_vertices.push(LineVertex { position: [0.0, 0.0, 210.0], color: [0.0, 0.0, 1.0] });
        line_vertices.push(LineVertex { position: [200.0, 0.0, 0.0], color: [1.0, 0.0, 0.0] });
        line_vertices.push(LineVertex { position: [210.0, 0.0, 0.0], color: [1.0, 0.0, 0.0] });
        line_vertices.push(LineVertex { position: [0.0, 200.0, 0.0], color: [0.0, 1.0, 0.0] });
        line_vertices.push(LineVertex { position: [0.0, 210.0, 0.0], color: [0.0, 1.0, 0.0] });
        
        // Grid - XZ plane (gray, low density)
        for i in -32..=32 {
            let pos = i as f32 * 8.0;
            line_vertices.push(LineVertex { position: [pos, 0.0, -256.0], color: [0.5, 0.5, 0.5] });
            line_vertices.push(LineVertex { position: [pos, 0.0, 256.0], color: [0.5, 0.5, 0.5] });
            line_vertices.push(LineVertex { position: [-256.0, 0.0, pos], color: [0.5, 0.5, 0.5] });
            line_vertices.push(LineVertex { position: [256.0, 0.0, pos], color: [0.5, 0.5, 0.5] });
        }
        
        // Grid - XZ plane (black, high density every 64 units)
        for i in -4..=4 {
            let pos = i as f32 * 64.0;
            line_vertices.push(LineVertex { position: [pos, 0.0, -256.0], color: [0.0, 0.0, 0.0] });
            line_vertices.push(LineVertex { position: [pos, 0.0, 256.0], color: [0.0, 0.0, 0.0] });
            line_vertices.push(LineVertex { position: [-256.0, 0.0, pos], color: [0.0, 0.0, 0.0] });
            line_vertices.push(LineVertex { position: [256.0, 0.0, pos], color: [0.0, 0.0, 0.0] });
        }

        let line_vertex_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("Line Vertex Buffer"),
            contents: bytemuck::cast_slice(&line_vertices),
            usage: wgpu::BufferUsages::VERTEX,
        });
        let num_lines = line_vertices.len() as u32;

        Ok(Self {
            surface,
            device,
            queue,
            config,
            render_pipeline,
            line_pipeline,
            vertex_buffer,
            index_buffer,
            num_indices: 0,
            line_vertex_buffer,
            num_lines,
            camera_buffer,
            camera_bind_group,
            camera_yaw: 0.0,
            camera_pitch: 0.0,
            camera_distance: 200.0,
        })
    }

    pub fn resize(&mut self, new_size: winit::dpi::PhysicalSize<u32>) {
        if new_size.width > 0 && new_size.height > 0 {
            self.config.width = new_size.width;
            self.config.height = new_size.height;
            self.surface.configure(&self.device, &self.config);
        }
    }

    pub fn render(&mut self) -> Result<(), wgpu::SurfaceError> {
        // Update camera matrix
        let aspect = self.config.width as f32 / self.config.height as f32;
        let proj = nalgebra_glm::perspective(aspect, 45.0_f32.to_radians(), 0.1, 1000.0);
        
        let eye = nalgebra_glm::vec3(
            self.camera_distance * self.camera_yaw.cos() * self.camera_pitch.cos(),
            -self.camera_distance * self.camera_pitch.sin(), // Negated Y like Delphi glScalef(1,-1,1)
            self.camera_distance * self.camera_yaw.sin() * self.camera_pitch.cos(),
        );
        let center = nalgebra_glm::vec3(0.0, 0.0, 0.0);
        let up = nalgebra_glm::vec3(0.0, -1.0, 0.0); // Inverted Y axis to match Delphi
        let view = nalgebra_glm::look_at(&eye, &center, &up);
        
        let view_proj = proj * view;
        self.queue.write_buffer(&self.camera_buffer, 0, bytemuck::cast_slice(view_proj.as_slice()));

        let output = self.surface.get_current_texture()?;
        let view = output.texture.create_view(&wgpu::TextureViewDescriptor::default());

        let depth_texture = self.device.create_texture(&wgpu::TextureDescriptor {
            label: Some("Depth Texture"),
            size: wgpu::Extent3d {
                width: self.config.width,
                height: self.config.height,
                depth_or_array_layers: 1,
            },
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: wgpu::TextureFormat::Depth32Float,
            usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
            view_formats: &[],
        });
        let depth_view = depth_texture.create_view(&wgpu::TextureViewDescriptor::default());

        let mut encoder = self.device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
            label: Some("Render Encoder"),
        });

        {
            let mut render_pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                label: Some("Render Pass"),
                color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                    view: &view,
                    resolve_target: None,
                    ops: wgpu::Operations {
                        load: wgpu::LoadOp::Clear(wgpu::Color {
                            r: 0.8,
                            g: 0.8,
                            b: 0.8,
                            a: 1.0,
                        }),
                        store: wgpu::StoreOp::Store,
                    },
                })],
            depth_stencil_attachment: Some(wgpu::RenderPassDepthStencilAttachment {
                view: &depth_view,
                depth_ops: Some(wgpu::Operations {
                    load: wgpu::LoadOp::Clear(1.0),
                    store: wgpu::StoreOp::Store,
                }),
                stencil_ops: None,
            }),
                occlusion_query_set: None,
                timestamp_writes: None,
            });

            // Draw axes and grid first
            render_pass.set_pipeline(&self.line_pipeline);
            render_pass.set_bind_group(0, &self.camera_bind_group, &[]);
            render_pass.set_vertex_buffer(0, self.line_vertex_buffer.slice(..));
            render_pass.draw(0..self.num_lines, 0..1);

            // Draw model
            render_pass.set_pipeline(&self.render_pipeline);
            render_pass.set_bind_group(0, &self.camera_bind_group, &[]);
            render_pass.set_vertex_buffer(0, self.vertex_buffer.slice(..));
            render_pass.set_index_buffer(self.index_buffer.slice(..), wgpu::IndexFormat::Uint16);
            render_pass.draw_indexed(0..self.num_indices, 0, 0..1);
        }

        self.queue.submit(std::iter::once(encoder.finish()));
        output.present();

        Ok(())
    }

    pub fn update_model(&mut self, model: &Model) {
        if let Some(geoset) = model.geosets.first() {
            let vertices: Vec<Vertex> = geoset.vertices.iter().zip(&geoset.normals).map(|(v, n)| Vertex {
                position: v.position,
                normal: n.normal,
            }).collect();

            let indices: Vec<u16> = geoset.faces.iter().flat_map(|f| f.vertices.iter().map(|&i| i as u16)).collect();

            println!("Loaded {} vertices, {} indices ({} triangles)", vertices.len(), indices.len(), indices.len() / 3);

            self.vertex_buffer = self.device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("Vertex Buffer"),
                contents: bytemuck::cast_slice(&vertices),
                usage: wgpu::BufferUsages::VERTEX,
            });

            self.index_buffer = self.device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("Index Buffer"),
                contents: bytemuck::cast_slice(&indices),
                usage: wgpu::BufferUsages::INDEX,
            });

            self.num_indices = indices.len() as u32;
        }
    }

    pub fn rotate_camera(&mut self, delta_x: f32, delta_y: f32) {
        self.camera_yaw += delta_x * 0.01;
        self.camera_pitch += delta_y * 0.01;
        self.camera_pitch = self.camera_pitch.clamp(-1.5, 1.5);
    }

    pub fn zoom_camera(&mut self, delta: f32) {
        self.camera_distance -= delta * 10.0;
        self.camera_distance = self.camera_distance.clamp(10.0, 1000.0);
    }
}