from PIL import Image
import os
import sys

# Fix encoding for Windows
sys.stdout.reconfigure(encoding='utf-8')

# Logo dosyası
logo_path = "waldo_logo.png"
output_dir = "web/icons"

# Ensure output directory exists
os.makedirs(output_dir, exist_ok=True)

# Open the logo
try:
    logo = Image.open(logo_path)
    print(f"[OK] Logo yuklendi: {logo.size}")
    
    # İkon boyutları
    sizes = [192, 512]
    
    for size in sizes:
        # Regular icon (square with transparent background)
        icon = Image.new('RGBA', (size, size), (255, 255, 255, 0))
        
        # Logo'yu boyutlandır (padding ile)
        padding = int(size * 0.1)  # %10 padding
        logo_size = size - (2 * padding)
        logo_resized = logo.resize((logo_size, logo_size), Image.Resampling.LANCZOS)
        
        # Logo'yu ortala
        position = (padding, padding)
        icon.paste(logo_resized, position, logo_resized if logo_resized.mode == 'RGBA' else None)
        
        # Kaydet
        icon_path = os.path.join(output_dir, f"Icon-{size}.png")
        icon.save(icon_path, "PNG")
        print(f"[OK] Ikon olusturuldu: Icon-{size}.png")
        
        # Maskable icon (daha fazla padding)
        maskable = Image.new('RGBA', (size, size), (255, 255, 255, 255))  # Beyaz arka plan
        maskable_padding = int(size * 0.2)  # %20 padding (maskable için)
        maskable_logo_size = size - (2 * maskable_padding)
        maskable_logo = logo.resize((maskable_logo_size, maskable_logo_size), Image.Resampling.LANCZOS)
        
        # Ortala
        maskable_position = (maskable_padding, maskable_padding)
        maskable.paste(maskable_logo, maskable_position, maskable_logo if maskable_logo.mode == 'RGBA' else None)
        
        # Kaydet
        maskable_path = os.path.join(output_dir, f"Icon-maskable-{size}.png")
        maskable.save(maskable_path, "PNG")
        print(f"[OK] Maskable ikon olusturuldu: Icon-maskable-{size}.png")
    
    print("\n[SUCCESS] Tum ikonlar basariyla olusturuldu!")
    
except FileNotFoundError:
    print("[ERROR] HATA: waldo_logo.png dosyasi bulunamadi!")
    print("[INFO] Lutfen logoyu 'waldo_logo.png' olarak kaydedin.")
except Exception as e:
    print(f"[ERROR] HATA: {e}")

