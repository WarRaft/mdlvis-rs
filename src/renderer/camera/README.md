# Camera Module

Модуль управления камерой для 3D вьювера.

## Структура

- `state.rs` - Состояние камеры (позиция, углы, расстояние, цель)
- `controller.rs` - Контроллер для обработки ввода и трансформаций камеры
- `mod.rs` - Модуль, экспортирующий публичные типы

## Использование

### Создание контроллера

```rust
use crate::renderer::camera::{CameraController, CameraState};

let camera_state = CameraState::new(
    0.0,        // yaw (рыскание)
    0.3,        // pitch (тангаж)
    200.0,      // distance (расстояние от цели)
    [0.0, 0.0, 0.0], // target (точка, вокруг которой вращается камера)
);

let mut controller = CameraController::new(camera_state);
```

### Обработка событий

```rust
// Нажатие кнопки мыши
controller.on_mouse_button(MouseButton::Right, true);

// Модификаторы клавиатуры
controller.on_modifiers(shift_pressed, alt_pressed);

// Движение мыши (возвращает true, если камера изменилась)
let changed = controller.on_mouse_move((x, y));

// Зум
let aspect_ratio = width as f32 / height as f32;
controller.zoom(delta, cursor_ndc, aspect_ratio);

// Жесты трекпада
controller.on_rotation_gesture(delta, control_pressed, shift_pressed);
controller.on_pan_gesture(delta_x, delta_y, control_pressed, shift_pressed);
```

### Управление

**Концепция:**
Камера вращается и зумится относительно **центра экрана** (viewport center = `target`).
Изначально центр экрана совпадает с центром сетки (0,0,0).
При панорамировании центр экрана смещается от центра сетки.

**Мышь и клавиатура:**
- **ПКМ** или **Alt+ЛКМ** - вращение вокруг центра экрана
- **СКМ** или **Shift+ПКМ** - панорамирование (смещение центра экрана)
- **Колесо мыши** - зум к/от курсора

**Трекпад (два пальца):**
- **Свайп двумя пальцами** (PanGesture):
  - Без модификаторов - **вращение вокруг центра сетки (0,0,0)**
  - **Shift** + свайп - панорамирование (смещение центра экрана)
- **Жест вращения** (RotationGesture):
  - Без модификаторов - **вращение вокруг центра сетки (0,0,0)**
  - **Shift** + жест - горизонтальное панорамирование
- **Pinch** (сжатие/растяжение) - зум к курсору

### Сброс камеры

```rust
controller.reset(); // Возврат к значениям по умолчанию
```

### Получение состояния

```rust
let state = controller.state();
// Используйте state.yaw, state.pitch, state.distance, state.target
```
