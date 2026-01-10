# Cómo Subir las Imágenes a App Store Connect

## ✅ Estado: LISTO PARA SUBIR

Todas las imágenes han sido procesadas y verificadas. Cumplen al 100% con los requisitos de Apple.

---

## 📂 Ubicación de las Imágenes

### Para iPhone
```
/home/rbruno/workspace/eta/screenshot/appstore_ready_1284x2778/
```

**5 imágenes (1284 × 2778 px):**
- 1_active_trip.png
- 2_home.png
- 3_student_list.png
- 4_trip_stats.png
- 5_support.png

### Para iPad
```
/home/rbruno/workspace/eta/screenshot/ipad_ready_2048x2732/
```

**5 imágenes (2048 × 2732 px):**
- 1_active_trip.png
- 2_home.png
- 3_student_list.png
- 4_trip_stats.png
- 5_support.png

---

## 🚀 Pasos para Subir a App Store Connect

### 1. Accede a App Store Connect
- Ve a: https://appstoreconnect.apple.com
- Inicia sesión con tu Apple ID de desarrollador

### 2. Selecciona tu App
- Haz clic en "Mis Apps"
- Busca y selecciona "ETA Latam" (o el nombre de tu app)

### 3. Ve a la Sección de Screenshots
- En el menú lateral, selecciona la versión de tu app (o crea una nueva)
- Busca la sección "App Previews and Screenshots"

### 4. Sube las Imágenes de iPhone
- Selecciona "iPhone 6.7 Display" o "iPhone 14/15 Pro Max"
- Haz clic en el botón "+" o arrastra las imágenes
- Sube las 5 imágenes de la carpeta `appstore_ready_1284x2778/`
- **Importante:** Súbelas en este orden:
  1. 1_active_trip.png
  2. 2_home.png
  3. 3_student_list.png
  4. 4_trip_stats.png
  5. 5_support.png

### 5. Sube las Imágenes de iPad
- Selecciona "iPad Pro (6th Gen) 12.9 Display" o similar
- Haz clic en el botón "+" o arrastra las imágenes
- Sube las 5 imágenes de la carpeta `ipad_ready_2048x2732/`
- **Importante:** Súbelas en el mismo orden que iPhone

### 6. Guarda los Cambios
- Haz clic en "Guardar" en la parte superior derecha
- Espera a que las imágenes se procesen (puede tardar unos minutos)

---

## ✅ Checklist Final Antes de Subir

Verifica que las imágenes:
- [ ] No mencionen precios o palabras como "Gratis", "Oferta"
- [ ] No mencionen competidores (otras apps similares)
- [ ] Muestren la interfaz real de tu app
- [ ] El texto sea legible y claro
- [ ] No contengan información sensible (datos personales, contraseñas, etc.)

---

## 📝 Notas Importantes

### Orden de las Imágenes
El orden es importante porque Apple muestra las primeras 3-5 imágenes en la vista principal de la App Store. La secuencia recomendada es:

1. **Active Trip** - Muestra la función principal (seguimiento en tiempo real)
2. **Home** - Demuestra facilidad de uso
3. **Student List** - Presenta el beneficio principal (control de asistencia)
4. **Trip Stats** - Muestra detalles valiosos
5. **Support** - Genera confianza

### Tiempo de Procesamiento
- Las imágenes pueden tardar 5-10 minutos en procesarse
- No cierres la ventana hasta que veas el mensaje de confirmación

### Múltiples Idiomas
Si tu app soporta varios idiomas, puedes subir diferentes screenshots para cada idioma:
- Selecciona el idioma en el menú desplegable
- Sube las imágenes correspondientes a ese idioma

---

## ⚠️ Posibles Problemas y Soluciones

### Problema: "Dimensiones incorrectas"
**Solución:** Usa las imágenes de las carpetas específicas (`appstore_ready_1284x2778/` para iPhone, `ipad_ready_2048x2732/` para iPad)

### Problema: "Archivo muy grande"
**Solución:** Las imágenes ya están optimizadas, pero si hay problemas, ejecuta:
```bash
python3 verificar_imagenes.py
```

### Problema: "Formato no soportado"
**Solución:** Todas las imágenes están en PNG. Si hay problemas, verifica que uses las carpetas correctas.

### Problema: "No puedo ver el dispositivo correcto"
**Solución:**
- Para iPhone: Busca "6.7 Display" o "iPhone 14/15 Pro Max"
- Para iPad: Busca "12.9 Display" o "iPad Pro"

---

## 🔍 Verificación Post-Subida

Después de subir:
1. Verifica que las 5 imágenes aparezcan en el orden correcto
2. Haz clic en cada imagen para ver la vista previa
3. Confirma que el texto sea legible
4. Revisa que no haya errores o advertencias de Apple

---

## 📞 Soporte Adicional

Si tienes problemas:
- Revisa la documentación oficial: https://developer.apple.com/help/app-store-connect/
- Ejecuta el script de verificación: `python3 verificar_imagenes.py`
- Consulta `RESUMEN_FINAL_PROCESAMIENTO.md` para más detalles

---

## 🎉 ¡Éxito!

Una vez subidas las imágenes:
- Completa el resto de la información de tu app (descripción, keywords, etc.)
- Revisa toda la información en App Store Connect
- Cuando todo esté listo, envía la app para revisión

**¡Buena suerte con tu publicación en la App Store!**

---

**Última actualización:** 2026-01-10
**Imágenes procesadas:** 10 (5 iPhone + 5 iPad)
**Estado:** ✅ Verificado y listo
