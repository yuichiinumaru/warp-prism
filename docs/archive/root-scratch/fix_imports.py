import os
import glob

files = glob.glob('apps/observatory/lib/**/*.dart', recursive=True) + glob.glob('apps/observatory/test/**/*.dart', recursive=True)

for file in files:
    if 'ds_compat.dart' in file or 'router.dart' in file:
        continue
    with open(file, 'r') as f:
        content = f.read()
    if 'package:warp_prism_ui/warp_prism_ui.dart' in content:
        new_content = content.replace("import 'package:warp_prism_ui/warp_prism_ui.dart';", "import 'package:warp_prism_observatory/src/ds_compat.dart';")
        with open(file, 'w') as f:
            f.write(new_content)
        print(f"Fixed {file}")
