use std::sync::Arc;
use wgpu::util::DeviceExt;
use crate::model::Model;
use egui_wgpu::ScreenDescriptor;

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
    skeleton_vertex_buffer: wgpu::Buffer,
    num_skeleton_lines: u32,
    camera_buffer: wgpu::Buffer,
    camera_bind_group: wgpu::BindGroup,
    camera_yaw: f32,
    camera_pitch: f32,
    camera_distance: f32,
    model_center: [f32; 3],
    egui_renderer: egui_wgpu::Renderer,
    egui_ctx: egui::Context,
}

impl Renderer {
    pub async fn new(window: &Arc<winit::window::Window>) -> Result<Self, Box<dyn std::error::Error>> {
        let size = window.inner_size();

        // The instance is a handle to our GPU
        let instance = wgpu::Instance::new(&wgpu::InstanceDescriptor {
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
                ..Default::default()
            },
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
                polygon_mode: wgpu::PolygonMode::Fill, // Filled mode with checkerboard texture
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
                depth_write_enabled: false, // Don't write to depth buffer so skeleton is always visible
                depth_compare: wgpu::CompareFunction::Always, // Always pass depth test
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
        // X axis - Red (right)
        line_vertices.push(LineVertex { position: [-200.0, 0.0, 0.0], color: [1.0, 0.0, 0.0] });
        line_vertices.push(LineVertex { position: [200.0, 0.0, 0.0], color: [1.0, 0.0, 0.0] });
        // Y axis - Green (forward/depth)
        line_vertices.push(LineVertex { position: [0.0, -200.0, 0.0], color: [0.0, 1.0, 0.0] });
        line_vertices.push(LineVertex { position: [0.0, 200.0, 0.0], color: [0.0, 1.0, 0.0] });
        // Z axis - Blue (up)
        line_vertices.push(LineVertex { position: [0.0, 0.0, -200.0], color: [0.0, 0.0, 1.0] });
        line_vertices.push(LineVertex { position: [0.0, 0.0, 200.0], color: [0.0, 0.0, 1.0] });
        
        // Extra thick endings for axes
        line_vertices.push(LineVertex { position: [0.0, 0.0, 200.0], color: [0.0, 0.0, 1.0] });
        line_vertices.push(LineVertex { position: [0.0, 0.0, 210.0], color: [0.0, 0.0, 1.0] });
        line_vertices.push(LineVertex { position: [200.0, 0.0, 0.0], color: [1.0, 0.0, 0.0] });
        line_vertices.push(LineVertex { position: [210.0, 0.0, 0.0], color: [1.0, 0.0, 0.0] });
        line_vertices.push(LineVertex { position: [0.0, 200.0, 0.0], color: [0.0, 1.0, 0.0] });
        line_vertices.push(LineVertex { position: [0.0, 210.0, 0.0], color: [0.0, 1.0, 0.0] });
        
        // Grid - XY plane (gray, low density) - ground plane
        for i in -32..=32 {
            let pos = i as f32 * 8.0;
            line_vertices.push(LineVertex { position: [pos, -256.0, 0.0], color: [0.5, 0.5, 0.5] });
            line_vertices.push(LineVertex { position: [pos, 256.0, 0.0], color: [0.5, 0.5, 0.5] });
            line_vertices.push(LineVertex { position: [-256.0, pos, 0.0], color: [0.5, 0.5, 0.5] });
            line_vertices.push(LineVertex { position: [256.0, pos, 0.0], color: [0.5, 0.5, 0.5] });
        }
        
        // Grid - XY plane (black, high density every 64 units)
        for i in -4..=4 {
            let pos = i as f32 * 64.0;
            line_vertices.push(LineVertex { position: [pos, -256.0, 0.0], color: [0.0, 0.0, 0.0] });
            line_vertices.push(LineVertex { position: [pos, 256.0, 0.0], color: [0.0, 0.0, 0.0] });
            line_vertices.push(LineVertex { position: [-256.0, pos, 0.0], color: [0.0, 0.0, 0.0] });
            line_vertices.push(LineVertex { position: [256.0, pos, 0.0], color: [0.0, 0.0, 0.0] });
        }

        let line_vertex_buffer = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("Line Vertex Buffer"),
            contents: bytemuck::cast_slice(&line_vertices),
            usage: wgpu::BufferUsages::VERTEX,
        });
        let num_lines = line_vertices.len() as u32;

