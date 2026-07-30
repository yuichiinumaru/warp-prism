import re
import sys

def main():
    path = 'packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart'
    with open(path, 'r') as f:
        content = f.read()

    # Find SizedBox with specific numeric height and child
    # e.g. SizedBox(height: 260, child: ...)
    # or 
    # const SizedBox(
    #   height: 260,
    #   child: ...
    # )
    
    # We will just replace any number after `height:` if it is 100 or greater, with 800.
    # We must be careful not to match animation durations, but height: 100+ is rare except for layouts.
    def replacer(m):
        val = int(m.group(1))
        if val >= 50:
            return f"height: 800,"
        return m.group(0)

    # replace `height: 240,` etc.
    content = re.sub(r'height:\s*([0-9]+),', replacer, content)
    
    with open(path, 'w') as f:
        f.write(content)

if __name__ == '__main__':
    main()