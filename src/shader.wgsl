// Vertex shader
struct CameraUniform {
    view_proj: mat4x4<f32>,
};

@group(0) @binding(0)
var<uniform> camera: CameraUniform;

struct VertexInput {
    @location(0) position: vec3<f32>,
    @location(1) normal: vec3<f32>,
};

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) world_pos: vec3<f32>,
    @location(1) normal: vec3<f32>,
};

@vertex
fn vs_main(
    model: VertexInput,
) -> VertexOutput {
    var out: VertexOutput;
    // Apply Y-axis inversion like Delphi glScalef(1.0, -1.0, 1.0)
    var pos = model.position;
    pos.y = -pos.y;
    out.world_pos = pos;
    out.clip_position = camera.view_proj * vec4<f32>(pos, 1.0);
    out.normal = model.normal;
    return out;
}

// Fragment shader with checkerboard pattern
@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    // Create checkerboard pattern based on world position
    let scale = 10.0;
    let checker_x = floor(in.world_pos.x * scale);
    let checker_y = floor(in.world_pos.y * scale);
    let checker_z = floor(in.world_pos.z * scale);
    let checker = (checker_x + checker_y + checker_z) % 2.0;
    
    // Two colors for checkerboard
    let color1 = vec3<f32>(0.9, 0.9, 0.9);
    let color2 = vec3<f32>(0.6, 0.6, 0.6);
    let base_color = mix(color1, color2, checker);
    
    // Simple lighting
    let light_dir = normalize(vec3<f32>(1.0, 1.0, 1.0));
    var normal = normalize(in.normal);
    normal.y = -normal.y; // Flip normal Y too
    let diffuse = max(dot(normal, light_dir), 0.0);
    let ambient = 0.3;
    let brightness = ambient + (1.0 - ambient) * diffuse;
    
    return vec4<f32>(base_color * brightness, 1.0);
}

// Line rendering shaders
struct LineVertexInput {
    @location(0) position: vec3<f32>,
    @location(1) color: vec3<f32>,
};

struct LineVertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) color: vec3<f32>,
};

@vertex
fn vs_line(
    model: LineVertexInput,
) -> LineVertexOutput {
    var out: LineVertexOutput;
    out.clip_position = camera.view_proj * vec4<f32>(model.position, 1.0);
    out.color = model.color;
    return out;
}

@fragment
fn fs_line(in: LineVertexOutput) -> @location(0) vec4<f32> {
    return vec4<f32>(in.color, 1.0);
}
