#[derive(Debug, Clone)]
pub struct GeosetRenderInfo {
    pub index_start: u32,
    pub index_count: u32,
    pub material_id: Option<usize>,
    pub vertices: Vec<[f32; 3]>,  // Store vertex positions for depth sorting
    pub faces: Vec<Vec<u32>>,     // Store face indices for depth sorting
}
