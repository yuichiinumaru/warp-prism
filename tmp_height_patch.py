import re

path = 'packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart'
with open(path, 'r') as f:
    text = f.read()

# Replace ANY numeric height between 200 and 400 that ends with a comma
text = re.sub(r'height:\s*(2[0-9][0-9]|3[0-9][0-9]),', r'height: 800,', text)

with open(path, 'w') as f:
    f.write(text)
