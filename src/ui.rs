use crate::model::Model;
use crate::settings::Settings;

pub struct Ui {
    show_geosets: Vec<bool>,
    selected_sequence: usize,
    animation_time: f32,
    is_playing: bool,
    pub settings: Settings,
}

impl Ui {
    pub fn new() -> Self {
        Self {
            show_geosets: Vec::new(),
            selected_sequence: 0,
            animation_time: 0.0,
            is_playing: false,
            settings: Settings::load(),
        }
    }

    pub fn show(&mut self, ctx: &egui::Context, model: &Option<Model>, axis_labels: (Option<[f32; 2]>, Option<[f32; 2]>, Option<[f32; 2]>), team_color: [f32; 3]) -> (bool, Option<[f32; 3]>) {
        let mut reset_camera = false;
        let mut new_team_color: Option<[f32; 3]> = None;
        
        // Draw axis labels as overlay using projected positions
        let (x_pos, y_pos, z_pos) = axis_labels;
        
        egui::Area::new("axis_labels".into())
            .fixed_pos(egui::pos2(0.0, 0.0))
            .interactable(false)
            .show(ctx, |ui| {
                let font_id = egui::FontId::proportional(32.0); // Bigger font
                
                if let Some([x, y]) = x_pos {
                    let pos = egui::pos2(x, y);
                    // Draw outline
                    for dx in [-1.0, 0.0, 1.0] {
                        for dy in [-1.0, 0.0, 1.0] {
                            if dx != 0.0 || dy != 0.0 {
                                ui.painter().text(
                                    egui::pos2(x + dx, y + dy),
                                    egui::Align2::CENTER_CENTER,
                                    "X",
                                    font_id.clone(),
                                    egui::Color32::from_rgb(0, 0, 0),
                                );
                            }
                        }
                    }
                    // Draw main text
                    ui.painter().text(
                        pos,
                        egui::Align2::CENTER_CENTER,
                        "X",
                        font_id.clone(),
                        egui::Color32::from_rgb(255, 50, 50),
                    );
                }
                
                if let Some([x, y]) = y_pos {
                    let pos = egui::pos2(x, y);
                    // Draw outline
                    for dx in [-1.0, 0.0, 1.0] {
                        for dy in [-1.0, 0.0, 1.0] {
                            if dx != 0.0 || dy != 0.0 {
                                ui.painter().text(
                                    egui::pos2(x + dx, y + dy),
                                    egui::Align2::CENTER_CENTER,
                                    "Y",
                                    font_id.clone(),
                                    egui::Color32::from_rgb(0, 0, 0),
                                );
                            }
                        }
                    }
                    // Draw main text
                    ui.painter().text(
                        pos,
                        egui::Align2::CENTER_CENTER,
                        "Y",
                        font_id.clone(),
                        egui::Color32::from_rgb(50, 255, 50),
                    );
                }
                
                if let Some([x, y]) = z_pos {
                    let pos = egui::pos2(x, y);
                    // Draw outline
                    for dx in [-1.0, 0.0, 1.0] {
                        for dy in [-1.0, 0.0, 1.0] {
                            if dx != 0.0 || dy != 0.0 {
                                ui.painter().text(
                                    egui::pos2(x + dx, y + dy),
                                    egui::Align2::CENTER_CENTER,
                                    "Z",
                                    font_id.clone(),
                                    egui::Color32::from_rgb(0, 0, 0),
                                );
                            }
                        }
                    }
                    // Draw main text
                    ui.painter().text(
                        pos,
                        egui::Align2::CENTER_CENTER,
                        "Z",
                        font_id,
                        egui::Color32::from_rgb(100, 150, 255),
                    );
                }
            });

        egui::SidePanel::left("left_panel")
            .default_width(250.0)
            .show(ctx, |ui| {
                ui.heading("MDLVis-RS");

                // Render settings panel
                ui.collapsing("Render Settings", |ui| {
                    if ui.checkbox(&mut self.settings.show_skeleton, "Show Skeleton").changed() {
                        self.settings.save();
                    }
                    if ui.checkbox(&mut self.settings.wireframe_mode, "Wireframe Mode").changed() {
                        self.settings.save();
                    }
                    if ui.checkbox(&mut self.settings.show_grid, "Show Grid").changed() {
                        self.settings.save();
                    }
                    
                    ui.separator();
                    ui.label("Far Plane (View Distance):");
                    if ui.add(egui::Slider::new(&mut self.settings.far_plane, 100.0..=5000.0)
                        .suffix(" units")
                        .logarithmic(true)).changed() {
                        self.settings.save();
                    }
                    
                    ui.separator();
                    
                    if ui.button("Reset Camera").clicked() {
                        reset_camera = true;
                    }
                });
                
                // Team Color picker
                ui.collapsing("Team Color", |ui| {
                    let mut color = team_color;
                    if ui.color_edit_button_rgb(&mut color).changed() {
                        new_team_color = Some(color);
                    }
                });

                if let Some(model) = model {
                    self.show_model_info(ui, model);
                    self.show_geosets_panel(ui, model);
                    self.show_textures_panel(ui, model);
                    self.show_animation_panel(ui, model);
                } else {
                    ui.label("No model loaded");
                    if ui.button("Load Model").clicked() {
                        // TODO: Implement file dialog
                    }
                }
            });
        
        (reset_camera, new_team_color)
    }
    fn show_model_info(&self, ui: &mut egui::Ui, model: &Model) {
        ui.collapsing("Model Info", |ui| {
            ui.label(format!("Name: {}", model.name));
            ui.separator();
            
            ui.label(format!("Geosets: {}", model.geosets.len()));
            let total_verts: usize = model.geosets.iter().map(|g| g.vertices.len()).sum();
            let total_faces: usize = model.geosets.iter().map(|g| g.faces.len()).sum();
            let total_uvs: usize = model.geosets.iter().map(|g| g.tex_coords.len()).sum();
            ui.label(format!("  Total vertices: {}", total_verts));
            ui.label(format!("  Total faces: {}", total_faces));
            ui.label(format!("  Total UVs: {}", total_uvs));
            
            ui.separator();
            ui.label(format!("Materials: {}", model.materials.len()));
            ui.label(format!("Textures: {}", model.textures.len()));
            ui.label(format!("Sequences: {}", model.sequences.len()));
            ui.label(format!("Bones: {}", model.bones.len()));
            ui.label(format!("Helpers: {}", model.helpers.len()));
        });
    }

