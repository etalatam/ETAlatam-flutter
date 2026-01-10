# Screenshots Profesionales para App Store - ETA

Este directorio contiene las herramientas y recursos para crear screenshots profesionales para la App Store de Apple.

## Contenido

- `plan-app-store.md` - Plan detallado de estrategia de screenshots
- `process_screenshots.py` - Script Python para procesar automáticamente las imágenes
- `usando las imagenes en la carpeta screen.md` - Especificaciones técnicas originales
- Screenshots originales (10 archivos PNG)

## Estado Actual

✅ **Dimensiones correctas:** Todas las imágenes ya tienen 1290 x 2796 px (iPhone 15 Pro Max)
✅ **Formato adecuado:** PNG con RGBA
✅ **Calidad excelente:** Imágenes nítidas y claras

## Próximos Pasos

### Opción 1: Procesamiento Automático con Script Python

1. **Instalar dependencias:**
   ```bash
   pip install Pillow
   ```

2. **Ejecutar el script:**
   ```bash
   cd /home/rbruno/workspace/eta/screenshot
   python3 process_screenshots.py
   ```

3. **Resultado:**
   - Se creará la carpeta `appstore_ready/` con 5 screenshots procesados
   - Cada imagen tendrá overlay oscuro y texto descriptivo
   - Nomenclatura: `1_active_trip.png`, `2_home.png`, etc.

**Ventajas:**
- Rápido y automatizado
- Consistencia en todos los screenshots
- Fácil de ajustar textos editando el script

**Limitaciones:**
- No incluye device frame del iPhone
- Usa fuentes del sistema (no SF Pro Display de Apple)
- Barra de estado sin ajustar

### Opción 2: Diseño Profesional Manual

Para resultados de máxima calidad:

