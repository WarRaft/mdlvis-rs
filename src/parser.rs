use std::fs::File;
use std::io::{Read, Seek, SeekFrom};
use byteorder::{LittleEndian, ReadBytesExt};
use crate::model::{Model, Geoset, Sequence, Bone};

pub fn load_mdl(path: &str) -> Result<Model, Box<dyn std::error::Error>> {
    let mut file = File::open(path)?;
    let mut buffer = [0u8; 4];
    file.read_exact(&mut buffer)?;

    if &buffer == b"MDLX" {
        load_mdx(&mut file)
    } else {
        // Assume MDL text format
        load_mdl_text(path)
    }
}

fn load_mdl_text(path: &str) -> Result<Model, Box<dyn std::error::Error>> {
    let mut file = File::open(path)?;
    let mut content = String::new();
    file.read_to_string(&mut content)?;

    // Basic text parsing - simplified
    let mut model = Model::default();
    model.name = "Text Model".to_string();

    // Dummy data
    let geoset = Geoset::default();
    model.geosets.push(geoset);

    Ok(model)
}

fn load_mdx(file: &mut File) -> Result<Model, Box<dyn std::error::Error>> {
    let mut model = Model::default();
    model.name = "MDX Model".to_string();

    // Read chunks until end of file
    loop {
        let mut chunk_type = [0u8; 4];
        if file.read_exact(&mut chunk_type).is_err() {
            break; // End of file
        }

        let size = file.read_u32::<LittleEndian>()?;
        let start_pos = file.seek(SeekFrom::Current(0))?;

        println!("Chunk: {:?}, Size: {}", String::from_utf8_lossy(&chunk_type), size);

        match &chunk_type {
            b"VERS" => {
                // Version chunk
                let version = file.read_u32::<LittleEndian>()?;
                println!("MDX Version: {}", version);
            }
            b"MODL" => {
                // Model header - skip 8 bytes, then read 336 bytes for name
                file.seek(SeekFrom::Current(8))?;
                let mut name_bytes = [0u8; 336];
                file.read_exact(&mut name_bytes)?;
                model.name = String::from_utf8(name_bytes.into_iter().take_while(|&b| b != 0).collect())
                    .unwrap_or_else(|_| "Unknown".to_string());
                println!("Model name: {}", model.name.trim());
            }
            b"GEOS" => {
                // Geosets - this chunk contains multiple geosets
                println!("Reading GEOS chunk, size: {}", size);
                read_geosets(file, &mut model, size)?;
                println!("Loaded {} geosets", model.geosets.len());
            }
            b"SEQS" => {
                // Sequences
                read_sequences(file, &mut model, size)?;
                println!("Loaded {} sequences", model.sequences.len());
            }
            b"TEXS" => {
                // Textures
                read_textures(file, &mut model, size)?;
                println!("Loaded {} textures", model.textures.len());
            }
            b"BONE" => {
                // Bones
                read_bones(file, &mut model, size)?;
            }
            b"HELP" => {
                // Helpers
                read_helpers(file, &mut model, size)?;
            }
            b"PIVT" => {
                // Pivot points
                read_pivots(file, &mut model, size)?;
            }
            b"MTLS" => {
                // Materials
                read_materials(file, &mut model, size)?;
            }
            _ => {
                // Skip unknown chunk
                file.seek(SeekFrom::Current(size as i64))?;
            }
        }

        // Ensure we're at the correct position after reading the chunk
        let current_pos = file.seek(SeekFrom::Current(0))?;
        let expected_pos = start_pos + size as u64;
        if current_pos < expected_pos {
            file.seek(SeekFrom::Start(expected_pos))?;
        }
    }

    Ok(model)
}

