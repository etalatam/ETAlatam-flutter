#!/usr/bin/env python3
"""
Script de verificación de imágenes para App Store
Valida que todas las imágenes cumplan con los requisitos de Apple

Uso: python3 verificar_imagenes.py
"""

from PIL import Image
import os
import glob

# Requisitos de Apple App Store
REQUIREMENTS = {
    'iPhone': {
        'path': 'appstore_ready_1284x2778',
        'width': 1284,
        'height': 2778,
        'device': 'iPhone 14/15 Pro Max',
        'min_images': 1,
        'max_images': 10
    },
    'iPad': {
        'path': 'ipad_ready_2048x2732',
        'width': 2048,
        'height': 2732,
        'device': 'iPad Pro 12.9" / iPad 13"',
        'min_images': 1,
        'max_images': 10
    }
}

def check_image(img_path, expected_width, expected_height):
    """Verifica una imagen individual"""
    errors = []

    try:
        with Image.open(img_path) as img:
            width, height = img.size

            # Verificar dimensiones
            if width != expected_width or height != expected_height:
                errors.append(f"Dimensión incorrecta: {width}×{height} (esperado: {expected_width}×{expected_height})")

            # Verificar formato
            if img.format != 'PNG':
                errors.append(f"Formato incorrecto: {img.format} (esperado: PNG)")

            # Verificar modo de color
            if img.mode not in ['RGB', 'RGBA']:
                errors.append(f"Modo de color incorrecto: {img.mode} (esperado: RGB o RGBA)")

            # Verificar tamaño de archivo (no debe ser demasiado grande)
            file_size = os.path.getsize(img_path)
            if file_size > 10 * 1024 * 1024:  # 10 MB
                errors.append(f"Archivo muy grande: {file_size / 1024 / 1024:.2f} MB (máximo recomendado: 10 MB)")

    except Exception as e:
        errors.append(f"Error al abrir imagen: {e}")

    return errors

def main():
    print("=" * 80)
    print("VERIFICACIÓN DE IMÁGENES PARA APP STORE")
    print("=" * 80)
    print()

    total_errors = 0
    total_warnings = 0

    for platform, config in REQUIREMENTS.items():
        print(f"\n{'=' * 80}")
        print(f"📱 {platform} - {config['device']}")
        print(f"   Requisito: {config['width']} × {config['height']} px")
        print(f"{'=' * 80}\n")

        # Verificar que la carpeta existe
        if not os.path.exists(config['path']):
            print(f"❌ ERROR: Carpeta no encontrada: {config['path']}")
            total_errors += 1
            continue

        # Buscar imágenes
        images = sorted(glob.glob(f"{config['path']}/*.png"))
        num_images = len(images)

        print(f"Número de imágenes encontradas: {num_images}")

        # Verificar cantidad de imágenes
        if num_images < config['min_images']:
            print(f"⚠️  ADVERTENCIA: Se encontraron {num_images} imágenes, se recomienda al menos {config['min_images']}")
            total_warnings += 1
        elif num_images > config['max_images']:
            print(f"❌ ERROR: Se encontraron {num_images} imágenes, máximo permitido: {config['max_images']}")
            total_errors += 1
        else:
            print(f"✓ Cantidad de imágenes OK ({num_images}/{config['max_images']})")

        print()

        # Verificar cada imagen
        for img_path in images:
            img_name = os.path.basename(img_path)
            errors = check_image(img_path, config['width'], config['height'])

            if errors:
                print(f"❌ {img_name}")
                for error in errors:
                    print(f"   • {error}")
                total_errors += len(errors)
            else:
                # Obtener info adicional
                with Image.open(img_path) as img:
                    file_size = os.path.getsize(img_path)
                    print(f"✓ {img_name:30s} {img.size[0]}×{img.size[1]} px ({file_size / 1024:.1f} KB)")

    # Verificaciones adicionales
    print(f"\n{'=' * 80}")
    print("CHECKLIST DE APROBACIÓN DE APPLE")
    print(f"{'=' * 80}\n")

    checklist = [
        ("Dimensiones correctas", total_errors == 0),
        ("Formato PNG", True),
        ("No menciona precios o 'Gratis'", None),
        ("No menciona competidores", None),
        ("Muestra interfaz real de la app", None),
        ("Texto legible", None),
        ("Sin contenido ofensivo", None),
    ]

    for item, status in checklist:
        if status is True:
            print(f"✓ {item}")
        elif status is False:
            print(f"❌ {item}")
        else:
            print(f"⚠️  {item} (verificar manualmente)")

    # Resumen final
    print(f"\n{'=' * 80}")
    print("RESUMEN DE VERIFICACIÓN")
    print(f"{'=' * 80}\n")

    if total_errors == 0 and total_warnings == 0:
        print("✅ ¡PERFECTO! Todas las imágenes cumplen con los requisitos de Apple")
        print("   Estás listo para subirlas a App Store Connect")
    elif total_errors == 0:
        print(f"⚠️  HAY {total_warnings} ADVERTENCIAS")
        print("   Las imágenes son válidas pero hay recomendaciones pendientes")
    else:
        print(f"❌ SE ENCONTRARON {total_errors} ERRORES")
        print("   Corrige los errores antes de subir a App Store Connect")

    print()
    print("=" * 80)

if __name__ == "__main__":
    main()
