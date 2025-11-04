// Vertex shader
struct CameraUniform {
    view_proj: mat4x4<f32>,
};

struct MaterialUniform {
    team_color: vec3<f32>,
    use_team_color: f32, // 0.0 = use texture, 1.0 = replace with team color, 0.5 = blend
};

@group(0) @binding(0)
var<uniform> camera: CameraUniform;

@group(1) @binding(0)
var t_diffuse: texture_2d<f32>;
@group(1) @binding(1)
var s_diffuse: sampler;

@group(2) @binding(0)
var<uniform> material: MaterialUniform;

struct VertexInput {
    @location(0) position: vec3<f32>,
    @location(1) normal: vec3<f32>,
    @location(2) uv: vec2<f32>,
};

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) world_pos: vec3<f32>,
    @location(1) normal: vec3<f32>,
    @location(2) uv: vec2<f32>,
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
    out.uv = model.uv;
    return out;
}

// Fragment shader with texture sampling
@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {
    // Sample texture
    var tex_color = textureSample(t_diffuse, s_diffuse, in.uv);
    
    // Apply team color if needed
    if (material.use_team_color > 0.5) {
        // Standard Porter-Duff OVER compositing:
        // result = src + dst * (1 - src.alpha)
        // Where src = texture pixel, dst = team color
        
        // Texture OVER team color
        let src = tex_color.rgb;
        let src_alpha = tex_color.a;
        let dst = material.team_color;
        
        // result = src + dst * (1 - src_alpha)
        let final_rgb = src + dst * (1.0 - src_alpha);
        
        // Preserve original alpha channel
        tex_color = vec4<f32>(final_rgb, src_alpha);
    }
    
    // Simple lighting
    let light_dir = normalize(vec3<f32>(1.0, 1.0, 1.0));
    var normal = normalize(in.normal);
    normal.y = -normal.y; // Flip normal Y too
    let diffuse = max(dot(normal, light_dir), 0.0);
    let ambient = 0.3;
    let brightness = ambient + (1.0 - ambient) * diffuse;
    
    return vec4<f32>(tex_color.rgb * brightness, tex_color.a);
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
