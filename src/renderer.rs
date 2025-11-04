use std::sync::Arc;
use wgpu::util::DeviceExt;
use crate::model::{Model, FilterMode};
use crate::material_system::MaterialUniform;
use egui_wgpu::ScreenDescriptor;

#[repr(C)]
#[derive(Copy, Clone, Debug, bytemuck::Pod, bytemuck::Zeroable)]
pub struct Vertex {
    position: [f32; 3],
    normal: [f32; 3],
    uv: [f32; 2],
}

impl Vertex {
    pub fn desc() -> wgpu::VertexBufferLayout<'static> {
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
                wgpu::VertexAttribute {
                    offset: (std::mem::size_of::<[f32; 3]>() * 2) as wgpu::BufferAddress,
                    shader_location: 2,
                    format: wgpu::VertexFormat::Float32x2,
                },
            ],
        }
    }
}

#[repr(C)]
#[derive(Copy, Clone, Debug, bytemuck::Pod, bytemuck::Zeroable)]
pub struct LineVertex {
    position: [f32; 3],
    color: [f32; 3],
}

impl LineVertex {
    pub fn desc() -> wgpu::VertexBufferLayout<'static> {
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

#[derive(Debug)]
struct GeosetRenderInfo {
    index_start: u32,
    index_count: u32,
    material_id: Option<usize>,
}

pub struct Renderer {
    surface: wgpu::Surface<'static>,
    device: wgpu::Device,
    queue: wgpu::Queue,
    config: wgpu::SurfaceConfiguration,
    render_pipeline: wgpu::RenderPipeline,
    wireframe_pipeline: wgpu::RenderPipeline,
    transparent_pipeline: wgpu::RenderPipeline,
    wireframe_transparent_pipeline: wgpu::RenderPipeline,
    additive_pipeline: wgpu::RenderPipeline,
    wireframe_additive_pipeline: wgpu::RenderPipeline,
    line_pipeline: wgpu::RenderPipeline,
    vertex_buffer: wgpu::Buffer,
    index_buffer: wgpu::Buffer,
    num_indices: u32,
    geosets: Vec<GeosetRenderInfo>,
    materials: Vec<crate::model::Material>,
    textures: Vec<crate::model::Texture>,
    line_vertex_buffer: wgpu::Buffer,
    num_lines: u32,
    skeleton_vertex_buffer: wgpu::Buffer,
    num_skeleton_lines: u32,
    bounding_box_vertex_buffer: wgpu::Buffer,
    num_bounding_box_lines: u32,
    camera_buffer: wgpu::Buffer,
    camera_bind_group: wgpu::BindGroup,
    texture_bind_groups: Vec<wgpu::BindGroup>, // One bind group per texture
    team_color_bind_group: wgpu::BindGroup,
    texture_bind_group_layout: wgpu::BindGroupLayout,
    // Material uniforms - three bind groups: normal, team color, team glow
    material_buffer_normal: wgpu::Buffer,
    material_buffer_team: wgpu::Buffer,
    material_buffer_team_glow: wgpu::Buffer,
    material_bind_group_normal: wgpu::BindGroup,
    material_bind_group_team: wgpu::BindGroup,
    material_bind_group_team_glow: wgpu::BindGroup,
    material_bind_group_layout: wgpu::BindGroupLayout,
    // Store white texture components to create bind groups for missing textures
    white_texture_view: wgpu::TextureView,
    white_texture_sampler: wgpu::Sampler,
    team_color: [f32; 3],
    team_color_id: u8, // 0-15 for different team colors
    grid_major_color: [f32; 3],
    grid_minor_color: [f32; 3],
    skybox_color: [f32; 3], 
    camera_yaw: f32,
    camera_pitch: f32,
    camera_distance: f32,
    default_camera_yaw: f32,
    default_camera_pitch: f32,
    default_camera_distance: f32,
    model_center: [f32; 3],
    egui_renderer: egui_wgpu::Renderer,
    egui_ctx: egui::Context,
    view_proj_matrix: nalgebra_glm::Mat4,
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
                required_features: wgpu::Features::POLYGON_MODE_LINE, // Required for wireframe mode
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

        // Create material uniform buffers - normal, team color, team glow
        let material_uniform_normal = MaterialUniform::normal(false, FilterMode::Opaque);
        let material_uniform_team = MaterialUniform::team_color([1.0, 0.0, 0.0], false, FilterMode::Opaque, false);
        let material_uniform_team_glow = MaterialUniform::team_color([1.0, 0.0, 0.0], false, FilterMode::Opaque, true);
        
