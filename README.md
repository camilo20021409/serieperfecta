🏋️‍♂️ Serie Perfecta

Esta una app móvil hecha con Flutter pensada para ayudarte a organizar y realizar tus rutinas de ejercicio por intervalos. Ideal si mides tus tiempos a la hora de tus entrenamientos o cualquier actividad que necesite controlar tiempos con avisos por sonido y vibración.

✨ ¿Qué puedes hacer con la app?

- **Crear tus propias rutinas:** Asigna un nombre y un tiempo de preparación antes de empezar.
- **Diseñar intervalos a tu medida:** Para cada bloque puedes definir:
  - Cuánto dura el ejercicio.
  - Cuánto dura el descanso.
  - Cuántas veces se repite ese ese ejericio en especifico.
- **Cambiar el orden de los intervalos** fácilmente arrastrándolos.
- **Recibir avisos por sonido** para saber cuándo empezar o descansar.
- **Recibir vibraciones** en momentos clave, útil si tienes el volumen bajo.
- **Guardar todo localmente** en tu celular usando Hive, sin perder tus rutinas ya creadas.

## 🚀 ¿Con qué está hecha?

- **Flutter** como framework principal.
- **Dart** como lenguaje de programación.
- **Provider** para la gestión de estado.
- **Hive** y **hive_flutter** para guardar rutinas e intervalos.
- **UUID** para generar IDs únicos.
- **just_audio** para reproducir sonidos.
- **vibration** para el feedback háptico.
- **shared_preferences** para guardar configuraciones simples.
- **path_provider** para ubicar carpetas del dispositivo.


## 📦 ¿Cómo probarla?

1. **Clona el repositorio:**

   ```bash
   git clone <URL_DE_TU_REPOSITORIO>
2. **Instala las dependencias:**
    ```bash
    flutter pub get
3. **Genera el código de Hive:**
   ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
4. **Corre la app:**
   ```bash
    flutter run
   
## 📱 ¿Cómo se usa?

1. **Inicio**
   - Verás tus rutinas guardadas, un mensaje para crear una nueva y el botón de ajustes.
2. **ajustes**
   - podras cambiar el tema entre claro y modo oscuro
4. **Crear o editar una rutina**
   - Pulsa el botón `+` para empezar una nueva rutina.
   - También puedes tocar una rutina ya creada para editarla.
   - Agrega intervalos con sus tiempos y repeticiones.
   - Agrega un nombre de rutina.
   - Puedes cambiarles el orden o eliminarlos.
   - Guarda los cambios con el botón "Guardar Rutina".
5. **Ejecutar la rutina**
   - En el inicio dale play a tu rutina e iniciará de forma inmediata.
   - Existen tres botones, repetir, play, y siguiente.
     - Repetir para reiniciar la rutina.
     - Play para pausar o continuar rutina.
     - siguiente para pasar a al siguiente estado de la rutina. 
