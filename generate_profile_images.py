#!/usr/bin/env python3
"""
Generate placeholder profile images for AGA geniuses
Creates circular images with orange gradient backgrounds and initials
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Profile data matching the geniuses
profiles = [
    {"name": "profile_nkosi", "initials": "ND", "color1": "#fb923c", "color2": "#f59e0b"},
    {"name": "profile_amina", "initials": "AM", "color1": "#fbbf24", "color2": "#f59e0b"},
    {"name": "profile_leila", "initials": "LB", "color1": "#fb923c", "color2": "#d97706"},
    {"name": "profile_kwame", "initials": "KO", "color1": "#fbbf24", "color2": "#fb923c"},
    {"name": "profile_zara", "initials": "ZO", "color1": "#f59e0b", "color2": "#d97706"},
    {"name": "profile_malik", "initials": "MH", "color1": "#fb923c", "color2": "#f59e0b"},
    {"name": "profile_fatima", "initials": "FD", "color1": "#fbbf24", "color2": "#f59e0b"},
    {"name": "profile_tendai", "initials": "TM", "color1": "#fb923c", "color2": "#d97706"},
    {"name": "profile_aisha", "initials": "AK", "color1": "#fbbf24", "color2": "#fb923c"},
    {"name": "profile_kofi", "initials": "KM", "color1": "#f59e0b", "color2": "#d97706"},
]

def hex_to_rgb(hex_color):
    """Convert hex color to RGB tuple"""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def create_gradient_circle(size, color1, color2):
    """Create a circular image with radial gradient"""
    img = Image.new('RGB', (size, size), color='white')
    draw = ImageDraw.Draw(img)
    
    # Create radial gradient effect
    center = size // 2
    max_radius = center
    
    for radius in range(max_radius, 0, -1):
        # Interpolate between colors
        ratio = radius / max_radius
        r1, g1, b1 = hex_to_rgb(color1)
        r2, g2, b2 = hex_to_rgb(color2)
        
        r = int(r1 * ratio + r2 * (1 - ratio))
        g = int(g1 * ratio + g2 * (1 - ratio))
        b = int(b1 * ratio + b2 * (1 - ratio))
        
        color = (r, g, b)
        draw.ellipse([center - radius, center - radius, 
                     center + radius, center + radius], fill=color)
    
    return img

def add_initials(img, initials, size):
    """Add initials text to the image"""
    draw = ImageDraw.Draw(img)
    
    # Try to use a system font, fallback to default
    try:
        font_size = size // 3
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
    except:
        font = ImageFont.load_default()
    
    # Get text bounding box
    bbox = draw.textbbox((0, 0), initials, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    # Center the text
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - bbox[1]
    
    # Draw text with shadow for depth
    shadow_offset = 2
    draw.text((x + shadow_offset, y + shadow_offset), initials, 
             fill=(0, 0, 0, 128), font=font)
    draw.text((x, y), initials, fill='white', font=font)
    
    return img

def create_profile_image(profile, size=400):
    """Create a complete profile image"""
    # Create gradient circle
    img = create_gradient_circle(size, profile['color1'], profile['color2'])
    
    # Add initials
    img = add_initials(img, profile['initials'], size)
    
    return img

def main():
    """Generate all profile images"""
    output_dir = "AGA/AGA/Assets.xcassets"
    
    for profile in profiles:
        # Create image
        img = create_profile_image(profile, size=400)
        
        # Save to assets
        output_path = f"{output_dir}/{profile['name']}.imageset/{profile['name']}.png"
        img.save(output_path, 'PNG')
        print(f"✅ Created {profile['name']}.png")
    
    print(f"\n🎉 Successfully created {len(profiles)} profile images!")
    print("\n📝 Next steps:")
    print("1. Open Xcode and verify the images appear in Assets.xcassets")
    print("2. Replace these placeholder images with real photos if desired")
    print("3. Update the User model to include profileImageName property")

if __name__ == "__main__":
    main()