        let material_buffer_normal = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("Material Buffer Normal"),
            contents: bytemuck::cast_slice(&[material_uniform_normal]),
            usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
        });
        
        let material_buffer_team = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("Material Buffer Team"),
            contents: bytemuck::cast_slice(&[material_uniform_team]),
            usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
        });
        
        let material_buffer_team_glow = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("Material Buffer Team Glow"),
            contents: bytemuck::cast_slice(&[material_uniform_team_glow]),
            usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
        });
        
        let material_bind_group_layout = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
            label: Some("Material Bind Group Layout"),
            entries: &[wgpu::BindGroupLayoutEntry {
                binding: 0,
                visibility: wgpu::ShaderStages::FRAGMENT,
                ty: wgpu::BindingType::Buffer {
                    ty: wgpu::BufferBindingType::Uniform,
                    has_dynamic_offset: false,
                    min_binding_size: None,
                },
                count: None,
            }],
        });
        
        let material_bind_group_normal = device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("Material Bind Group Normal"),
            layout: &material_bind_group_layout,
            entries: &[wgpu::BindGroupEntry {
                binding: 0,
                resource: material_buffer_normal.as_entire_binding(),
            }],
        });
        
        let material_bind_group_team = device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("Material Bind Group Team"),
            layout: &material_bind_group_layout,
            entries: &[wgpu::BindGroupEntry {
                binding: 0,
                resource: material_buffer_team.as_entire_binding(),
            }],
        });
        
        let material_bind_group_team_glow = device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("Material Bind Group Team Glow"),
            layout: &material_bind_group_layout,
            entries: &[wgpu::BindGroupEntry {
                binding: 0,
                resource: material_buffer_team_glow.as_entire_binding(),
            }],
        });

        // Create default white 1x1 texture (for non-team-color materials)
        let texture_size = wgpu::Extent3d {
            width: 1,
            height: 1,
            depth_or_array_layers: 1,
        };
        
        let diffuse_texture = device.create_texture(&wgpu::TextureDescriptor {
            label: Some("Default White Texture"),
            size: texture_size,
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: wgpu::TextureFormat::Rgba8UnormSrgb,
            usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
            view_formats: &[],
        });
        
        // Write WHITE pixel data (opaque white for normal materials)
        queue.write_texture(
            wgpu::TexelCopyTextureInfo {
                texture: &diffuse_texture,
                mip_level: 0,
                origin: wgpu::Origin3d::ZERO,
                aspect: wgpu::TextureAspect::All,
            },
            &[255, 255, 255, 255], // RGBA white opaque
            wgpu::TexelCopyBufferLayout {
                offset: 0,
                bytes_per_row: Some(4),
                rows_per_image: Some(1),
            },
            texture_size,
        );
        
        let diffuse_texture_view = diffuse_texture.create_view(&wgpu::TextureViewDescriptor::default());
        let diffuse_sampler = device.create_sampler(&wgpu::SamplerDescriptor {
            label: Some("Default Sampler"),
            address_mode_u: wgpu::AddressMode::Repeat,
            address_mode_v: wgpu::AddressMode::Repeat,
            address_mode_w: wgpu::AddressMode::Repeat,
            mag_filter: wgpu::FilterMode::Linear,
            min_filter: wgpu::FilterMode::Linear,
            mipmap_filter: wgpu::FilterMode::Nearest,
            ..Default::default()
        });
        
        // Create texture bind group layout
        let texture_bind_group_layout = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
            label: Some("Texture Bind Group Layout"),
            entries: &[
                wgpu::BindGroupLayoutEntry {
                    binding: 0,
                    visibility: wgpu::ShaderStages::FRAGMENT,
                    ty: wgpu::BindingType::Texture {
                        sample_type: wgpu::TextureSampleType::Float { filterable: true },
                        view_dimension: wgpu::TextureViewDimension::D2,
                        multisampled: false,
                    },
                    count: None,
                },
                wgpu::BindGroupLayoutEntry {
                    binding: 1,
                    visibility: wgpu::ShaderStages::FRAGMENT,
                    ty: wgpu::BindingType::Sampler(wgpu::SamplerBindingType::Filtering),
                    count: None,
                },
            ],
        });
        
        // Create initial bind group for white texture
        let initial_bind_group = device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("White Texture Bind Group"),
            layout: &texture_bind_group_layout,
            entries: &[
                wgpu::BindGroupEntry {
                    binding: 0,
                    resource: wgpu::BindingResource::TextureView(&diffuse_texture_view),
                },
                wgpu::BindGroupEntry {
                    binding: 1,
                    resource: wgpu::BindingResource::Sampler(&diffuse_sampler),
                },
            ],
        });
        
        // Initialize texture bind groups vector with the white texture
        let texture_bind_groups = vec![initial_bind_group];

        // Create team color texture (red by default to match team_color value)
        let team_color_data = [255u8, 0, 0, 255]; // Red - matches team_color: [1.0, 0.0, 0.0]
        let team_color_texture = device.create_texture(&wgpu::TextureDescriptor {
            label: Some("Team Color Texture"),
            size: wgpu::Extent3d {
                width: 1,
                height: 1,
                depth_or_array_layers: 1,
            },
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: wgpu::TextureFormat::Rgba8UnormSrgb,
            usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
            view_formats: &[],
        });

        queue.write_texture(
            wgpu::TexelCopyTextureInfo {
                texture: &team_color_texture,
                mip_level: 0,
                origin: wgpu::Origin3d::ZERO,
                aspect: wgpu::TextureAspect::All,
            },
            &team_color_data,
            wgpu::TexelCopyBufferLayout {
                offset: 0,
                bytes_per_row: Some(4),
                rows_per_image: Some(1),
            },
            wgpu::Extent3d {
                width: 1,
                height: 1,
                depth_or_array_layers: 1,
            },
        );

        let team_color_texture_view = team_color_texture.create_view(&wgpu::TextureViewDescriptor::default());
        
        let team_color_bind_group = device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("Team Color Bind Group"),
            layout: &texture_bind_group_layout,
            entries: &[
                wgpu::BindGroupEntry {
                    binding: 0,
                    resource: wgpu::BindingResource::TextureView(&team_color_texture_view),
                },
                wgpu::BindGroupEntry {
                    binding: 1,
                    resource: wgpu::BindingResource::Sampler(&diffuse_sampler),
                },
            ],
        });

        let render_pipeline_layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
            label: Some("Render Pipeline Layout"),
            bind_group_layouts: &[&camera_bind_group_layout, &texture_bind_group_layout, &material_bind_group_layout],
            push_constant_ranges: &[],
        });

        // Create separate layout for lines (no textures)
        let line_pipeline_layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
            label: Some("Line Pipeline Layout"),
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
                    blend: Some(wgpu::BlendState::REPLACE), // Opaque materials replace background
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

        // Wireframe pipeline - same as render pipeline but with Line mode
        let wireframe_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("Wireframe Pipeline"),
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
                    blend: Some(wgpu::BlendState::ALPHA_BLENDING),
                    write_mask: wgpu::ColorWrites::ALL,
                })],
                compilation_options: wgpu::PipelineCompilationOptions::default(),
            }),
            primitive: wgpu::PrimitiveState {
                topology: wgpu::PrimitiveTopology::TriangleList,
                strip_index_format: None,
                front_face: wgpu::FrontFace::Cw,
                cull_mode: None,
                polygon_mode: wgpu::PolygonMode::Line, // Wireframe mode!
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

        // Create transparent rendering pipeline (depth write OFF, depth test ON)
        let transparent_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("Transparent Pipeline"),
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
                    blend: Some(wgpu::BlendState::ALPHA_BLENDING),
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
                depth_write_enabled: false, // Don't write depth for transparent materials
                depth_compare: wgpu::CompareFunction::Less, // But still test against depth
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

        // Create wireframe transparent rendering pipeline (same as transparent but with wireframe mode)
        let wireframe_transparent_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("Wireframe Transparent Pipeline"),
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
                    blend: Some(wgpu::BlendState::ALPHA_BLENDING),
                    write_mask: wgpu::ColorWrites::ALL,
                })],
                compilation_options: wgpu::PipelineCompilationOptions::default(),
            }),
            primitive: wgpu::PrimitiveState {
                topology: wgpu::PrimitiveTopology::TriangleList,
                strip_index_format: None,
                front_face: wgpu::FrontFace::Cw,
                cull_mode: None,
                polygon_mode: wgpu::PolygonMode::Line, // Wireframe mode!
                unclipped_depth: false,
                conservative: false,
            },
            depth_stencil: Some(wgpu::DepthStencilState {
                format: wgpu::TextureFormat::Depth32Float,
                depth_write_enabled: false, // Don't write depth for transparent materials
                depth_compare: wgpu::CompareFunction::Less, // But still test against depth
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

        // Create additive rendering pipeline (GL_ONE, GL_ONE) for glow effects
        let additive_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("Additive Pipeline"),
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
                    blend: Some(wgpu::BlendState {
                        color: wgpu::BlendComponent {
                            src_factor: wgpu::BlendFactor::One,
                            dst_factor: wgpu::BlendFactor::One,
                            operation: wgpu::BlendOperation::Add,
                        },
                        alpha: wgpu::BlendComponent {
                            src_factor: wgpu::BlendFactor::One,
                            dst_factor: wgpu::BlendFactor::One,
                            operation: wgpu::BlendOperation::Add,
                        },
                    }),
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
                depth_write_enabled: false, // Don't write depth for additive materials
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

        // Create wireframe additive rendering pipeline
        let wireframe_additive_pipeline = device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("Wireframe Additive Pipeline"),
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
                    blend: Some(wgpu::BlendState {
                        color: wgpu::BlendComponent {
                            src_factor: wgpu::BlendFactor::One,
                            dst_factor: wgpu::BlendFactor::One,
                            operation: wgpu::BlendOperation::Add,
                        },
                        alpha: wgpu::BlendComponent {
                            src_factor: wgpu::BlendFactor::One,
                            dst_factor: wgpu::BlendFactor::One,
                            operation: wgpu::BlendOperation::Add,
                        },
                    }),
                    write_mask: wgpu::ColorWrites::ALL,
                })],
                compilation_options: wgpu::PipelineCompilationOptions::default(),
            }),
            primitive: wgpu::PrimitiveState {
                topology: wgpu::PrimitiveTopology::TriangleList,
                strip_index_format: None,
                front_face: wgpu::FrontFace::Cw,
                cull_mode: None,
                polygon_mode: wgpu::PolygonMode::Line, // Wireframe mode!
                unclipped_depth: false,
                conservative: false,
            },
            depth_stencil: Some(wgpu::DepthStencilState {
                format: wgpu::TextureFormat::Depth32Float,
                depth_write_enabled: false,
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
            layout: Some(&line_pipeline_layout),
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
                    blend: Some(wgpu::BlendState::ALPHA_BLENDING),
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

        // Create empty bounding box buffer initially
        let bounding_box_vertex_buffer = device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("Bounding Box Vertex Buffer"),
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
            wireframe_pipeline,
            transparent_pipeline,
            wireframe_transparent_pipeline,
            additive_pipeline,
            wireframe_additive_pipeline,
            line_pipeline,
            vertex_buffer,
            index_buffer,
            num_indices: 0,
            geosets: Vec::new(),
            materials: Vec::new(),
            textures: Vec::new(),
            line_vertex_buffer,
            num_lines,
            skeleton_vertex_buffer,
            num_skeleton_lines: 0,
            bounding_box_vertex_buffer,
            num_bounding_box_lines: 0,
            camera_buffer,
            camera_bind_group,
            texture_bind_groups,
            team_color_bind_group,
            texture_bind_group_layout,
            material_buffer_normal,
            material_buffer_team,
            material_buffer_team_glow,
            material_bind_group_normal,
            material_bind_group_team,
            material_bind_group_team_glow,
            material_bind_group_layout,
            white_texture_view: diffuse_texture_view,
            white_texture_sampler: diffuse_sampler,
            team_color: [1.0, 0.0, 0.0], // Red by default
            team_color_id: 0, // Red team color
            grid_major_color: [0.2, 0.2, 0.2], // Dark gray major grid
            grid_minor_color: [0.4, 0.4, 0.4], // Light gray minor grid
            skybox_color: [0.3, 0.5, 0.8], // Light blue skybox
            camera_yaw: 0.0, // 0 degrees - front view
            camera_pitch: std::f32::consts::PI * 0.15, // 27 degrees - look slightly down at model
            camera_distance: 200.0,
            default_camera_yaw: 0.0,
            default_camera_pitch: std::f32::consts::PI * 0.15,
            default_camera_distance: 200.0,
            model_center: [0.0, 0.0, 0.0],
            egui_renderer,
            egui_ctx,
            view_proj_matrix: nalgebra_glm::Mat4::identity(),
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

    pub fn render(&mut self, show_skeleton: bool, show_grid: bool, show_bounding_box: bool, wireframe_mode: bool, far_plane: f32, panel_width: f32, show_geosets: &Vec<bool>, _paint_jobs: Vec<egui::ClippedPrimitive>, _textures_delta: egui::TexturesDelta, _screen_descriptor: ScreenDescriptor) -> Result<(), wgpu::SurfaceError> {
        // Calculate viewport dimensions (excluding left panel)
        let panel_width_pixels = (panel_width * _screen_descriptor.pixels_per_point) as f32;
        let viewport_width = self.config.width as f32 - panel_width_pixels;
        let viewport_height = self.config.height as f32;
        
        // Update camera matrix with correct aspect ratio for viewport
        let aspect = viewport_width / viewport_height;
        let proj = nalgebra_glm::perspective(aspect, 45.0_f32.to_radians(), 0.1, far_plane);
        
        let eye = nalgebra_glm::vec3(
            self.model_center[0] + self.camera_distance * self.camera_yaw.cos() * self.camera_pitch.cos(),
            self.model_center[1] + self.camera_distance * self.camera_yaw.sin() * self.camera_pitch.cos(),
            self.model_center[2] + self.camera_distance * self.camera_pitch.sin(),
        );
        let center = nalgebra_glm::vec3(self.model_center[0], self.model_center[1], self.model_center[2]);
        let up = nalgebra_glm::vec3(0.0, 0.0, 1.0); // Z-up coordinate system
        let view = nalgebra_glm::look_at(&eye, &center, &up);
        
        let view_proj = proj * view;
        self.view_proj_matrix = view_proj; // Store for axis label projection
        self.queue.write_buffer(&self.camera_buffer, 0, bytemuck::cast_slice(view_proj.as_slice()));

        // Helper closure to update material uniform for specific geoset
        let update_material_uniform = |geoset: &GeosetRenderInfo, is_team_color: bool, is_team_glow: bool| -> MaterialUniform {
            let filter_mode = if let Some(mat_id) = geoset.material_id {
                if mat_id < self.materials.len() {
                    let material = &self.materials[mat_id];
                    if let Some(layer) = material.layers.first() {
                        layer.filter_mode.clone()
                    } else {
                        FilterMode::Opaque
                    }
                } else {
                    FilterMode::Opaque
                }
            } else {
                FilterMode::Opaque
            };

            if is_team_color {
                MaterialUniform::team_color(self.team_color, wireframe_mode, filter_mode, is_team_glow)
            } else {
                MaterialUniform::normal(wireframe_mode, filter_mode)
            }
        };

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
                            r: self.skybox_color[0] as f64,
                            g: self.skybox_color[1] as f64,
                            b: self.skybox_color[2] as f64,
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

            // Set viewport and scissor to render only in area not covered by left panel
            render_pass.set_viewport(
                panel_width_pixels,
                0.0,
                viewport_width,
                viewport_height,
                0.0,
                1.0,
            );
            
            render_pass.set_scissor_rect(
                panel_width_pixels as u32,
                0,
                viewport_width as u32,
                viewport_height as u32,
            );

            // Draw axes and grid first
            if show_grid {
                render_pass.set_pipeline(&self.line_pipeline);
                render_pass.set_bind_group(0, &self.camera_bind_group, &[]);
                render_pass.set_vertex_buffer(0, self.line_vertex_buffer.slice(..));
                render_pass.draw(0..self.num_lines, 0..1);
            }

            // Draw model in two passes: opaque first (with depth write), then transparent (without depth write)
            if self.num_indices > 0 {
                render_pass.set_bind_group(0, &self.camera_bind_group, &[]);
                render_pass.set_vertex_buffer(0, self.vertex_buffer.slice(..));
                render_pass.set_index_buffer(self.index_buffer.slice(..), wgpu::IndexFormat::Uint16);
                
                // Helper function to check if material uses team glow (ReplaceableID=2)
                let is_team_glow_material = |mat_id: usize| -> bool {
                    if mat_id < self.materials.len() {
                        if let Some(layer) = self.materials[mat_id].layers.first() {
                            if let Some(tex_id) = layer.texture_id {
                                if tex_id < self.textures.len() {
                                    return self.textures[tex_id].replaceable_id == 2;
                                }
                            }
                        }
                    }
                    false
                };

                // Helper closure to render a geoset
                let render_geoset = |render_pass: &mut wgpu::RenderPass, geoset: &GeosetRenderInfo| {
                    // Determine texture, material bind group, and material type
                    let (texture_bind_group, is_team_color, is_team_glow) = if let Some(mat_id) = geoset.material_id {
                        if mat_id < self.materials.len() {
                            let material = &self.materials[mat_id];
                            if let Some(layer) = material.layers.first() {
                                if let Some(tex_id) = layer.texture_id {
                                    if tex_id < self.textures.len() {
                                        let texture = &self.textures[tex_id];
                                        // Distinguish between ReplaceableID=1 (team color) and ReplaceableID=2 (team glow)
                                        if texture.replaceable_id == 1 {
                                            let tex_bg = if tex_id < self.texture_bind_groups.len() {
                                                &self.texture_bind_groups[tex_id]
                                            } else {
                                                &self.texture_bind_groups[0]
                                            };
                                            (tex_bg, true, false) // Team color, NOT glow
                                        } else if texture.replaceable_id == 2 {
                                            let tex_bg = if tex_id < self.texture_bind_groups.len() {
                                                &self.texture_bind_groups[tex_id]
                                            } else {
                                                &self.texture_bind_groups[0]
                                            };
                                            (tex_bg, true, true) // Team glow
                                        } else if tex_id < self.texture_bind_groups.len() {
                                            (&self.texture_bind_groups[tex_id], false, false)
                                        } else {
                                            (&self.texture_bind_groups[0], false, false)
                                        }
                                    } else {
                                        (&self.texture_bind_groups[0], false, false)
                                    }
                                } else {
                                    (&self.texture_bind_groups[0], false, false)
                                }
                            } else {
                                (&self.texture_bind_groups[0], false, false)
                            }
                        } else {
                            (&self.texture_bind_groups[0], false, false)
                        }
                    } else {
                        (&self.texture_bind_groups[0], false, false)
                    };
                    
                    // Update material uniform for this specific geoset
                    let material_uniform = update_material_uniform(geoset, is_team_color, is_team_glow);
                    let (material_buffer, material_bind_group) = if is_team_glow {
                        (&self.material_buffer_team_glow, &self.material_bind_group_team_glow)
                    } else if is_team_color {
                        (&self.material_buffer_team, &self.material_bind_group_team)
                    } else {
                        (&self.material_buffer_normal, &self.material_bind_group_normal)
                    };
                    self.queue.write_buffer(material_buffer, 0, bytemuck::cast_slice(&[material_uniform]));
                    
                    render_pass.set_bind_group(1, texture_bind_group, &[]);
                    render_pass.set_bind_group(2, material_bind_group, &[]);
                    render_pass.draw_indexed(geoset.index_start..(geoset.index_start + geoset.index_count), 0, 0..1);
                };
                
                // PASS 1: Render opaque materials with depth write enabled
                let opaque_pipeline = if wireframe_mode {
                    &self.wireframe_pipeline
                } else {
                    &self.render_pipeline
                };
                render_pass.set_pipeline(opaque_pipeline);
                
                for (geoset_idx, geoset) in self.geosets.iter().enumerate() {
                    // Skip if geoset is hidden via UI
                    if geoset_idx < show_geosets.len() && !show_geosets[geoset_idx] {
                        continue;
                    }
                    
                    if let Some(mat_id) = geoset.material_id {
                        if mat_id < self.materials.len() {
                            let material = &self.materials[mat_id];
                            if let Some(layer) = material.layers.first() {
                                // Render only opaque materials in first pass
                                if layer.filter_mode == crate::model::FilterMode::Opaque {
                                    render_geoset(&mut render_pass, geoset);
                                }
                            }
                        }
                    }
                }
                
                // PASS 2: Render transparent materials (blend mode: SRC_ALPHA, ONE_MINUS_SRC_ALPHA)
                let transparent_pipeline = if wireframe_mode {
                    &self.wireframe_transparent_pipeline
                } else {
                    &self.transparent_pipeline
                };
                render_pass.set_pipeline(transparent_pipeline);
                
                for (geoset_idx, geoset) in self.geosets.iter().enumerate() {
                    // Skip if geoset is hidden via UI
                    if geoset_idx < show_geosets.len() && !show_geosets[geoset_idx] {
                        continue;
                    }
                    
                    if let Some(mat_id) = geoset.material_id {
                        if mat_id < self.materials.len() {
                            let material = &self.materials[mat_id];
                            if let Some(layer) = material.layers.first() {
                                // Render transparent and blend materials in second pass, but exclude team glow
                                if (layer.filter_mode == crate::model::FilterMode::Transparent ||
                                   layer.filter_mode == crate::model::FilterMode::Blend) &&
                                   !is_team_glow_material(mat_id) {
                                    render_geoset(&mut render_pass, geoset);
                                }
                            }
                        }
                    }
                }
                
                // PASS 3: Render additive materials (blend mode: ONE, ONE)
                let additive_pipeline = if wireframe_mode {
                    &self.wireframe_additive_pipeline
                } else {
                    &self.additive_pipeline
                };
                render_pass.set_pipeline(additive_pipeline);
                
                for (geoset_idx, geoset) in self.geosets.iter().enumerate() {
                    // Skip if geoset is hidden via UI
                    if geoset_idx < show_geosets.len() && !show_geosets[geoset_idx] {
                        continue;
                    }
                    
                    if let Some(mat_id) = geoset.material_id {
                        if mat_id < self.materials.len() {
                            let material = &self.materials[mat_id];
                            if let Some(layer) = material.layers.first() {
                                // Render additive materials OR team glow materials in third pass
                                if layer.filter_mode == crate::model::FilterMode::Additive ||
                                   layer.filter_mode == crate::model::FilterMode::AddAlpha ||
                                   is_team_glow_material(mat_id) {
                                    render_geoset(&mut render_pass, geoset);
                                }
                            }
                        }
                    }
                }
            }
            
            // Draw skeleton on top (always visible)
            if show_skeleton && self.num_skeleton_lines > 0 {
                render_pass.set_pipeline(&self.line_pipeline);
                render_pass.set_bind_group(0, &self.camera_bind_group, &[]);
                render_pass.set_vertex_buffer(0, self.skeleton_vertex_buffer.slice(..));
                render_pass.draw(0..(self.num_skeleton_lines * 2), 0..1);
            }
            
            // Draw bounding boxes
            if show_bounding_box && self.num_bounding_box_lines > 0 {
                render_pass.set_pipeline(&self.line_pipeline);
                render_pass.set_bind_group(0, &self.camera_bind_group, &[]);
                render_pass.set_vertex_buffer(0, self.bounding_box_vertex_buffer.slice(..));
                render_pass.draw(0..(self.num_bounding_box_lines * 2), 0..1);
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
        let mut geosets_info: Vec<GeosetRenderInfo> = Vec::new();
        
        for (geoset_idx, geoset) in model.geosets.iter().enumerate() {
            let vertex_offset = all_vertices.len() as u32;
            let index_start = all_indices.len() as u32;
            
            // Add vertices from this geoset with UV coordinates
            for i in 0..geoset.vertices.len() {
                let uv = if i < geoset.tex_coords.len() {
                    geoset.tex_coords[i].uv
                } else {
                    [0.0, 0.0] // Default UV if not available
                };
                
                all_vertices.push(Vertex {
                    position: geoset.vertices[i].position,
                    normal: if i < geoset.normals.len() {
                        geoset.normals[i].normal
                    } else {
                        [0.0, 0.0, 1.0] // Default normal
                    },
                    uv,
                });
            }
            
            // Add indices from this geoset, offsetting by current vertex count
            for face in &geoset.faces {
                for &idx in &face.vertices {
                    all_indices.push((vertex_offset + idx) as u16);
                }
            }
            
            let index_count = (all_indices.len() as u32) - index_start;
            
            geosets_info.push(GeosetRenderInfo {
                index_start,
                index_count,
                material_id: geoset.material_id,
            });
            
            println!("  Geoset {}: added {} vertices, {} UVs, {} faces, material_id: {:?}", 
                geoset_idx, geoset.vertices.len(), geoset.tex_coords.len(), geoset.faces.len(), geoset.material_id);
        }

        self.geosets = geosets_info;
        self.materials = model.materials.clone();
        self.textures = model.textures.clone();

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

        // Generate bounding box lines from geosets
        self.generate_bounding_box_lines(model);
    }

    /// Generate bounding box lines from all geosets
    fn generate_bounding_box_lines(&mut self, model: &crate::model::Model) {
        let bbox_color = [1.0, 1.0, 0.0]; // Yellow for bounding box - will be updated from settings
        self.generate_bounding_box_lines_with_color(model, bbox_color);
    }
    
    fn generate_bounding_box_lines_with_color(&mut self, model: &crate::model::Model, bbox_color: [f32; 3]) {
        let mut bbox_vertices = Vec::new();
        
        // Calculate overall model bounding box
        let mut overall_min = [f32::INFINITY, f32::INFINITY, f32::INFINITY];
        let mut overall_max = [f32::NEG_INFINITY, f32::NEG_INFINITY, f32::NEG_INFINITY];
        let mut has_valid_bbox = false;
        
        for geoset in &model.geosets {
            let min = geoset.minimum_extent;
            let max = geoset.maximum_extent;
            
            // Skip if bounding box is invalid
            if min[0] >= max[0] || min[1] >= max[1] || min[2] >= max[2] {
                continue;
            }
            
            // Update overall bounds
            for i in 0..3 {
                overall_min[i] = overall_min[i].min(min[i]);
                overall_max[i] = overall_max[i].max(max[i]);
            }
            has_valid_bbox = true;
        }
        
        if has_valid_bbox {
            // Create wireframe cube for the overall model bounding box
            let vertices = [
                // Bottom face (Z = min[2])
                [overall_min[0], overall_min[1], overall_min[2]], // 0: min corner
                [overall_max[0], overall_min[1], overall_min[2]], // 1: +X
                [overall_max[0], overall_max[1], overall_min[2]], // 2: +X+Y  
                [overall_min[0], overall_max[1], overall_min[2]], // 3: +Y
                // Top face (Z = max[2])
                [overall_min[0], overall_min[1], overall_max[2]], // 4: +Z
                [overall_max[0], overall_min[1], overall_max[2]], // 5: +X+Z
                [overall_max[0], overall_max[1], overall_max[2]], // 6: +X+Y+Z (max corner)
                [overall_min[0], overall_max[1], overall_max[2]], // 7: +Y+Z
            ];
            
            // Bottom face edges
            for i in 0..4 {
                let next = (i + 1) % 4;
                bbox_vertices.push(LineVertex { position: vertices[i], color: bbox_color });
                bbox_vertices.push(LineVertex { position: vertices[next], color: bbox_color });
            }
            
            // Top face edges  
            for i in 4..8 {
                let next = 4 + ((i - 4 + 1) % 4);
                bbox_vertices.push(LineVertex { position: vertices[i], color: bbox_color });
                bbox_vertices.push(LineVertex { position: vertices[next], color: bbox_color });
            }
            
            // Vertical edges connecting bottom to top
            for i in 0..4 {
                bbox_vertices.push(LineVertex { position: vertices[i], color: bbox_color });
                bbox_vertices.push(LineVertex { position: vertices[i + 4], color: bbox_color });
            }
            
            let box_size = [
                overall_max[0] - overall_min[0],
                overall_max[1] - overall_min[1], 
                overall_max[2] - overall_min[2]
            ];
            
            println!("Model bounding box: min={:?}, max={:?}, size={:?}", 
                overall_min, overall_max, box_size);
        }
        
        if !bbox_vertices.is_empty() {
            self.bounding_box_vertex_buffer = self.device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("Bounding Box Vertex Buffer"), 
                contents: bytemuck::cast_slice(&bbox_vertices),
                usage: wgpu::BufferUsages::VERTEX,
            });
            self.num_bounding_box_lines = (bbox_vertices.len() / 2) as u32;
            println!("Generated {} bounding box lines for overall model ({} geosets)", 
                self.num_bounding_box_lines, model.geosets.len());
        } else {
            self.num_bounding_box_lines = 0;
            println!("No valid bounding boxes found in geosets");
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

    pub fn reset_camera(&mut self) {
        self.camera_yaw = self.default_camera_yaw;
        self.camera_pitch = self.default_camera_pitch;
        self.camera_distance = self.default_camera_distance;
    }
    
    pub fn get_camera_orientation(&self) -> (f32, f32) {
        (self.camera_yaw, self.camera_pitch)
    }

    pub fn update_colors(&mut self, settings: &crate::settings::Settings, model: Option<&crate::model::Model>) {
        // Update team color
        self.set_team_color(settings.team_color);
        
        // Update grid colors
        self.grid_major_color = settings.grid_major_color;
        self.grid_minor_color = settings.grid_minor_color;
        self.regenerate_grid();
        
        // Update skybox color
        self.skybox_color = settings.skybox_color;
        
        // Update bounding box color if model is loaded
        if let Some(model) = model {
            if settings.show_bounding_box {
                self.generate_bounding_box_lines_with_color(model, settings.bounding_box_color);
            }
        }
    }
    
    /// Regenerate grid with current grid color
    fn regenerate_grid(&mut self) {
        let mut line_vertices = Vec::new();
        
        // Axes - red X, green Y, blue Z
        line_vertices.push(LineVertex { position: [0.0, 0.0, 0.0], color: [1.0, 0.0, 0.0] });
        line_vertices.push(LineVertex { position: [210.0, 0.0, 0.0], color: [1.0, 0.0, 0.0] });
        line_vertices.push(LineVertex { position: [0.0, 0.0, 0.0], color: [0.0, 1.0, 0.0] });
        line_vertices.push(LineVertex { position: [0.0, 210.0, 0.0], color: [0.0, 1.0, 0.0] });
        
        // Minor grid - XY plane (every 8 units)
        for i in -32..=32 {
            let pos = i as f32 * 8.0;
            line_vertices.push(LineVertex { position: [pos, -256.0, 0.0], color: self.grid_minor_color });
            line_vertices.push(LineVertex { position: [pos, 256.0, 0.0], color: self.grid_minor_color });
            line_vertices.push(LineVertex { position: [-256.0, pos, 0.0], color: self.grid_minor_color });
            line_vertices.push(LineVertex { position: [256.0, pos, 0.0], color: self.grid_minor_color });
        }
        
        // Major grid - XY plane (every 64 units)
        for i in -4..=4 {
            let pos = i as f32 * 64.0;
            line_vertices.push(LineVertex { position: [pos, -256.0, 0.0], color: self.grid_major_color });
            line_vertices.push(LineVertex { position: [pos, 256.0, 0.0], color: self.grid_major_color });
            line_vertices.push(LineVertex { position: [-256.0, pos, 0.0], color: self.grid_major_color });
            line_vertices.push(LineVertex { position: [256.0, pos, 0.0], color: self.grid_major_color });
        }

        // Update line vertex buffer
        self.line_vertex_buffer = self.device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("Line Vertex Buffer"),
            contents: bytemuck::cast_slice(&line_vertices),
            usage: wgpu::BufferUsages::VERTEX,
        });
        self.num_lines = line_vertices.len() as u32;
    }

    pub fn set_team_color(&mut self, color: [f32; 3]) {
        self.team_color = color;
        
        // Update team material buffer - use default values since actual material type will be set during rendering
        let material_uniform = MaterialUniform::team_color(color, false, FilterMode::Opaque, false);
        
        self.queue.write_buffer(&self.material_buffer_team, 0, bytemuck::cast_slice(&[material_uniform]));
    }

    pub fn get_team_color(&self) -> [f32; 3] {
        self.team_color
    }

    /// Project a 3D world position to 2D screen coordinates
    /// Returns None if behind camera or outside viewport with margin
    pub fn project_to_screen(&self, world_pos: [f32; 3]) -> Option<[f32; 2]> {
        let point = nalgebra_glm::vec4(world_pos[0], world_pos[1], world_pos[2], 1.0);
        let clip_space = self.view_proj_matrix * point;
        
        // Perspective divide
        if clip_space.w <= 0.0 {
            return None; // Behind camera
        }
        
        let ndc = nalgebra_glm::vec3(
            clip_space.x / clip_space.w,
            clip_space.y / clip_space.w,
            clip_space.z / clip_space.w,
        );
        
        // Check if in NDC bounds (strict check - must be fully on screen)
        if ndc.x < -1.0 || ndc.x > 1.0 || ndc.y < -1.0 || ndc.y > 1.0 {
            return None;
        }
        
        // Convert to screen coordinates
        let screen_x = (ndc.x + 1.0) * 0.5 * self.config.width as f32;
        let screen_y = (1.0 - ndc.y) * 0.5 * self.config.height as f32; // Flip Y
        
        Some([screen_x, screen_y])
    }

    pub fn get_viewport_size(&self) -> [u32; 2] {
        [self.config.width, self.config.height]
    }

    /// Get screen positions for axis labels
    /// Returns (X_pos, Y_pos, Z_pos) or None if off-screen
    pub fn get_axis_label_positions(&self) -> (Option<[f32; 2]>, Option<[f32; 2]>, Option<[f32; 2]>) {
        // Calculate current view_proj matrix (not using cached one to avoid one-frame lag)
        let aspect = self.config.width as f32 / self.config.height as f32;
        let proj = nalgebra_glm::perspective(aspect, 45.0_f32.to_radians(), 0.1, 1000.0);
        
        let eye = nalgebra_glm::vec3(
            self.model_center[0] + self.camera_distance * self.camera_yaw.cos() * self.camera_pitch.cos(),
            self.model_center[1] + self.camera_distance * self.camera_yaw.sin() * self.camera_pitch.cos(),
            self.model_center[2] + self.camera_distance * self.camera_pitch.sin(),
        );
        let center = nalgebra_glm::vec3(self.model_center[0], self.model_center[1], self.model_center[2]);
        let up = nalgebra_glm::vec3(0.0, 0.0, 1.0);
        let view = nalgebra_glm::look_at(&eye, &center, &up);
        let view_proj = proj * view;
        
        // Project axis endpoints at world origin (0,0,0)
        let axis_length = 150.0;
        let x_end = [axis_length, 0.0, 0.0];
        let y_end = [0.0, axis_length, 0.0];
        let z_end = [0.0, 0.0, axis_length];
        
        let project = |world_pos: [f32; 3]| -> Option<[f32; 2]> {
            let point = nalgebra_glm::vec4(world_pos[0], world_pos[1], world_pos[2], 1.0);
            let clip_space = view_proj * point;
            
            if clip_space.w <= 0.0 {
                return None;
            }
            
            let ndc = nalgebra_glm::vec3(
                clip_space.x / clip_space.w,
                clip_space.y / clip_space.w,
                clip_space.z / clip_space.w,
            );
            
            if ndc.x < -1.0 || ndc.x > 1.0 || ndc.y < -1.0 || ndc.y > 1.0 {
                return None;
            }
            
            let screen_x = (ndc.x + 1.0) * 0.5 * self.config.width as f32;
            let screen_y = (1.0 - ndc.y) * 0.5 * self.config.height as f32;
            
            Some([screen_x, screen_y])
        };
        
        (
            project(x_end),
            project(y_end),
            project(z_end),
        )
    }
    
    /// Load texture from RGBA data and update or add texture bind group
    pub fn load_texture_from_rgba(&mut self, rgba_data: &[u8], width: u32, height: u32, texture_id: usize) {
        let texture_size = wgpu::Extent3d {
            width,
            height,
            depth_or_array_layers: 1,
        };
        
        let texture = self.device.create_texture(&wgpu::TextureDescriptor {
            label: Some("Loaded Texture"),
            size: texture_size,
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: wgpu::TextureFormat::Rgba8UnormSrgb,
            usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
            view_formats: &[],
        });
        
        self.queue.write_texture(
            wgpu::TexelCopyTextureInfo {
                texture: &texture,
                mip_level: 0,
                origin: wgpu::Origin3d::ZERO,
                aspect: wgpu::TextureAspect::All,
            },
            rgba_data,
            wgpu::TexelCopyBufferLayout {
                offset: 0,
                bytes_per_row: Some(4 * width),
                rows_per_image: Some(height),
            },
            texture_size,
        );
        
        let texture_view = texture.create_view(&wgpu::TextureViewDescriptor::default());
        let sampler = self.device.create_sampler(&wgpu::SamplerDescriptor {
            label: Some("Texture Sampler"),
            address_mode_u: wgpu::AddressMode::ClampToEdge,
            address_mode_v: wgpu::AddressMode::ClampToEdge,
            address_mode_w: wgpu::AddressMode::ClampToEdge,
            mag_filter: wgpu::FilterMode::Linear,
            min_filter: wgpu::FilterMode::Linear,
            mipmap_filter: wgpu::FilterMode::Linear,
            ..Default::default()
        });
        
        // Create new bind group for this texture
        let bind_group = self.device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("Texture Bind Group"),
            layout: &self.texture_bind_group_layout,
            entries: &[
                wgpu::BindGroupEntry {
                    binding: 0,
                    resource: wgpu::BindingResource::TextureView(&texture_view),
                },
                wgpu::BindGroupEntry {
                    binding: 1,
                    resource: wgpu::BindingResource::Sampler(&sampler),
                },
            ],
        });
        
        // Ensure the vector is large enough
        while self.texture_bind_groups.len() <= texture_id {
            // Fill gaps with white texture bind groups
            let white_bind_group = self.device.create_bind_group(&wgpu::BindGroupDescriptor {
                label: Some("White Texture Bind Group (Gap Filler)"),
                layout: &self.texture_bind_group_layout,
                entries: &[
                    wgpu::BindGroupEntry {
                        binding: 0,
                        resource: wgpu::BindingResource::TextureView(&self.white_texture_view),
                    },
                    wgpu::BindGroupEntry {
                        binding: 1,
                        resource: wgpu::BindingResource::Sampler(&self.white_texture_sampler),
                    },
                ],
            });
            self.texture_bind_groups.push(white_bind_group);
        }
        
        // Update the bind group for this texture ID
        self.texture_bind_groups[texture_id] = bind_group;
        
        println!("Loaded texture {} ({}x{})", texture_id, width, height);
    }
    
    /// Create team glow texture (32x32 with alpha map from WC3)
    pub fn create_team_glow_texture(&mut self, texture_id: usize) {
        // Team glow alpha map from WC3 (32x32) - from delphi/glow.pas
        const TEAM_GLOW_ALPHA: [u8; 1024] = [
            1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
            1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,2,2,2,2,3,3,3,3,3,3,3,2,2,2,1,1,1,1,0,0,0,0,0,1,
            1,1,1,1,1,1,1,1,1,2,2,3,4,5,6,6,6,6,5,4,3,2,2,1,2,2,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,3,4,6,7,9,9,10,9,8,7,5,3,2,1,3,2,2,1,0,0,0,0,
            1,1,1,1,1,1,1,1,3,4,6,8,10,13,14,15,17,16,15,12,10,7,6,5,4,3,2,1,0,0,0,0,1,1,1,1,1,1,1,1,7,8,10,13,16,18,20,22,24,23,21,18,15,12,10,9,4,3,2,1,0,0,0,0,
            0,0,1,1,0,1,3,4,5,9,15,20,25,30,35,38,38,36,34,31,26,20,13,9,9,6,2,1,0,1,1,0,0,0,1,1,0,1,3,5,10,15,21,28,35,41,47,50,51,49,46,41,36,28,20,15,10,7,3,1,0,1,1,0,
            0,0,1,1,1,2,4,7,15,20,28,38,47,55,62,67,69,67,62,56,47,37,28,21,12,9,4,1,1,1,1,0,0,0,1,1,1,3,6,9,16,23,33,45,57,68,78,83,87,83,77,69,58,45,33,25,15,11,6,2,1,1,1,0,
            0,0,1,1,1,4,8,11,19,27,39,53,67,81,92,99,103,99,91,81,68,53,39,30,18,13,7,3,1,1,1,1,0,0,1,0,1,5,9,13,24,32,46,61,77,92,105,112,116,112,104,93,78,61,45,35,20,16,9,4,1,1,1,1,
            0,0,0,0,2,5,11,14,27,36,50,67,84,100,113,120,124,120,112,100,84,66,49,39,23,17,10,4,1,1,1,1,0,0,0,0,2,6,11,15,28,36,51,68,85,102,115,123,127,122,114,102,86,67,50,40,24,18,11,4,1,1,1,1,
            1,1,1,1,2,5,11,15,25,36,51,67,82,97,112,121,123,118,110,98,83,66,49,39,22,17,10,4,2,1,0,0,1,1,1,1,2,5,10,14,24,34,48,63,77,90,104,113,116,111,103,92,78,61,46,36,20,16,9,4,1,1,0,0,
            1,1,1,1,1,4,9,12,22,30,43,56,68,80,92,99,104,99,92,82,69,54,39,30,18,14,8,3,1,1,0,0,1,1,1,1,1,3,7,10,18,25,35,47,58,69,78,84,88,84,78,69,58,45,33,25,16,12,6,3,1,1,0,0,
            0,1,1,1,1,2,5,8,13,18,27,37,47,56,64,68,70,67,62,55,47,37,26,20,12,9,5,2,1,1,0,0,0,1,1,1,0,1,4,6,9,13,19,27,36,43,48,51,52,50,46,41,35,28,20,14,10,7,3,1,1,1,0,0,
            0,1,1,1,0,1,3,4,7,9,13,19,25,30,33,34,36,34,32,29,25,20,14,9,8,5,2,1,1,1,0,0,0,1,1,1,0,0,2,4,6,7,9,13,18,21,23,23,27,25,23,21,19,15,9,6,6,4,2,0,0,1,0,0,
            1,1,1,1,1,1,1,1,4,5,6,8,10,12,13,14,16,15,14,12,10,8,7,6,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,3,4,6,7,8,10,10,10,9,8,7,5,4,3,2,1,1,1,1,1,1,1,1,
            1,1,1,1,1,1,1,1,1,1,2,2,3,4,5,5,5,4,4,3,2,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,1,1,1,2,2,3,3,2,2,2,2,1,1,1,1,1,1,1,1,1,1,
            1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,
            1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1
        ];
        
        // Create RGBA texture with pre-multiplied alpha to avoid filtering artifacts
        // This matches Delphi implementation: RGB = white * (alpha/255)
        let mut rgba_data = Vec::with_capacity(32 * 32 * 4);
        for alpha_byte in &TEAM_GLOW_ALPHA {
            let alpha = (*alpha_byte as f32 / 127.0 * 255.0) as u8; // Scale 0-127 to 0-255
            // Pre-multiply: RGB = white * (alpha/255) to prevent visible edges during filtering
            rgba_data.push(alpha); // R - pre-multiplied
            rgba_data.push(alpha); // G - pre-multiplied
            rgba_data.push(alpha); // B - pre-multiplied
            rgba_data.push(alpha); // A - from map
        }
        
        self.load_texture_from_rgba(&rgba_data, 32, 32, texture_id);
        println!("Created team glow texture at index {}", texture_id);
    }
    
    /// Load team color texture from RGBA data
    pub fn load_team_color_texture(&mut self, rgba_data: &[u8], width: u32, height: u32) {
        let texture_size = wgpu::Extent3d {
            width,
            height,
            depth_or_array_layers: 1,
        };
        
        let texture = self.device.create_texture(&wgpu::TextureDescriptor {
            label: Some("Team Color Texture"),
            size: texture_size,
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: wgpu::TextureFormat::Rgba8UnormSrgb,
            usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
            view_formats: &[],
        });
        
        self.queue.write_texture(
            wgpu::TexelCopyTextureInfo {
                texture: &texture,
                mip_level: 0,
                origin: wgpu::Origin3d::ZERO,
                aspect: wgpu::TextureAspect::All,
            },
            rgba_data,
            wgpu::TexelCopyBufferLayout {
                offset: 0,
                bytes_per_row: Some(4 * width),
                rows_per_image: Some(height),
            },
            texture_size,
        );
        
        let texture_view = texture.create_view(&wgpu::TextureViewDescriptor::default());
        let sampler = self.device.create_sampler(&wgpu::SamplerDescriptor {
            label: Some("Team Color Sampler"),
            address_mode_u: wgpu::AddressMode::Repeat,
            address_mode_v: wgpu::AddressMode::Repeat,
            address_mode_w: wgpu::AddressMode::Repeat,
            mag_filter: wgpu::FilterMode::Linear,
            min_filter: wgpu::FilterMode::Linear,
            mipmap_filter: wgpu::FilterMode::Nearest,
            ..Default::default()
        });
        
        // Recreate team color bind group with new texture
        self.team_color_bind_group = self.device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("Team Color Bind Group"),
            layout: &self.texture_bind_group_layout,
            entries: &[
                wgpu::BindGroupEntry {
                    binding: 0,
                    resource: wgpu::BindingResource::TextureView(&texture_view),
                },
                wgpu::BindGroupEntry {
                    binding: 1,
                    resource: wgpu::BindingResource::Sampler(&sampler),
                },
            ],
        });
        
        println!("Loaded team color texture: {}x{}", width, height);
    }
}