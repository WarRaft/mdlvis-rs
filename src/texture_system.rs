/// Texture management system for handling different texture types and loading

pub struct TextureManager {
    device: std::sync::Arc<wgpu::Device>,
    queue: std::sync::Arc<wgpu::Queue>,
}

impl TextureManager {
    pub fn new(device: std::sync::Arc<wgpu::Device>, queue: std::sync::Arc<wgpu::Queue>) -> Self {
        Self { device, queue }
    }

    /// Create team glow texture (32x32 with alpha map from WC3)
    pub fn create_team_glow_texture(&self) -> wgpu::Texture {
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
        
        // Create RGBA texture: white color (255,255,255) with varying alpha
        let mut rgba_data = Vec::with_capacity(32 * 32 * 4);
        for alpha_byte in &TEAM_GLOW_ALPHA {
            let alpha = (*alpha_byte as f32 / 127.0 * 255.0) as u8; // Scale 0-127 to 0-255
            rgba_data.push(255); // R - white
            rgba_data.push(255); // G - white  
            rgba_data.push(255); // B - white
            rgba_data.push(alpha); // A - from map
        }
        
        self.create_texture_from_rgba(&rgba_data, 32, 32, Some("Team Glow Texture"))
    }

    /// Create texture from RGBA data
    pub fn create_texture_from_rgba(&self, rgba_data: &[u8], width: u32, height: u32, label: Option<&str>) -> wgpu::Texture {
        let texture_size = wgpu::Extent3d {
            width,
            height,
            depth_or_array_layers: 1,
        };
        
        let texture = self.device.create_texture(&wgpu::TextureDescriptor {
            label,
            size: texture_size,
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: wgpu::TextureFormat::Rgba8Unorm,
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
        
        texture
    }

    /// Create a solid white 1x1 texture for fallbacks
    pub fn create_white_texture(&self) -> wgpu::Texture {
        let rgba_data = [255u8, 255, 255, 255]; // White RGBA
        self.create_texture_from_rgba(&rgba_data, 1, 1, Some("White Fallback Texture"))
    }
}