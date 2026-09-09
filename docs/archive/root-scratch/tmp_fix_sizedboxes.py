import re

path = 'packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart'
with open(path, 'r') as f:
    text = f.read()

# Match `SizedBox(height: 123, child:` or `const SizedBox(height: 123, child:`
text = re.sub(r'const SizedBox\(\s*height:\s*([0-9]+),\s*child:', r'Container(constraints: const BoxConstraints(minHeight: \1), child:', text)
text = re.sub(r'SizedBox\(\s*height:\s*([0-9]+),\s*child:', r'Container(constraints: const BoxConstraints(minHeight: \1), child:', text)

# Also horizontal: `SizedBox(width: 123, child:`
text = re.sub(r'const SizedBox\(\s*width:\s*([0-9]+),\s*child:', r'Container(constraints: const BoxConstraints(minWidth: \1), child:', text)
text = re.sub(r'SizedBox\(\s*width:\s*([0-9]+),\s*child:', r'Container(constraints: const BoxConstraints(minWidth: \1), child:', text)

with open(path, 'w') as f:
    f.write(text)
