import re

with open('packages/warp_prism_ui/lib/src/atoms/ds_chip.dart', 'r') as f:
    content = f.read()

# I want to remove the strict `height: _height` on AnimatedContainer and use a visual layout that allows children to be 48
# Or better, just make the test check the outer hit target (which is now 48 because of SizedBox) and relax the inner remove icon check?
# Wait, DSTopbarAction has size 48x48 ?