    fn show_geosets_panel(&mut self, ui: &mut egui::Ui, model: &Model) {
        ui.collapsing("Geosets", |ui| {
            egui::ScrollArea::vertical()
                .max_height(150.0)
                .show(ui, |ui| {
                    for (i, geoset) in model.geosets.iter().enumerate() {
                        if self.show_geosets.len() <= i {
                            self.show_geosets.push(true);
                        }

                        ui.group(|ui| {
                            ui.checkbox(&mut self.show_geosets[i], format!("Geoset {}", i));
                            ui.label(format!("  Vertices: {}", geoset.vertices.len()));
                            ui.label(format!("  Faces: {}", geoset.faces.len()));
                            ui.label(format!("  UVs: {}", geoset.tex_coords.len()));
                            if geoset.tex_coords.len() != geoset.vertices.len() {
                                ui.colored_label(
                                    egui::Color32::YELLOW, 
                                    format!("  ⚠ UV count mismatch!")
                                );
                            }
                        });
                    }
                });
        });
    }

    fn show_textures_panel(&self, ui: &mut egui::Ui, model: &Model) {
        ui.collapsing("Textures", |ui| {
            if model.textures.is_empty() {
                ui.label("No textures");
            } else {
                ui.label(format!("Total: {} textures", model.textures.len()));
                ui.separator();
                
                egui::ScrollArea::vertical()
                    .max_height(200.0)
                    .show(ui, |ui| {
                        for (i, texture) in model.textures.iter().enumerate() {
                            ui.group(|ui| {
                                ui.horizontal(|ui| {
                                    ui.label(format!("#{}", i));
                                    ui.label(&texture.filename);
                                });
                                
                                if texture.replaceable_id > 0 {
                                    ui.label(format!("  Replaceable ID: {}", texture.replaceable_id));
                                }
                                
                                if texture.image_data.is_some() {
                                    ui.colored_label(egui::Color32::GREEN, "  ✓ Loaded");
                                    ui.label(format!("  {}x{}", texture.width, texture.height));
                                } else {
                                    ui.colored_label(egui::Color32::YELLOW, "  ⏳ Not loaded yet");
                                }
                            });
                        }
                    });
                
                ui.separator();
                ui.colored_label(
                    egui::Color32::from_rgb(200, 150, 0),
                    "ℹ Texture loading not implemented yet"
                );
            }
        });
    }

    fn show_animation_panel(&mut self, ui: &mut egui::Ui, model: &Model) {
        if model.sequences.is_empty() {
            return;
        }

        ui.collapsing("Animation", |ui| {
            egui::ComboBox::from_label("Sequence")
                .selected_text(&model.sequences[self.selected_sequence].name)
                .show_ui(ui, |ui| {
                    for (i, seq) in model.sequences.iter().enumerate() {
                        ui.selectable_value(&mut self.selected_sequence, i, &seq.name);
                    }
                });

            // Show sequence details
            let seq = &model.sequences[self.selected_sequence];
            ui.label(format!("Frames: {} - {}", seq.start_frame, seq.end_frame));
            ui.label(format!("Duration: {} frames", seq.end_frame - seq.start_frame));
            ui.label(format!("Non-looping: {}", seq.non_looping));
            if let Some(rarity) = seq.rarity {
                ui.label(format!("Rarity: {}", rarity));
            }

            ui.separator();

            ui.horizontal(|ui| {
                if ui.button(if self.is_playing { "⏸" } else { "▶" }).clicked() {
                    self.is_playing = !self.is_playing;
                }
                ui.add(egui::Slider::new(&mut self.animation_time, 0.0..=1.0).text("Time"));
            });
        });
    }
}