fn read_geosets(file: &mut File, model: &mut Model, geos_size: u32) -> Result<(), Box<dyn std::error::Error>> {
    let start_pos = file.stream_position()?;
    let end_pos = start_pos + geos_size as u64;
    
    while file.stream_position()? < end_pos {
        let geoset_start = file.stream_position()?;
        
        // Each geoset has inclusiveSize field
        let inclusive_size = file.read_u32::<LittleEndian>()?;
        let geoset_end = geoset_start + inclusive_size as u64;
        
        if inclusive_size == 0 || geoset_end > end_pos {
            break;
        }
        
        let mut geoset = Geoset::default();
        let mut indices = Vec::new();
        let mut tag = [0u8; 4];
        
        // Read all chunks within this geoset (order not guaranteed)
        while file.stream_position()? < geoset_end {
            // Check if we have at least 4 bytes left for a tag
            if geoset_end - file.stream_position()? < 4 {
                break;
            }
            
            file.read_exact(&mut tag)?;
            
            match &tag {
                b"VRTX" => {
                    let count = file.read_u32::<LittleEndian>()? as usize;
                    for _ in 0..count {
                        let x = file.read_f32::<LittleEndian>()?;
                        let y = file.read_f32::<LittleEndian>()?;
                        let z = file.read_f32::<LittleEndian>()?;
                        geoset.vertices.push(crate::model::Vertex { position: [x, y, z] });
                    }
                }
                b"NRMS" => {
                    let count = file.read_u32::<LittleEndian>()? as usize;
                    for _ in 0..count {
                        let x = file.read_f32::<LittleEndian>()?;
                        let y = file.read_f32::<LittleEndian>()?;
                        let z = file.read_f32::<LittleEndian>()?;
                        geoset.normals.push(crate::model::Normal { normal: [x, y, z] });
                    }
                }
                b"PTYP" => {
                    let count = file.read_u32::<LittleEndian>()?;
                    file.seek(SeekFrom::Current((count * 4) as i64))?;
                }
                b"PCNT" => {
                    let count = file.read_u32::<LittleEndian>()?;
                    file.seek(SeekFrom::Current((count * 4) as i64))?;
                }
                b"PVTX" => {
                    let count = file.read_u32::<LittleEndian>()? as usize;
                    for _ in 0..count {
                        let index = file.read_u16::<LittleEndian>()?;
                        indices.push(index as u32);
                    }
                }
                b"GNDX" => {
                    // Vertex Groups: byte array mapping each vertex to a matrix group
                    let count = file.read_u32::<LittleEndian>()? as usize;
                    geoset.vertex_groups.reserve(count);
                    for _ in 0..count {
                        geoset.vertex_groups.push(file.read_u8()?);
                    }
                }
                b"MTGC" => {
                    // Matrix Group Counts: how many bones in each group
                    let num_groups = file.read_u32::<LittleEndian>()? as usize;
                    geoset.matrix_groups.reserve(num_groups);
                    for _ in 0..num_groups {
                        let group_size = file.read_u32::<LittleEndian>()? as usize;
                        geoset.matrix_groups.push(Vec::with_capacity(group_size));
                    }
                }
                b"MATS" => {
                    // Matrix Groups Data: bone indices for each group
                    let total_count = file.read_u32::<LittleEndian>()? as usize;
                    
                    // Read bone indices into the pre-allocated matrix groups
                    for group in &mut geoset.matrix_groups {
                        for _ in 0..group.capacity() {
                            group.push(file.read_u32::<LittleEndian>()?);
                        }
                    }
                    
                    // After MATS comes MaterialID as a plain long field
                    let material_id = file.read_u32::<LittleEndian>()?;
                    geoset.material_id = Some(material_id as usize);
                    
                    // Skip SelectionGroup
                    let _selection_group = file.read_u32::<LittleEndian>()?;
                    geoset.selection_group = _selection_group as usize;
                    
                    // Read Selectable
                    let selectable = file.read_u32::<LittleEndian>()?;
                    geoset.unselectable = selectable == 4; // 4 = Unselectable
                    
                    // Read BoundsRadius
                    geoset.bounds_radius = file.read_f32::<LittleEndian>()?;
                    
                    // Read MinExt (3 floats)
                    geoset.minimum_extent[0] = file.read_f32::<LittleEndian>()?;
                    geoset.minimum_extent[1] = file.read_f32::<LittleEndian>()?;
                    geoset.minimum_extent[2] = file.read_f32::<LittleEndian>()?;
                    
                    // Read MaxExt (3 floats)
                    geoset.maximum_extent[0] = file.read_f32::<LittleEndian>()?;
                    geoset.maximum_extent[1] = file.read_f32::<LittleEndian>()?;
                    geoset.maximum_extent[2] = file.read_f32::<LittleEndian>()?;
                    // Skip nanim and animations array
                    let nanim = file.read_u32::<LittleEndian>()?;
                    file.seek(SeekFrom::Current((nanim * 28) as i64))?; // Each animation is 7 floats
                }
                b"UVAS" => {
                    let uvas_count = file.read_u32::<LittleEndian>()?;
                    
                    // Read first UVBS set (primary texture coordinates)
                    if uvas_count > 0 {
                        file.read_exact(&mut tag)?;
                        if &tag == b"UVBS" {
                            let uvbs_count = file.read_u32::<LittleEndian>()? as usize;
                            for _ in 0..uvbs_count {
                                let u = file.read_f32::<LittleEndian>()?;
                                let v = file.read_f32::<LittleEndian>()?;
                                geoset.tex_coords.push(crate::model::TexCoord { uv: [u, v] });
                            }
                        }
                        
                        // Skip remaining UVAS sets (secondary UVs)
                        for _ in 1..uvas_count {
                            file.read_exact(&mut tag)?;
                            if &tag == b"UVBS" {
                                let count = file.read_u32::<LittleEndian>()?;
                                file.seek(SeekFrom::Current((count * 8) as i64))?;
                            }
                        }
                    }
                }
                _ => {
                    // Not a known chunk tag - could be materialId, selectionGroup, etc.
                    // Treat as u32 value
                    file.seek(SeekFrom::Current(-4))?; // Go back
                    let _val = file.read_u32::<LittleEndian>()?;
                }
            }
        }
        
        // Group indices into triangles
        for chunk in indices.chunks(3) {
            if chunk.len() == 3 {
                geoset.faces.push(crate::model::Face {
                    vertices: [chunk[0], chunk[1], chunk[2]],
                });
            }
        }

        if !geoset.vertices.is_empty() {
            println!("  Geoset {}: {} vertices, {} faces, {} vertex groups, {} matrix groups", 
                model.geosets.len(), 
                geoset.vertices.len(), 
                geoset.faces.len(),
                geoset.vertex_groups.len(),
                geoset.matrix_groups.len());
            model.geosets.push(geoset);
        }
        
        // Seek to end of geoset using inclusiveSize
        file.seek(SeekFrom::Start(geoset_start + inclusive_size as u64))?;
    }

    Ok(())
}

