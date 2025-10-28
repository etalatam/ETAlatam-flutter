# Instrucciones para Probar el Login en Dispositivo Android

## Estado de la Conexión
✅ **Dispositivo conectado exitosamente:**
- IP: 192.168.0.197:39757
- Modelo: 2312DRAABG
- Sistema: Android 15 (API 35)
- Arquitectura: arm64

## Aplicación en Ejecución
La aplicación ETAlatam se está instalando y ejecutando en tu dispositivo Android.

## Credenciales de Prueba

```
Email: etalatam+representante1@gmail.com
Contraseña: casa1234
```

## Pasos para Probar el Login

### 1. Esperar a que la aplicación se abra
- La aplicación se abrirá automáticamente una vez instalada
- Verás el logo de ETA y la pantalla de login

### 2. Ingresar Credenciales
- **Campo Email/Usuario:** `etalatam+representante1@gmail.com`
- **Campo Contraseña:** `casa1234`
- Presionar el botón **INICIAR**

### 3. Resultado Esperado
Si el login es exitoso, deberías:
- Ver una pantalla de carga momentánea
- Ser redirigido al dashboard principal
- Ver el nombre "Representante1 Demo" en algún lugar de la interfaz
- Tener acceso a las funcionalidades del rol "Guardián/Representante"

## Verificación del Login Exitoso

### Información del Usuario que Debería Aparecer:
- **Nombre:** Representante1 Demo
- **Rol:** Guardian (eta.guardians)
- **ID Usuario:** 128
- **Email:** etalatam+representante1@gmail.com

## Solución de Problemas

### Si el login falla:

1. **Error de conexión:**
   - Verificar que el dispositivo tenga internet
   - Verificar que pueda acceder a: https://api.etalatam.com

2. **Error de credenciales:**
   - Verificar que el email esté escrito correctamente
   - Verificar que la contraseña sea exactamente: `casa1234`

3. **La aplicación no se abre:**
   - Verificar en el terminal si hay errores
   - Reintentar con: `flutter run -d 192.168.0.197:39757`

4. **Permisos:**
   - La app puede solicitar permisos de:
     - Ubicación (para tracking GPS)
     - Notificaciones (para alertas)
     - Cámara (opcional)
   - Aceptar los permisos necesarios

## Comandos Útiles

```bash
# Ver logs del dispositivo
adb logcat | grep -i eta

# Reinstalar la aplicación
adb uninstall com.schoolroutes.eta_school_app
flutter run -d 192.168.0.197:39757

# Ver información del dispositivo
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release
```

## Estado de las Pruebas Automatizadas

✅ **Pruebas de API:** El login fue verificado exitosamente
- Token de autenticación recibido
- Información del usuario obtenida correctamente
- Manejo de errores funcionando

## Notas Adicionales

- La aplicación está en modo DEBUG
- Versión: 1.12.35
- Los logs detallados están disponibles en el terminal
- El hot reload está disponible (presionar 'r' en el terminal)

---

**Última actualización:** 27 de Octubre de 2025
**Estado:** Aplicación instalándose en dispositivo Android