1. **Usar Figma, Photoshop o Sketch**
2. **Descargar recursos:**
   - Device frame iPhone 15 Pro Max de [Apple Design Resources](https://developer.apple.com/design/resources/)
   - Fuente [SF Pro Display](https://developer.apple.com/fonts/)

3. **Crear canvas de 1290 x 2796 px**

4. **Por cada screenshot:**
   - Insertar device frame
   - Colocar screenshot original dentro del frame
   - Añadir overlay con degradado (ver colores en `plan-app-store.md`)
   - Añadir título y subtítulo (ver textos en `plan-app-store.md`)

### Opción 3: Herramientas Online

Servicios recomendados:
- [AppScreens.com](https://appscreens.com) - Profesional, automatizado (pago)
- [PlaceIt by Envato](https://placeit.net) - Templates variados
- [MockuPhone](https://mockuphone.com) - Gratuito, básico

## Secuencia de Screenshots para App Store

Según el análisis en `plan-app-store.md`, el orden óptimo es:

| # | Archivo | Mensaje | Propósito |
|---|---------|---------|-----------|
| 1 | `active_trip.png` | "Seguimiento en Tiempo Real" | LA PROMESA (función principal) |
| 2 | `home.png` | "Todo en un Solo Lugar" | FACILIDAD DE USO |
| 3 | `student-ist.png` | "Control Total de Asistencia" | BENEFICIO PRINCIPAL |
| 4 | `trip-stats.png` | "Estadísticas Detalladas" | DETALLES VALIOSOS |
| 5 | `support-chat.png` | "Soporte Cuando lo Necesites" | CONFIANZA Y SOPORTE |

## Checklist de Aprobación de Apple

Antes de subir a App Store Connect:

- [ ] Dimensiones exactas: 1290 x 2796 px
- [ ] Formato PNG de alta calidad
- [ ] Sin mencionar precios ("Gratis", "Oferta")
- [ ] Sin referencias a competidores
- [ ] Interfaz real de la app visible
- [ ] Texto legible sin hacer zoom
- [ ] Barra de estado limpia (idealmente 9:41 AM, batería 100%)
- [ ] Máximo 10 screenshots por idioma
- [ ] Perfil de color RGB o Display P3

## Ajustes Recomendados

### Para la Barra de Estado

Las capturas actuales tienen diferentes horas. Lo ideal es:
- **Hora:** 9:41 AM (estándar de Apple)
- **Batería:** 100%
- **Señal:** Completa

**Cómo ajustar:**
1. Abrir el simulador de iOS
2. Configurar la hora del sistema a 9:41 AM
3. Cargar la batería al 100%
4. Volver a capturar las pantallas

O usar herramientas como [StatusBuddy](https://github.com/insidegui/StatusBuddy) para iOS.

### Device Frame

El script actual NO incluye el marco del iPhone. Para añadirlo:

**Opción A - Manual:**
1. Descargar frame de [Apple Design Resources](https://developer.apple.com/design/resources/)
2. Usar Photoshop/Figma para componer

**Opción B - Herramientas:**
- [DeviceFrames.com](https://deviceframes.com)
- [Rotato](https://rotato.app) - App para macOS

## Textos Sugeridos

Ver documento completo en `plan-app-store.md`, sección "Secuencia Estratégica".

Todos los textos han sido diseñados siguiendo principios de:
- **Brevedad:** Máximo 2 líneas por título
- **Acción:** Verbos que indican valor inmediato
- **Claridad:** Sin jerga técnica
- **Beneficio:** Enfocados en el usuario, no en features

## Estructura de Archivos

```
screenshot/
├── README.md                                    (este archivo)
├── plan-app-store.md                           (estrategia completa)
├── process_screenshots.py                       (script de procesamiento)
├── usando las imagenes en la carpeta screen.md (specs técnicas)
├── active_trip.png                             ⭐ Screenshot #1
├── home.png                                    ⭐ Screenshot #2
├── student-ist.png                             ⭐ Screenshot #3
├── trip-stats.png                              ⭐ Screenshot #4
├── support-chat.png                            ⭐ Screenshot #5
├── login.png
├── recovery-password.png
├── profile.png
├── onboarding01.png
├── onboarding02.png
└── appstore_ready/                             (generado por script)
    ├── 1_active_trip.png
    ├── 2_home.png
    ├── 3_student_list.png
    ├── 4_trip_stats.png
    └── 5_support.png
```

## Recursos Adicionales

### Documentación Oficial
- [App Store Screenshot Specifications](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Store Product Page](https://developer.apple.com/app-store/product-page/)

### Herramientas Recomendadas
- **Diseño:** Figma, Sketch, Adobe XD
- **Device Frames:** Apple Design Resources, MockuPhone
- **Tipografía:** SF Pro Display (oficial de Apple)
- **Automatización:** Fastlane screenshots, AppScreens

### Inspiración
- [AppScreens Gallery](https://appscreens.com/gallery)
- [Mobbin](https://mobbin.com) - Screenshots de apps exitosas
- [Pttrns](https://pttrns.com) - Patterns de UI

## Preguntas Frecuentes

**P: ¿Por qué solo 5 screenshots si puedo subir hasta 10?**
R: Apple muestra solo los primeros 3-5 en la vista principal. Es mejor tener 5 excelentes que 10 mediocres. Enfócate en calidad sobre cantidad.

**P: ¿Puedo usar screenshots en español?**
R: Sí, pero considera crear versiones en inglés también si tu app está en múltiples idiomas. Puedes tener hasta 10 screenshots por cada idioma soportado.

**P: ¿Necesito el device frame obligatoriamente?**
R: No es obligatorio, pero hace que los screenshots se vean mucho más profesionales y mejora la percepción de calidad de tu app.

**P: ¿Qué pasa si Apple rechaza mis screenshots?**
R: Revisa el checklist de aprobación. Los rechazos más comunes son por mencionar precios, referencias a competidores, o texto ilegible.

## Notas del Proyecto

- **App:** ETA Latam - Gestión de Transporte Escolar
- **Plataforma:** iOS (iPhone 15 Pro Max como referencia)
- **Fecha:** Enero 2026
- **Estado:** Screenshots base listos, pendiente procesamiento final

---

**Última actualización:** 2026-01-10
**Autor:** Claude Code
**Proyecto:** ETA Latam