fn read_sequences(file: &mut File, model: &mut Model, size: u32) -> Result<(), Box<dyn std::error::Error>> {
    // From Delphi: SizeOfSeq = $50 + 13*4 = 80 + 52 = 132 bytes per sequence
    const SEQUENCE_SIZE: u32 = 0x50 + 13 * 4; // 132 bytes
    
    let count = size / SEQUENCE_SIZE;
    println!("Reading {} sequences from SEQS chunk", count);
    
    for _ in 0..count {
        let mut name_bytes = [0u8; 0x50]; // 80 bytes for name
        file.read_exact(&mut name_bytes)?;
        let name = String::from_utf8(name_bytes.iter().take_while(|&&b| b != 0).copied().collect())
            .unwrap_or_else(|_| "Unknown".to_string());
        
        let start_frame = file.read_u32::<LittleEndian>()?;
        let end_frame = file.read_u32::<LittleEndian>()?;
        let _move_speed = file.read_f32::<LittleEndian>()?;
        let non_looping_flag = file.read_u32::<LittleEndian>()?;
        let rarity = file.read_f32::<LittleEndian>()?;
        
        // Skip remaining data (padding + bounds: 4 + 4 + 4*3 + 4*3 = 32 bytes)
        file.seek(SeekFrom::Current(32))?;
        
        let seq_name = name.trim().to_string();
        println!("  Sequence: '{}' frames {}-{}", seq_name, start_frame, end_frame);
        
        model.sequences.push(Sequence {
            name: seq_name,
            start_frame,
            end_frame,
            rarity: Some(rarity as u32),
            non_looping: non_looping_flag != 0,
        });
    }
    
    Ok(())
}