        // Create empty skeleton buffer initially
        let skeleton_vertex_buffer = device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("Skeleton Vertex Buffer"),
            size: 0,
            usage: wgpu::BufferUsages::VERTEX,
            mapped_at_creation: false,
        });

        // Initialize egui
        let egui_ctx = egui::Context::default();
        let egui_renderer = egui_wgpu::Renderer::new(
            &device,
            config.format,
            Default::default(),
        );

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
            skeleton_vertex_buffer,
            num_skeleton_lines: 0,
            camera_buffer,
            camera_bind_group,
            camera_yaw: std::f32::consts::PI * 1.25, // 225 degrees - front-right view
            camera_pitch: std::f32::consts::PI * 0.15, // 27 degrees - look slightly up
            camera_distance: 200.0,
            model_center: [0.0, 0.0, 0.0],
            egui_renderer,
            egui_ctx,
        })
    }

    pub fn resize(&mut self, new_size: winit::dpi::PhysicalSize<u32>) {
        if new_size.width > 0 && new_size.height > 0 {
            self.config.width = new_size.width;
            self.config.height = new_size.height;
            self.surface.configure(&self.device, &self.config);
        }
    }

    pub fn egui_context(&self) -> egui::Context {
        self.egui_ctx.clone()
    }

    pub fn render(&mut self, _paint_jobs: Vec<egui::ClippedPrimitive>, _textures_delta: egui::TexturesDelta, _screen_descriptor: ScreenDescriptor) -> Result<(), wgpu::SurfaceError> {
        // Update camera matrix
        let aspect = self.config.width as f32 / self.config.height as f32;
        let proj = nalgebra_glm::perspective(aspect, 45.0_f32.to_radians(), 0.1, 1000.0);
        
        let eye = nalgebra_glm::vec3(
            self.model_center[0] + self.camera_distance * self.camera_yaw.cos() * self.camera_pitch.cos(),
            self.model_center[1] + self.camera_distance * self.camera_yaw.sin() * self.camera_pitch.cos(),
            self.model_center[2] + self.camera_distance * self.camera_pitch.sin(),
        );
        let center = nalgebra_glm::vec3(self.model_center[0], self.model_center[1], self.model_center[2]);
        let up = nalgebra_glm::vec3(0.0, 0.0, 1.0); // Z-up coordinate system
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
                    depth_slice: None,
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
            if self.num_indices > 0 {
                render_pass.set_pipeline(&self.render_pipeline);
                render_pass.set_bind_group(0, &self.camera_bind_group, &[]);
                render_pass.set_vertex_buffer(0, self.vertex_buffer.slice(..));
                render_pass.set_index_buffer(self.index_buffer.slice(..), wgpu::IndexFormat::Uint16);
                render_pass.draw_indexed(0..self.num_indices, 0, 0..1);
            }
            
            // Draw skeleton on top (always visible)
            if self.num_skeleton_lines > 0 {
                render_pass.set_pipeline(&self.line_pipeline);
                render_pass.set_bind_group(0, &self.camera_bind_group, &[]);
                render_pass.set_vertex_buffer(0, self.skeleton_vertex_buffer.slice(..));
                render_pass.draw(0..(self.num_skeleton_lines * 2), 0..1);
            }
        }

        // Render egui properly
        for (id, image_delta) in &_textures_delta.set {
            self.egui_renderer.update_texture(&self.device, &self.queue, *id, image_delta);
        }

        let screen_desc = _screen_descriptor;
        
        // Update egui buffers before rendering
        self.egui_renderer.update_buffers(
            &self.device,
            &self.queue,
            &mut encoder,
            &_paint_jobs,
            &screen_desc,
        );

        {
            let mut egui_rpass = encoder
                .begin_render_pass(&wgpu::RenderPassDescriptor {
                    label: Some("egui render pass"),
                    color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                        view: &view,
                        resolve_target: None,
                        ops: wgpu::Operations {
                            load: wgpu::LoadOp::Load,
                            store: wgpu::StoreOp::Store,
                        },
                        depth_slice: None,
                    })],
                    depth_stencil_attachment: None,
                    occlusion_query_set: None,
                    timestamp_writes: None,
                })
                .forget_lifetime();  // This is the key!

            self.egui_renderer.render(&mut egui_rpass, &_paint_jobs, &screen_desc);
        }

        for id in &_textures_delta.free {
            self.egui_renderer.free_texture(id);
        }

        self.queue.submit(std::iter::once(encoder.finish()));
        output.present();

        Ok(())
    }

    pub fn update_model(&mut self, model: &Model) {
        if model.geosets.is_empty() {
            return;
        }
        
        let mut all_vertices: Vec<Vertex> = Vec::new();
        let mut all_indices: Vec<u16> = Vec::new();
        
        for (geoset_idx, geoset) in model.geosets.iter().enumerate() {
            let vertex_offset = all_vertices.len() as u32;
            
            // Add vertices from this geoset
            let vertices: Vec<Vertex> = geoset.vertices.iter().zip(&geoset.normals).map(|(v, n)| Vertex {
                position: v.position,
                normal: n.normal,
            }).collect();
            
            all_vertices.extend(vertices);
            
            // Add indices from this geoset, offsetting by current vertex count
            for face in &geoset.faces {
                for &idx in &face.vertices {
                    all_indices.push((vertex_offset + idx) as u16);
                }
            }
            
            println!("  Geoset {}: added {} vertices, {} faces", 
                geoset_idx, geoset.vertices.len(), geoset.faces.len());
        }

        // Calculate bounding box to understand model position
        if !all_vertices.is_empty() {
            let mut min = all_vertices[0].position;
            let mut max = all_vertices[0].position;
            for v in &all_vertices {
                for i in 0..3 {
                    min[i] = min[i].min(v.position[i]);
                    max[i] = max[i].max(v.position[i]);
                }
            }
            println!("Model bounds: min({:.2}, {:.2}, {:.2}), max({:.2}, {:.2}, {:.2})", 
                min[0], min[1], min[2], max[0], max[1], max[2]);
            
            // Store model center for camera targeting
            self.model_center = [
                (min[0] + max[0]) / 2.0,
                (min[1] + max[1]) / 2.0,
                (min[2] + max[2]) / 2.0,
            ];
            
            println!("Center: ({:.2}, {:.2}, {:.2})", 
                self.model_center[0], self.model_center[1], self.model_center[2]);
        }

        println!("Total: {} vertices, {} indices ({} triangles)", 
            all_vertices.len(), all_indices.len(), all_indices.len() / 3);

        self.vertex_buffer = self.device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("Vertex Buffer"),
            contents: bytemuck::cast_slice(&all_vertices),
            usage: wgpu::BufferUsages::VERTEX,
        });

        self.index_buffer = self.device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("Index Buffer"),
            contents: bytemuck::cast_slice(&all_indices),
            usage: wgpu::BufferUsages::INDEX,
        });

        self.num_indices = all_indices.len() as u32;
        println!("Updated num_indices to: {}", self.num_indices);
        
        // Generate skeleton lines
        if !model.bones.is_empty() || !model.helpers.is_empty() {
            let mut skeleton_vertices = Vec::new();
            let bone_color = [1.0, 1.0, 0.0]; // Yellow for bones
            let helper_color = [0.0, 1.0, 1.0]; // Cyan for helpers
            
            // Helper function to find pivot point by object_id
            let find_pivot = |object_id: i32| -> Option<[f32; 3]> {
                if object_id < 0 {
                    return None;
                }
                
                // Search in bones first
                if let Some(bone) = model.bones.iter().find(|b| b.object_id == object_id as u32) {
                    return Some(bone.pivot_point);
                }
                
                // Then search in helpers
                if let Some(helper) = model.helpers.iter().find(|h| h.object_id == object_id as u32) {
                    return Some(helper.pivot_point);
                }
                
                None
            };
            
            // Process bones
            for bone in &model.bones {
                if let Some(parent_pivot) = find_pivot(bone.parent_id) {
                    skeleton_vertices.push(LineVertex {
                        position: parent_pivot,
                        color: bone_color,
                    });
                    skeleton_vertices.push(LineVertex {
                        position: bone.pivot_point,
                        color: bone_color,
                    });
                }
            }
            
            // Process helpers
            for helper in &model.helpers {
                if let Some(parent_pivot) = find_pivot(helper.parent_id) {
                    skeleton_vertices.push(LineVertex {
                        position: parent_pivot,
                        color: helper_color,
                    });
                    skeleton_vertices.push(LineVertex {
                        position: helper.pivot_point,
                        color: helper_color,
                    });
                }
            }
            
            if !skeleton_vertices.is_empty() {
                self.skeleton_vertex_buffer = self.device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                    label: Some("Skeleton Vertex Buffer"),
                    contents: bytemuck::cast_slice(&skeleton_vertices),
                    usage: wgpu::BufferUsages::VERTEX,
                });
                self.num_skeleton_lines = (skeleton_vertices.len() / 2) as u32;
                println!("Loaded {} bones + {} helpers, generated {} skeleton lines", 
                    model.bones.len(), model.helpers.len(), self.num_skeleton_lines);
            } else {
                self.num_skeleton_lines = 0;
                println!("Loaded {} bones + {} helpers, but no lines generated (all roots or invalid parent_ids)", 
                    model.bones.len(), model.helpers.len());
            }
        } else {
            self.num_skeleton_lines = 0;
        }
    }

    pub fn rotate_camera(&mut self, delta_x: f32, delta_y: f32) {
        self.camera_yaw -= delta_x * 0.01; // Inverted for natural rotation
        self.camera_pitch += delta_y * 0.01;
        self.camera_pitch = self.camera_pitch.clamp(-1.5, 1.5);
    }

    pub fn zoom_camera(&mut self, delta: f32) {
        self.camera_distance -= delta * 10.0;
        self.camera_distance = self.camera_distance.clamp(10.0, 1000.0);
    }
}