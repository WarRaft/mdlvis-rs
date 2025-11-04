// Vertex shader
struct CameraUniform {
    view_proj: mat4x4<f32>,
};

struct MaterialUniform {
    team_color_and_flags: vec4<f32>, // team_color.rgb + use_team_color
    material_type_and_wireframe: vec4<f32>, // filter_mode + wireframe_mode + is_team_glow + padding
    extra_padding: vec4<f32>, // Additional padding for alignment
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
    // Extract values from uniform structure
    let team_color = material.team_color_and_flags.xyz;
    let use_team_color = material.team_color_and_flags.w;
    let filter_mode = material.material_type_and_wireframe.x;
    let wireframe_mode = material.material_type_and_wireframe.y;
    let is_team_glow = material.material_type_and_wireframe.z;
    
    // In wireframe mode, use a solid color instead of texture
    if (wireframe_mode > 0.5) {
        // Use bright colors for wireframe to make lines visible
        // Green for normal materials, yellow for team color materials, red for glow/additive
        var wireframe_color = vec3<f32>(0.0, 1.0, 0.0); // Default green
        if (use_team_color > 0.5) {
            wireframe_color = vec3<f32>(1.0, 1.0, 0.0); // Yellow for team color
        } else if (filter_mode >= 3.0) { // Additive or AddAlpha
            wireframe_color = vec3<f32>(1.0, 0.5, 0.0); // Orange for glow effects
        }
        return vec4<f32>(wireframe_color, 1.0);
    }
    
    // Normal rendering - sample texture
    var tex_color = textureSample(t_diffuse, s_diffuse, in.uv);
    
    // Apply team color blending based on material type
    if (use_team_color > 0.5) {
        let is_team_glow = material.material_type_and_wireframe.z > 0.5;
        
        if (is_team_glow) {
            // Team Glow (ReplaceableID=2): white texture with alpha pattern
            // Multiply team color by alpha to get glow intensity
            let glow_rgb = team_color * tex_color.a;
            tex_color = vec4<f32>(glow_rgb.x, glow_rgb.y, glow_rgb.z, tex_color.a);
        } else {
            // Regular Team Color (ReplaceableID=1): blend team color with texture using alpha
            // Where alpha=0: show team_color, where alpha=1: show texture
            let blended = mix(team_color, tex_color.rgb, tex_color.a);
            tex_color = vec4<f32>(blended.x, blended.y, blended.z, tex_color.a);
        }
    }
    
    // Apply lighting only to non-glow materials
    var final_color = tex_color;
    if (filter_mode < 3.0) { // Not additive/glow
        let light_dir = normalize(vec3<f32>(1.0, 1.0, 1.0));
        var normal = normalize(in.normal);
        normal.y = -normal.y; // Flip normal Y too
        let diffuse = max(dot(normal, light_dir), 0.0);
        let ambient = 0.3;
        let brightness = ambient + (1.0 - ambient) * diffuse;
        final_color = vec4<f32>(tex_color.rgb * brightness, tex_color.a);
    }
    
    return final_color;
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