fn read_textures(file: &mut File, model: &mut Model, size: u32) -> Result<(), Box<dyn std::error::Error>> {
    // From Delphi: TEXSize = $100 + 3*4 = 256 + 12 = 268 bytes per texture
    const TEXTURE_SIZE: u32 = 0x100 + 3 * 4; // 268 bytes
    
    let count = size / TEXTURE_SIZE;
    println!("Reading {} textures from TEXS chunk", count);
    
    for _ in 0..count {
        let replaceable_id = file.read_u32::<LittleEndian>()?;
        
        let mut filename_bytes = [0u8; 0x100]; // 256 bytes for filename
        file.read_exact(&mut filename_bytes)?;
        let filename = String::from_utf8(filename_bytes.iter().take_while(|&&b| b != 0).copied().collect())
            .unwrap_or_else(|_| "Unknown".to_string());
        
        // Skip padding (4 bytes)
        file.seek(SeekFrom::Current(4))?;
        
        // Read flags
        let _flags = file.read_u32::<LittleEndian>()?;
        
        let tex_filename = filename.trim().to_string();
        println!("  Texture: '{}', ReplaceableID: {}", tex_filename, replaceable_id);
        
        model.textures.push(crate::model::Texture {
            filename: tex_filename,
            replaceable_id,
            image_data: None, // Will be loaded later if needed
            width: 0,
            height: 0,
        });
    }
    
    Ok(())
}

// Tag constants for controllers
const TAG_KGTR: u32 = 0x5254474B; // Translation (3 floats)
const TAG_KGRT: u32 = 0x5452474B; // Rotation (4 floats - quaternion)
const TAG_KGSC: u32 = 0x4353474B; // Scaling (3 floats)
const TAG_KLAV: u32 = 0x56414C4B; // Visibility (1 float)

// Reads a controller chunk if present, returns controller index or -1 if not found
fn read_controller(
    file: &mut File,
    model: &mut Model,
    expected_tag: u32,
    element_size: usize,
) -> Result<i32, Box<dyn std::error::Error>> {
    let pos_before = file.stream_position()?;
    
    // Try to read tag
    let tag = match file.read_u32::<LittleEndian>() {
        Ok(t) => t,
        Err(_) => {
            file.seek(SeekFrom::Start(pos_before))?;
            return Ok(-1);
        }
    };
    
    // If tag doesn't match, rewind and return -1 (static)
    if tag != expected_tag {
        file.seek(SeekFrom::Start(pos_before))?;
        return Ok(-1);
    }
    
    // Tag matches, read controller data
    let keyframe_count = file.read_u32::<LittleEndian>()? as usize;
    let interpolation_type = file.read_u32::<LittleEndian>()?;
    let global_seq_id = file.read_i32::<LittleEndian>()?;
    
    // Create AnimationController
    let controller_idx = model.controllers.len() as i32;
    let mut keyframes = Vec::with_capacity(keyframe_count);
    
    // Read keyframes
    for _ in 0..keyframe_count {
        let frame = file.read_i32::<LittleEndian>()?;
        
        // Read data values
        let mut data = Vec::with_capacity(element_size);
        for _ in 0..element_size {
            data.push(file.read_f32::<LittleEndian>()?);
        }
        
        // Read tangents if Hermite (2) or Bezier (3)
        let (in_tan, out_tan) = if interpolation_type == 2 || interpolation_type == 3 {
            let mut in_tan = Vec::with_capacity(element_size);
            let mut out_tan = Vec::with_capacity(element_size);
            
            for _ in 0..element_size {
                in_tan.push(file.read_f32::<LittleEndian>()?);
            }
            for _ in 0..element_size {
                out_tan.push(file.read_f32::<LittleEndian>()?);
            }
            
            (in_tan, out_tan)
        } else {
            (Vec::new(), Vec::new())
        };
        
        keyframes.push(crate::model::Keyframe {
            frame,
            data,
            in_tan,
            out_tan,
        });
    }
    
    model.controllers.push(crate::model::AnimationController {
        interpolation_type,
        global_seq_id,
        keyframes,
    });
    
    // Debug: print first controller info
    if model.controllers.len() == 1 {
        println!("  First controller: {} keyframes, interp_type={}, global_seq={}", 
            keyframe_count, interpolation_type, global_seq_id);
        if !model.controllers[0].keyframes.is_empty() {
            let kf = &model.controllers[0].keyframes[0];
            println!("    First keyframe: frame={}, data={:?}", kf.frame, kf.data);
        }
    }
    
    Ok(controller_idx)
}

