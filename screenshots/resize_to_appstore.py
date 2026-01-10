#!/usr/bin/env python3
"""
Script para redimensionar im\u00e1genes a las dimensiones correctas de App Store
Uso: python3 resize_to_appstore.py
"""

from PIL import Image
import os
import glob
import sys

# Dimensiones correctas seg\u00fan App Store
TARGET_WIDTH = 1284
TARGET_HEIGHT = 2778

def resize_image(input_path, output_path):
    """Redimensiona la imagen a las dimensiones exactas requeridas"""
    try:
        with Image.open(input_path) as img:
            # Redimensionar usando LANCZOS para alta calidad
            resized = img.resize((TARGET_WIDTH, TARGET_HEIGHT), Image.Resampling.LANCZOS)
            resized.save(output_path, 'PNG', optimize=True, quality=95)
            return resized.size, True
    except Exception as e:
        print(f"Error procesando {input_path}: {e}")
        return None, False

def main():
    print("=" * 70)
    print("REDIMENSIONADOR DE IM\u00c1GENES PARA APP STORE")
    print("=" * 70)
    print(f"\nDimensi\u00f3n objetivo: {TARGET_WIDTH} x {TARGET_HEIGHT} px")
    print(f"(iPhone 14 Pro Max / iPhone 15 Pro Max)")
    print()

    # Crear directorio de salida
    output_dir = "appstore_1284x2778"
    os.makedirs(output_dir, exist_ok=True)

    # Buscar todas las im\u00e1genes PNG en el directorio actual
    png_files = [f for f in glob.glob("*.png") if os.path.isfile(f)]

    if not png_files:
        print("No se encontraron im\u00e1genes PNG en el directorio actual.")
        return

    print(f"Se encontraron {len(png_files)} im\u00e1genes PNG\n")
    print("Procesando...")
    print("-" * 70)

    successful = 0
    failed = 0

    for img_name in sorted(png_files):
        output_path = os.path.join(output_dir, img_name)
        new_size, success = resize_image(img_name, output_path)

        if success:
            successful += 1
            print(f"\u2713 {img_name:40s} -> {new_size[0]} x {new_size[1]} px")
        else:
            failed += 1
            print(f"\u2717 {img_name:40s} -> ERROR")

    print("-" * 70)
    print(f"\n\u2713 Procesadas exitosamente: {successful}")
    if failed > 0:
        print(f"\u2717 Fallidas: {failed}")

    print(f"\nIm\u00e1genes guardadas en: ./{output_dir}/")
    print("=" * 70)

if __name__ == "__main__":
    main()
