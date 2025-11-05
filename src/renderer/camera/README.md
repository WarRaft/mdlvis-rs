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
```

### Управление

- **ПКМ** или **Alt+ЛКМ** - вращение камеры вокруг цели
- **СКМ** или **Shift+ПКМ** - панорамирование (перемещение цели)
- **Колесо мыши** - зум к/от курсора

### Сброс камеры

```rust
controller.reset(); // Возврат к значениям по умолчанию
```

### Получение состояния

```rust
let state = controller.state();
// Используйте state.yaw, state.pitch, state.distance, state.target
```
