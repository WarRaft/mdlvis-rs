// Vertex shader
struct CameraUniform {
    view_proj: mat4x4<f32>,
};

struct MaterialUniform {
    team_color: vec4<f32>, // team_color.rgb + replaceable_id (0=none, 1=team_color, 2=team_glow)
    material_type_and_wireframe: vec4<f32>, // filter_mode + wireframe_mode + layer_alpha + shading_flags
    extra_padding: vec4<f32>, // Padding for alignment
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
    let team_color_rgb = material.team_color.xyz;
    let replaceable_id = material.team_color.w; // 0=none, 1=team_color, 2=team_glow
    let filter_mode = material.material_type_and_wireframe.x;
    let wireframe_mode = material.material_type_and_wireframe.y;
    let layer_alpha = material.material_type_and_wireframe.z;
    let shading_flags = u32(material.material_type_and_wireframe.w);
    
    // Check if unshaded flag is set (0x1)
    let is_unshaded = (shading_flags & 0x1u) != 0u;
    
    // In wireframe mode, use a solid color instead of texture
    if (wireframe_mode > 0.5) {
        var wireframe_color = vec3<f32>(0.0, 1.0, 0.0); // Default green
        if (filter_mode >= 4.0) { // Additive or AddAlpha (now 4.0+)
            wireframe_color = vec3<f32>(1.0, 0.5, 0.0); // Orange for glow effects
        }
        return vec4<f32>(wireframe_color, 1.0);
    }
    
    // Sample texture (for RID=1/2 textures are already generated with team color)
    var tex_color = textureSample(t_diffuse, s_diffuse, in.uv);
    
    // Filter mode handling:
    // 0 = None - no transparency
    // 1 = Transparent - alpha testing (discard transparent pixels)
    // 2 = Blend - alpha blending
    // 3+ = Additive/etc
    
    // Alpha test for Transparent mode - War3 uses cutout, not blending!
    if (filter_mode > 0.5 && filter_mode < 1.5) { // Transparent mode
        if (tex_color.a < 0.01) { // Discard nearly transparent pixels
            discard;
        }
        // Don't modify alpha - keep original for proper rendering
    }

    
    // Apply layer_alpha to texture alpha (modulate like glColor4f)
    // This controls the transparency of this entire layer
    tex_color.a = tex_color.a * layer_alpha;
    
    // Apply lighting only to non-glow materials AND if not unshaded
    var final_color = tex_color;
    if (filter_mode < 4.0 && !is_unshaded) { // Not additive/glow (now < 4.0) AND not unshaded
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
