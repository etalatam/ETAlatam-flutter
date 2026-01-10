#!/usr/bin/env python3
"""
Script para crear screenshots profesionales para App Store
Basado en las especificaciones de Apple para iPhone 15 Pro Max

Dimensiones: 1290 x 2796 px
Perfil de color: RGB/Display P3
Formato: PNG

Requisitos:
    pip install Pillow
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os
from pathlib import Path


class AppStoreScreenshotProcessor:
    """Procesador de screenshots para App Store"""

    # Dimensiones requeridas por Apple
    WIDTH = 1290
    HEIGHT = 2796

    # Configuración de screenshots según plan estratégico
    SCREENSHOTS_CONFIG = {
        "1_active_trip": {
            "source": "active_trip.png",
            "title": "Seguimiento en Tiempo Real",
            "subtitle": "Ubica el autobús escolar en cada momento del trayecto",
            "gradient_colors": [(26, 35, 126), (13, 71, 161)],  # Azul oscuro a azul medio
            "text_position": "top"
        },
        "2_home": {
            "source": "home.png",
            "title": "Todo en un Solo Lugar",
            "subtitle": "Rutas activas e historial de viajes al alcance de tu mano",
            "gradient_colors": [(0, 105, 92), (38, 166, 154)],  # Verde turquesa a verde claro
            "text_position": "top"
        },
        "3_student_list": {
            "source": "student-ist.png",
            "title": "Control Total de Asistencia",
            "subtitle": "Verifica quién abordó el autobús con un solo vistazo",
            "gradient_colors": [(2, 119, 189), (255, 255, 255)],  # Azul cielo a blanco
            "text_position": "top"
        },
        "4_trip_stats": {
            "source": "trip-stats.png",
            "title": "Estadísticas Detalladas",
            "subtitle": "Tiempo, distancia y paradas de cada viaje registrados",
            "gradient_colors": [(46, 125, 50), (102, 187, 106)],  # Verde a verde claro
            "text_position": "bottom"
        },
        "5_support": {
            "source": "support-chat.png",
            "title": "Soporte Cuando lo Necesites",
            "subtitle": "Resuelve incidencias directamente desde la app",
            "gradient_colors": [(66, 66, 66), (117, 117, 117)],  # Gris a gris claro
            "text_position": "top"
        }
    }

    def __init__(self, input_dir=".", output_dir="appstore_ready"):
        """
        Inicializa el procesador

        Args:
            input_dir: Directorio con los screenshots originales
            output_dir: Directorio donde se guardarán los screenshots procesados
        """
        self.input_dir = Path(input_dir)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)

    def create_gradient_background(self, color1, color2, vertical=True):
        """
        Crea un fondo con degradado

        Args:
            color1: Color inicial (R, G, B)
            color2: Color final (R, G, B)
            vertical: Si True, degradado vertical; si False, horizontal

        Returns:
            Image: Imagen con degradado
        """
        background = Image.new('RGB', (self.WIDTH, self.HEIGHT))
        draw = ImageDraw.Draw(background)

        if vertical:
            # Degradado vertical
            for y in range(self.HEIGHT):
                # Interpolar entre los dos colores
                ratio = y / self.HEIGHT
                r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
                g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
                b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
                draw.line([(0, y), (self.WIDTH, y)], fill=(r, g, b))
        else:
            # Degradado horizontal
            for x in range(self.WIDTH):
                ratio = x / self.WIDTH
                r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
                g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
                b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
                draw.line([(x, 0), (x, self.HEIGHT)], fill=(r, g, b))

        return background

    def create_overlay_gradient(self, position="top", opacity=0.8):
        """
        Crea un overlay de degradado semi-transparente para colocar texto

        Args:
            position: "top" o "bottom"
            opacity: Opacidad del overlay (0.0 a 1.0)

        Returns:
            Image: Overlay con degradado transparente
        """
        overlay = Image.new('RGBA', (self.WIDTH, self.HEIGHT), (0, 0, 0, 0))
        draw = ImageDraw.Draw(overlay)

        # Altura del overlay (aproximadamente 1/3 de la imagen)
        overlay_height = self.HEIGHT // 3

        if position == "top":
            # Degradado de negro a transparente de arriba hacia abajo
            for y in range(overlay_height):
                ratio = y / overlay_height
                alpha = int(255 * opacity * (1 - ratio))
                draw.line([(0, y), (self.WIDTH, y)], fill=(0, 0, 0, alpha))
        else:
            # Degradado de transparente a negro de abajo hacia arriba
            start_y = self.HEIGHT - overlay_height
            for y in range(overlay_height):
                ratio = y / overlay_height
                alpha = int(255 * opacity * ratio)
                actual_y = start_y + y
                draw.line([(0, actual_y), (self.WIDTH, actual_y)], fill=(0, 0, 0, alpha))

        return overlay

    def add_text_to_image(self, image, title, subtitle, position="top"):
        """
        Añade texto (título y subtítulo) a la imagen

        Args:
            image: Imagen PIL
            title: Texto del título
            subtitle: Texto del subtítulo
            position: "top" o "bottom"

        Returns:
            Image: Imagen con texto añadido
        """
        draw = ImageDraw.Draw(image)

        # Intentar usar fuentes del sistema
        # En producción, usar SF Pro Display de Apple
        font_paths = [
            "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
            "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
            "/System/Library/Fonts/SFNSDisplay.ttf",  # macOS
            "C:\\Windows\\Fonts\\arialbd.ttf",  # Windows
        ]

        title_font = None
        for font_path in font_paths:
            try:
                title_font = ImageFont.truetype(font_path, 90)
                subtitle_font = ImageFont.truetype(font_path.replace("-Bold", ""), 52)
                break
            except:
                continue

        if title_font is None:
            # Fallback a fuente predeterminada
            title_font = ImageFont.load_default()
            subtitle_font = ImageFont.load_default()
            print("⚠️  Advertencia: No se encontró fuente adecuada. Usando fuente predeterminada.")
            print("   Para mejores resultados, instala fuentes o usa SF Pro Display de Apple.")

        # Calcular posiciones del texto
        padding = 80
        title_y = padding if position == "top" else self.HEIGHT - 400

        # Añadir sombra al texto para mejor legibilidad
        shadow_offset = 3

        # Manejar títulos largos con word wrap
        max_width = self.WIDTH - (padding * 2)
        title_words = title.split()
        title_lines = []
        current_title_line = []

        for word in title_words:
            test_line = ' '.join(current_title_line + [word])
            try:
                bbox = draw.textbbox((0, 0), test_line, font=title_font)
                text_width = bbox[2] - bbox[0]
                if text_width < max_width:
                    current_title_line.append(word)
                else:
                    if current_title_line:
                        title_lines.append(' '.join(current_title_line))
                    current_title_line = [word]
            except:
                if len(test_line) * 45 < max_width:
                    current_title_line.append(word)
                else:
                    if current_title_line:
                        title_lines.append(' '.join(current_title_line))
                    current_title_line = [word]
        if current_title_line:
            title_lines.append(' '.join(current_title_line))

        # Dibujar cada línea del título
        current_y = title_y
        for i, title_line in enumerate(title_lines):
            # Sombra
            draw.text((padding + shadow_offset, current_y + shadow_offset),
                     title_line, font=title_font, fill=(0, 0, 0, 180))
            # Texto
            draw.text((padding, current_y), title_line, font=title_font, fill=(255, 255, 255, 255))
            current_y += 110

        # Ajustar posición del subtítulo
        subtitle_y = current_y + 20 if position == "top" else self.HEIGHT - 250

        # Dibujar subtítulo con sombra (con word wrap mejorado)
        max_width = self.WIDTH - (padding * 2)
        words = subtitle.split()
        lines = []
        current_line = []

        for word in words:
            test_line = ' '.join(current_line + [word])
            # Usar bbox para medir el ancho real del texto
            try:
                bbox = draw.textbbox((0, 0), test_line, font=subtitle_font)
                text_width = bbox[2] - bbox[0]
                if text_width < max_width:
                    current_line.append(word)
                else:
                    if current_line:
                        lines.append(' '.join(current_line))
                    current_line = [word]
            except:
                # Fallback a aproximación
                if len(test_line) * 22 < max_width:
                    current_line.append(word)
                else:
                    if current_line:
                        lines.append(' '.join(current_line))
                    current_line = [word]
        if current_line:
            lines.append(' '.join(current_line))

        # Dibujar cada línea del subtítulo
        for i, line in enumerate(lines):
            line_y = subtitle_y + (i * 60)
            # Sombra
            draw.text((padding + shadow_offset, line_y + shadow_offset),
                     line, font=subtitle_font, fill=(0, 0, 0, 140))
            # Texto
            draw.text((padding, line_y), line, font=subtitle_font, fill=(255, 255, 255, 230))

        return image

    def process_screenshot(self, config_key):
        """
        Procesa un screenshot según la configuración

        Args:
            config_key: Clave de configuración (ej. "1_active_trip")
        """
        config = self.SCREENSHOTS_CONFIG[config_key]
        source_path = self.input_dir / config["source"]

        if not source_path.exists():
            print(f"❌ Error: No se encontró {config['source']}")
            return

        print(f"📸 Procesando: {config['source']}")

        # Cargar screenshot original
        screenshot = Image.open(source_path)

        # Verificar dimensiones
        if screenshot.size != (self.WIDTH, self.HEIGHT):
            print(f"⚠️  Advertencia: {config['source']} tiene dimensiones {screenshot.size}")
            print(f"   Se esperaba {self.WIDTH}x{self.HEIGHT}")
            screenshot = screenshot.resize((self.WIDTH, self.HEIGHT), Image.Resampling.LANCZOS)

        # Convertir a RGBA si es necesario
        if screenshot.mode != 'RGBA':
            screenshot = screenshot.convert('RGBA')

        # Crear overlay de degradado para el texto
        overlay = self.create_overlay_gradient(
            position=config["text_position"],
            opacity=0.7
        )

        # Combinar screenshot con overlay
        result = Image.alpha_composite(screenshot, overlay)

        # Añadir texto
        result = self.add_text_to_image(
            result,
            config["title"],
            config["subtitle"],
            config["text_position"]
        )

        # Convertir a RGB para guardar como PNG sin canal alpha
        result_rgb = Image.new('RGB', result.size, (255, 255, 255))
        result_rgb.paste(result, mask=result.split()[3])  # Usar canal alpha como máscara

        # Guardar
        output_path = self.output_dir / f"{config_key}.png"
        result_rgb.save(output_path, 'PNG', quality=100, optimize=False)

        print(f"✅ Guardado: {output_path}")

    def process_all(self):
        """Procesa todos los screenshots según la configuración"""
        print("\n" + "="*60)
        print("🚀 PROCESADOR DE SCREENSHOTS PARA APP STORE")
        print("="*60)
        print(f"📁 Directorio de entrada: {self.input_dir}")
        print(f"📁 Directorio de salida: {self.output_dir}")
        print(f"📐 Dimensiones: {self.WIDTH} x {self.HEIGHT} px")
        print("="*60 + "\n")

        for config_key in self.SCREENSHOTS_CONFIG.keys():
            self.process_screenshot(config_key)
            print()

        print("="*60)
        print("✨ PROCESO COMPLETADO")
        print("="*60)
        print(f"\n📂 Los screenshots están en: {self.output_dir.absolute()}")
        print("\n⚠️  IMPORTANTE:")
        print("   - Revisa que el texto sea legible en todas las capturas")
        print("   - Considera ajustar la barra de estado a 9:41 AM y 100% batería")
        print("   - Para resultados profesionales, añade device frame del iPhone 15 Pro Max")
        print("   - Usa SF Pro Display de Apple para tipografía oficial")
        print()


def main():
    """Función principal"""
    # Directorio actual (donde están los screenshots)
    current_dir = Path(__file__).parent

    # Crear procesador
    processor = AppStoreScreenshotProcessor(
        input_dir=current_dir,
        output_dir=current_dir / "appstore_ready"
    )

    # Procesar todos los screenshots
    processor.process_all()


if __name__ == "__main__":
    main()
