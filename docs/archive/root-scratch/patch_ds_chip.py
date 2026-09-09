import re

with open('packages/warp_prism_ui/lib/src/atoms/ds_chip.dart', 'r') as f:
    content = f.read()

# I want to wrap `AnimatedContainer(...)` with `SizedBox(height: 48, child: Center(child: ...))`
# Note: we need to wrap the whole `Row` or `AnimatedContainer`?
# In the original code it is:
#         child: GestureDetector(
#           onTap: widget.enabled ? widget.onTap : null,
#           child: MouseRegion(
#             cursor: isInteractive
#                 ? SystemMouseCursors.click
#                 : SystemMouseCursors.basic,
#             child: AnimatedContainer(
# ...

content = content.replace('''        child: GestureDetector(
          onTap: widget.enabled ? widget.onTap : null,
          child: MouseRegion(
            cursor: isInteractive
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: AnimatedContainer(''', '''        child: GestureDetector(
          onTap: widget.enabled ? widget.onTap : null,
          child: MouseRegion(
            cursor: isInteractive
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: SizedBox(
              height: 48,
              child: Center(
                child: AnimatedContainer(''')

# Then we need to add two closing brackets for Center and SizedBox at the end of AnimatedContainer
content = content.replace('''                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );''', '''                  ],
                ],
              ),
            ),
              ),
            ),
          ),
        ),
      ),
    );''')

with open('packages/warp_prism_ui/lib/src/atoms/ds_chip.dart', 'w') as f:
    f.write(content)
