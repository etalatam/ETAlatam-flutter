# language: es
Característica: Flujo de inicio de sesión
  Como usuario de la aplicación ETAlatam
  Quiero poder iniciar sesión con mis credenciales
  Para poder acceder a las funcionalidades de la aplicación

  Antecedentes:
    Dado que la aplicación está iniciada
    Y no hay sesión activa

  @smoke @critical
  Escenario: Inicio de sesión exitoso con credenciales válidas
    Dado que estoy en la pantalla de login
    Cuando ingreso "etalatam+representante1@gmail.com" en el campo de correo
    Y ingreso "casa1234" en el campo de contraseña
    Y presiono el botón de "Ingresar"
    Entonces debería ver la pantalla de inicio
    Y debería estar autenticado como "Representante1"
    Y mi rol debería ser "eta.guardians"

  @negative
  Escenario: Inicio de sesión fallido con credenciales inválidas
    Dado que estoy en la pantalla de login
    Cuando ingreso "usuario.invalido@test.com" en el campo de correo
    Y ingreso "passwordIncorrecta" en el campo de contraseña
    Y presiono el botón de "Ingresar"
    Entonces debería ver un mensaje de error
    Y el mensaje debería contener "401"
    Y debería permanecer en la pantalla de login

  @validation
  Escenario: Validación de campos vacíos
    Dado que estoy en la pantalla de login
    Cuando presiono el botón de "Ingresar" sin llenar los campos
    Entonces no debería poder continuar
    Y debería permanecer en la pantalla de login

  @navigation
  Escenario: Navegación automática con sesión activa
    Dado que tengo una sesión activa guardada
    Cuando inicio la aplicación
    Entonces debería ser redirigido automáticamente a la pantalla de inicio
    Y no debería ver la pantalla de login

  @security
  Escenario: Manejo de timeout en el login
    Dado que estoy en la pantalla de login
    Y el servidor no responde
    Cuando ingreso "etalatam+representante1@gmail.com" en el campo de correo
    Y ingreso "casa1234" en el campo de contraseña
    Y presiono el botón de "Ingresar"
    Entonces debería ver un mensaje de error de conexión después de 10 segundos
    Y el mensaje debería contener "Connection error"

  @persistence
  Escenario: Persistencia de datos de sesión después del login
    Dado que estoy en la pantalla de login
    Cuando ingreso "etalatam+representante1@gmail.com" en el campo de correo
    Y ingreso "casa1234" en el campo de contraseña
    Y presiono el botón de "Ingresar"
    Y navego a la pantalla de inicio exitosamente
    Entonces el token de sesión debería estar guardado en el almacenamiento local
    Y el id de usuario debería ser 128
    Y el nombre de relación debería ser "eta.guardians"
    Y el id de relación debería ser 20

  @stability
  Escenario: Prevención de bucle infinito en login
    Dado que estoy en la pantalla de login
    Cuando ingreso "etalatam+representante1@gmail.com" en el campo de correo
    Y ingreso "casa1234" en el campo de contraseña
    Y presiono el botón de "Ingresar"
    Entonces no debería volver a la pantalla de login automáticamente
    Y debería permanecer en la pantalla de inicio
    Y no debería ver parpadeos entre pantallas

  @recovery
  Escenario: Navegación a recuperación de contraseña
    Dado que estoy en la pantalla de login
    Cuando presiono el enlace "¿Olvidaste tu contraseña?"
    Entonces debería ver la pantalla de recuperación de contraseña
    Y debería poder ingresar mi correo para recuperación