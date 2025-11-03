const TEXTURE_BASE_URL: &str = "https://github.com/WarRaft/War3.mpq/raw/refs/heads/main/lowercase";

/// Download a texture from the GitHub repository
pub async fn download_texture(path: &str) -> Result<Vec<u8>, Box<dyn std::error::Error>> {
    // Convert path to lowercase and replace backslashes with forward slashes
    let normalized_path = path.to_lowercase().replace('\\', "/");
    
    // Remove leading slash if present
    let normalized_path = normalized_path.trim_start_matches('/');
    
    let url = format!("{}/{}", TEXTURE_BASE_URL, normalized_path);
    
    println!("Downloading texture from: {}", url);
    
    // Use async HTTP client
    let response = reqwest::get(&url).await?;
    
    if !response.status().is_success() {
        return Err(format!("Failed to download texture: HTTP {}", response.status()).into());
    }
    
    let bytes = response.bytes().await?;
    Ok(bytes.to_vec())
}

/// Load and decode a BLP texture
pub fn decode_blp(data: &[u8]) -> Result<(Vec<u8>, u32, u32), Box<dyn std::error::Error>> {
    // Use blp crate to decode to RGBA
    let img = blp::core::decode::decode_to_rgba(data)?;
    
    let width = img.width();
    let height = img.height();
    
    // Convert to RGBA8
    let rgba_img = img.to_rgba8();
    let rgba_data = rgba_img.into_raw();
    
    Ok((rgba_data, width, height))
}

/// Download and decode a texture from the repository
pub async fn load_texture(path: &str) -> Result<(Vec<u8>, u32, u32), Box<dyn std::error::Error>> {
    let blp_data = download_texture(path).await?;
    decode_blp(&blp_data)
}