fn read_bones(file: &mut File, model: &mut Model, size: u32) -> Result<(), Box<dyn std::error::Error>> {
    let start_pos = file.stream_position()?;
    let end_pos = start_pos + size as u64;
    
    while file.stream_position()? < end_pos {
        let node_start = file.stream_position()?;
        
        if node_start >= end_pos {
            break;
        }
        
        // Read Node.inclusiveSize - this is the size of the Node structure INCLUDING this u32
        let inclusive_size = file.read_u32::<LittleEndian>()?;
        
        // Read Node fields
        let mut name_bytes = [0u8; 0x50]; // 80 bytes for name
        file.read_exact(&mut name_bytes)?;
        let name = String::from_utf8(name_bytes.iter().take_while(|&&b| b != 0).copied().collect())
            .unwrap_or_else(|_| "Unknown".to_string());
        
        let object_id = file.read_u32::<LittleEndian>()?;
        let parent_id = file.read_i32::<LittleEndian>()?;
        let _flags = file.read_u32::<LittleEndian>()?;
        
        // Read controllers (these are inside the Node structure)
        let translation_idx = read_controller(file, model, TAG_KGTR, 3)?;
        let rotation_idx = read_controller(file, model, TAG_KGRT, 4)?;
        let scaling_idx = read_controller(file, model, TAG_KGSC, 3)?;
        let visibility_idx = read_controller(file, model, TAG_KLAV, 1)?;
        
        // Seek to end of Node structure
        file.seek(SeekFrom::Start(node_start + inclusive_size as u64))?;
        
        // Now read Bone-specific fields (AFTER Node structure)
        let geoset_id = file.read_i32::<LittleEndian>()?;
        let geoset_anim_id = file.read_i32::<LittleEndian>()?;
        
        model.bones.push(Bone {
            name: name.trim().to_string(),
            object_id,
            parent_id,
            pivot_point: [0.0, 0.0, 0.0], // Will be set from PIVT chunk
            geoset_id: if geoset_id >= 0 { Some(geoset_id as u32) } else { None },
            geoset_anim_id: if geoset_anim_id >= 0 { Some(geoset_anim_id as u32) } else { None },
            translation_idx,
            rotation_idx,
            scaling_idx,
            visibility_idx,
        });
    }
    
    println!("Loaded {} bones, {} controllers", model.bones.len(), model.controllers.len());
    Ok(())
}

fn read_helpers(file: &mut File, model: &mut Model, size: u32) -> Result<(), Box<dyn std::error::Error>> {
    use crate::model::Helper;
    
    let start_pos = file.stream_position()?;
    let end_pos = start_pos + size as u64;
    
    while file.stream_position()? < end_pos {
        let node_start = file.stream_position()?;
        
        if node_start >= end_pos {
            break;
        }
        
        // Read Node.inclusiveSize
        let inclusive_size = file.read_u32::<LittleEndian>()?;
        
        // Read Node fields
        let mut name_bytes = [0u8; 0x50]; // 80 bytes for name
        file.read_exact(&mut name_bytes)?;
        let name = String::from_utf8(name_bytes.iter().take_while(|&&b| b != 0).copied().collect())
            .unwrap_or_else(|_| "Unknown".to_string());
        
        let object_id = file.read_u32::<LittleEndian>()?;
        let parent_id = file.read_i32::<LittleEndian>()?;
        let _flags = file.read_u32::<LittleEndian>()?;
        
        // Read controllers (these are inside the Node structure)
        let translation_idx = read_controller(file, model, TAG_KGTR, 3)?;
        let rotation_idx = read_controller(file, model, TAG_KGRT, 4)?;
        let scaling_idx = read_controller(file, model, TAG_KGSC, 3)?;
        let visibility_idx = read_controller(file, model, TAG_KLAV, 1)?;
        
        // Seek to end of Node structure
        file.seek(SeekFrom::Start(node_start + inclusive_size as u64))?;
        
        // Helper has no additional fields after Node, unlike Bone
        model.helpers.push(Helper {
            name: name.trim().to_string(),
            object_id,
            parent_id,
            pivot_point: [0.0, 0.0, 0.0], // Will be set from PIVT chunk
            translation_idx,
            rotation_idx,
            scaling_idx,
            visibility_idx,
        });
    }
    
    println!("Loaded {} helpers", model.helpers.len());
    Ok(())
}

