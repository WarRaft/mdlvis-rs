use std::fs::File;
use std::io::{Read, Seek, SeekFrom};
use byteorder::{LittleEndian, ReadBytesExt};
use crate::model::{Model, Geoset, Material, Sequence, Bone};

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
                let material = Material::default();
                model.materials.push(material);
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
        
        if inclusive_size == 0 || geoset_start + inclusive_size as u64 > end_pos {
            break;
        }
        
        let mut geoset = Geoset::default();

        // Read VRTX chunk
        let mut tag = [0u8; 4];
        file.read_exact(&mut tag)?;
        if &tag != b"VRTX" {
            println!("Warning: Expected VRTX, got {:?}, skipping geoset", String::from_utf8_lossy(&tag));
            file.seek(SeekFrom::Start(geoset_start + inclusive_size as u64))?;
            continue;
        }
        let nverts = file.read_u32::<LittleEndian>()? as usize;
        for _ in 0..nverts {
            let x = file.read_f32::<LittleEndian>()?;
            let y = file.read_f32::<LittleEndian>()?;
            let z = file.read_f32::<LittleEndian>()?;
            geoset.vertices.push(crate::model::Vertex { position: [x, y, z] });
        }

        // Read NRMS chunk
        file.read_exact(&mut tag)?;
        if &tag != b"NRMS" {
            println!("Warning: Expected NRMS, got {:?}, skipping rest of geoset", String::from_utf8_lossy(&tag));
            file.seek(SeekFrom::Start(geoset_start + inclusive_size as u64))?;
            continue;
        }
        let nnorms = file.read_u32::<LittleEndian>()? as usize;
        for _ in 0..nnorms {
            let x = file.read_f32::<LittleEndian>()?;
            let y = file.read_f32::<LittleEndian>()?;
            let z = file.read_f32::<LittleEndian>()?;
            geoset.normals.push(crate::model::Normal { normal: [x, y, z] });
        }

        // Read and skip PTYP
        file.read_exact(&mut tag)?;
        if &tag != b"PTYP" {
            println!("Warning: Expected PTYP, got {:?}", String::from_utf8_lossy(&tag));
            file.seek(SeekFrom::Start(geoset_start + inclusive_size as u64))?;
            continue;
        }
        let ptyp_count = file.read_u32::<LittleEndian>()?;
        file.seek(SeekFrom::Current((ptyp_count * 4) as i64))?;

        // Read and skip PCNT  
        file.read_exact(&mut tag)?;
        if &tag != b"PCNT" {
            println!("Warning: Expected PCNT, got {:?}", String::from_utf8_lossy(&tag));
            file.seek(SeekFrom::Start(geoset_start + inclusive_size as u64))?;
            continue;
        }
        let pcnt_count = file.read_u32::<LittleEndian>()?;
        file.seek(SeekFrom::Current((pcnt_count * 4) as i64))?;

        // Read PVTX (vertex indices)
        file.read_exact(&mut tag)?;
        if &tag != b"PVTX" {
            println!("Warning: Expected PVTX, got {:?}", String::from_utf8_lossy(&tag));
            file.seek(SeekFrom::Start(geoset_start + inclusive_size as u64))?;
            continue;
        }
        
        let num_indices = file.read_u32::<LittleEndian>()? as usize;
        let mut indices = Vec::new();
        for _ in 0..num_indices {
            let index = file.read_u16::<LittleEndian>()?;
            indices.push(index as u32);
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
            println!("  Geoset {}: {} vertices, {} faces", 
                model.geosets.len(), geoset.vertices.len(), geoset.faces.len());
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
        
        // Skip to end of Node (which includes all tracks/controllers)
        // node_start + inclusiveSize is where the Node ends
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
        });
    }
    
    println!("Loaded {} bones", model.bones.len());
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
        
        // Skip to end of Node (which includes all tracks/controllers)
        file.seek(SeekFrom::Start(node_start + inclusive_size as u64))?;
        
        // Helper has no additional fields after Node, unlike Bone
        model.helpers.push(Helper {
            name: name.trim().to_string(),
            object_id,
            parent_id,
            pivot_point: [0.0, 0.0, 0.0], // Will be set from PIVT chunk
        });
    }
    
    println!("Loaded {} helpers", model.helpers.len());
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
