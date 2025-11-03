use egui::Context;

use crate::model::Model;

pub struct Ui {
    show_geosets: Vec<bool>,
    selected_sequence: usize,
    animation_time: f32,
    is_playing: bool,
}

impl Ui {
    pub fn new() -> Self {
        Self {
            show_geosets: Vec::new(),
            selected_sequence: 0,
            animation_time: 0.0,
            is_playing: false,
        }
    }

    pub fn show(&mut self, ctx: &egui::Context, model: &Option<Model>) {
        egui::SidePanel::left("left_panel")
            .default_width(250.0)
            .show(ctx, |ui| {
                ui.heading("MDLVis-RS");

                if let Some(model) = model {
                    self.show_model_info(ui, model);
                    self.show_geosets_panel(ui, model);
                    self.show_animation_panel(ui, model);
                } else {
                    ui.label("No model loaded");
                    if ui.button("Load Model").clicked() {
                        // TODO: Implement file dialog
                    }
                }
            });
    }

    fn show_model_info(&self, ui: &mut egui::Ui, model: &Model) {
        ui.collapsing("Model Info", |ui| {
            ui.label(format!("Name: {}", model.name));
            ui.label(format!("Geosets: {}", model.geosets.len()));
            ui.label(format!("Materials: {}", model.materials.len()));
            ui.label(format!("Textures: {}", model.textures.len()));
            ui.label(format!("Sequences: {}", model.sequences.len()));
        });
    }

    fn show_geosets_panel(&mut self, ui: &mut egui::Ui, model: &Model) {
        ui.collapsing("Geosets", |ui| {
            for (i, geoset) in model.geosets.iter().enumerate() {
                if self.show_geosets.len() <= i {
                    self.show_geosets.push(true);
                }

                ui.horizontal(|ui| {
                    ui.checkbox(&mut self.show_geosets[i], format!("Geoset {}", i));
                    ui.label(format!("{} verts", geoset.vertices.len()));
                });
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

            ui.horizontal(|ui| {
                if ui.button(if self.is_playing { "⏸" } else { "▶" }).clicked() {
                    self.is_playing = !self.is_playing;
                }
                ui.add(egui::Slider::new(&mut self.animation_time, 0.0..=1.0).text("Time"));
            });
        });
    }
}