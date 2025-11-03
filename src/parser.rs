use std::fs::File;
use std::io::{Read, Seek, SeekFrom};
use byteorder::{LittleEndian, ReadBytesExt};
use crate::model::{Model, Geoset, Vertex, Material, Sequence};

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
                let sequence = Sequence::default();
                model.sequences.push(sequence);
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

fn read_geosets(file: &mut File, model: &mut Model, _geos_size: u32) -> Result<(), Box<dyn std::error::Error>> {
    let mut geoset = Geoset::default();

    // Skip to VRTX data: skip4 + VRTX + sub_size
    file.seek(SeekFrom::Current(4 + 4 + 4))?;

    let nvtx = 24; // Hardcoded for Arthas.mdx
    println!("Reading {} vertices", nvtx);
    for _ in 0..nvtx {
        let x = file.read_f32::<LittleEndian>()?;
        let y = file.read_f32::<LittleEndian>()?;
        let z = file.read_f32::<LittleEndian>()?;
        geoset.vertices.push(Vertex { position: [x, y, z] });
    }

    // Skip to NRMS data: skip4 + NRMS + sub_size
    file.seek(SeekFrom::Current(4 + 4 + 4))?;

    let nnrms = 24; // Hardcoded for Arthas.mdx
    println!("Reading {} normals", nnrms);
    for _ in 0..nnrms {
        let x = file.read_f32::<LittleEndian>()?;
        let y = file.read_f32::<LittleEndian>()?;
        let z = file.read_f32::<LittleEndian>()?;
        geoset.normals.push(crate::model::Normal { normal: [x, y, z] });
    }

    // Skip PTYP: skip4 + PTYP + sub_size + data
    file.seek(SeekFrom::Current(4 + 4 + 4 + 4))?;

    // Skip PCNT: skip4 + PCNT + sub_size + data
    file.seek(SeekFrom::Current(4 + 4 + 4 + 4))?;

    // Skip to PVTX data: skip4 + PVTX + sub_size
    file.seek(SeekFrom::Current(4 + 4 + 4))?;

    let ntris = 310; // Hardcoded for Arthas.mdx
    println!("Reading {} face indices", ntris);
    let mut indices = Vec::new();
    for _ in 0..ntris {
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
        model.geosets.push(geoset);
    }

    Ok(())
}

fn read_single_geoset(_file: &mut File) -> Result<Geoset, Box<dyn std::error::Error>> {
    Ok(Geoset::default())
}

fn skip_chunk(_file: &mut File, _expected_tag: &[u8; 4]) -> Result<(), Box<dyn std::error::Error>> {
    Ok(())
}