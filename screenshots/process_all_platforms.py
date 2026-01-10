#!/usr/bin/env python3
"""
Script para procesar imágenes para TODAS las plataformas de App Store
Genera automáticamente imágenes para iPhone y iPad

Uso: python3 process_all_platforms.py
"""

from PIL import Image
import os
import glob

# Dimensiones para cada plataforma
PLATFORMS = {
    'iPhone': {
        'width': 1284,
        'height': 2778,
        'output_dir': 'appstore_1284x2778',
        'description': 'iPhone 14/15 Pro Max'
    },
    'iPad': {
        'width': 2048,
        'height': 2732,
        'output_dir': 'ipad_2048x2732',
        'description': 'iPad Pro 12.9" / iPad 13"'
    }
}

def resize_image(input_path, output_path, target_width, target_height):
    """Redimensiona imagen a dimensiones específicas"""
    try:
        with Image.open(input_path) as img:
            resized = img.resize((target_width, target_height), Image.Resampling.LANCZOS)
            resized.save(output_path, 'PNG', optimize=True, quality=95)
            return True
    except Exception as e:
        print(f"Error: {e}")
        return False

def main():
    print("=" * 70)
    print("PROCESADOR DE IMÁGENES PARA APP STORE")
    print("Genera imágenes para iPhone y iPad automáticamente")
    print("=" * 70)
    print()

    # Buscar imágenes PNG
    png_files = [f for f in glob.glob("*.png") if os.path.isfile(f)]

    if not png_files:
        print("❌ No se encontraron imágenes PNG en el directorio actual.")
        return

    print(f"📸 Se encontraron {len(png_files)} imágenes PNG\n")

    # Procesar para cada plataforma
    for platform_name, config in PLATFORMS.items():
        print(f"\n{'=' * 70}")
        print(f"📱 Procesando para {platform_name}")
        print(f"   {config['description']}")
        print(f"   Dimensión: {config['width']} × {config['height']} px")
        print(f"{'=' * 70}\n")

        # Crear directorio de salida
        os.makedirs(config['output_dir'], exist_ok=True)

        successful = 0
        failed = 0

        for img_name in sorted(png_files):
            output_path = os.path.join(config['output_dir'], img_name)

            if resize_image(img_name, output_path, config['width'], config['height']):
                successful += 1
                print(f"✓ {img_name:40s} -> {config['width']} × {config['height']} px")
            else:
                failed += 1
                print(f"✗ {img_name:40s} -> ERROR")

        print(f"\n{platform_name} - Exitosas: {successful}, Fallidas: {failed}")
        print(f"Guardadas en: ./{config['output_dir']}/")

    print("\n" + "=" * 70)
    print("✅ PROCESAMIENTO COMPLETADO")
    print("=" * 70)
    print("\nCarpetas generadas:")
    for platform_name, config in PLATFORMS.items():
        print(f"  • {config['output_dir']:30s} ({platform_name})")
    print()

if __name__ == "__main__":
    main()