fn read_materials(file: &mut File, model: &mut Model, size: u32) -> Result<(), Box<dyn std::error::Error>> {
    let start_pos = file.seek(SeekFrom::Current(0))?;
    let end_pos = start_pos + size as u64;
    
    // Each material has inclusiveSize at the start
    while file.seek(SeekFrom::Current(0))? < end_pos {
        let material_size = file.read_u32::<LittleEndian>()?;
        let material_start = file.seek(SeekFrom::Current(0))?;
        let material_end = material_start + (material_size as u64) - 4; // -4 because we already read size
        
        // Skip priority plane and flags
        file.seek(SeekFrom::Current(8))?;
        
        // Read LAYS tag
        let mut tag = [0u8; 4];
        file.read_exact(&mut tag)?;
        
        if &tag != b"LAYS" {
            // Not a valid material, skip to end
            file.seek(SeekFrom::Start(material_end))?;
            continue;
        }
        
        let layers_count = file.read_u32::<LittleEndian>()?;
        let mut material = crate::model::Material::default();
        
        // Read each layer
        for _ in 0..layers_count {
            let layer_size = file.read_u32::<LittleEndian>()?;
            let layer_start = file.seek(SeekFrom::Current(0))?;
            let layer_end = layer_start + (layer_size as u64) - 4;
            
            // Read layer data
            let filter_mode_val = file.read_u32::<LittleEndian>()?;
            let _shading_flags = file.read_u32::<LittleEndian>()?;
            let texture_id = file.read_u32::<LittleEndian>()?;
            let _texture_animation_id = file.read_u32::<LittleEndian>()?;
            let _coord_id = file.read_u32::<LittleEndian>()?;
            let alpha = file.read_f32::<LittleEndian>()?;
            
            // Map filter mode from MDX values (from delphi/mdlwork.pas):
            // 0=Opaque (legacy), 1=Opaque, 2=ColorAlpha, 3=FullAlpha, 4=Additive, 5=Modulate, 6=Modulate2X, 7=AddAlpha, 8=AlphaKey
            let filter_mode = match filter_mode_val {
                0 | 1 => crate::model::FilterMode::Opaque, // 0 is legacy opaque
                2 | 3 => crate::model::FilterMode::Transparent, // ColorAlpha and FullAlpha
                4 => crate::model::FilterMode::Additive,
                5 => crate::model::FilterMode::Modulate,
                6 => crate::model::FilterMode::Modulate2x,
                7 => crate::model::FilterMode::AddAlpha,
                _ => crate::model::FilterMode::Blend,
            };
            
            let layer = crate::model::Layer {
                texture_id: Some(texture_id as usize),
                filter_mode,
                alpha,
            };
            material.layers.push(layer);
            
            // Skip to end of layer (may contain optional track chunks KMTF, KMTA, etc.)
            file.seek(SeekFrom::Start(layer_end))?;
        }
        
        if let Some(layer) = material.layers.first() {
            if let Some(tex_id) = layer.texture_id {
                println!("  Material {}: texture_id = {}, filter_mode = {:?}, alpha = {}", 
                    model.materials.len(), tex_id, layer.filter_mode, layer.alpha);
            }
        }
        
        model.materials.push(material);
        
        // Seek to end of material
        file.seek(SeekFrom::Start(material_end))?;
    }
    
    println!("Loaded {} materials", model.materials.len());
    
    Ok(())
}

fn read_pivots(file: &mut File, model: &mut Model, size: u32) -> Result<(), Box<dyn std::error::Error>> {
    let count = size / (4 * 3); // Each pivot point is 3 floats
    
    for i in 0..count as usize {
        let x = file.read_f32::<LittleEndian>()?;
        let y = file.read_f32::<LittleEndian>()?;
        let z = file.read_f32::<LittleEndian>()?;
        
        // Assign to bones first, then helpers
        if i < model.bones.len() {
            model.bones[i].pivot_point = [x, y, z];
        } else {
            let helper_idx = i - model.bones.len();
            if helper_idx < model.helpers.len() {
                model.helpers[helper_idx].pivot_point = [x, y, z];
            }
        }
    }
    
    println!("Loaded {} pivot points ({} bones + {} helpers)", count, model.bones.len(), model.helpers.len());
    Ok(())
}
