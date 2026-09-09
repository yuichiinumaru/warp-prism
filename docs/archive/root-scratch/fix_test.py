import re

with open('apps/catalog/test/widget_test.dart', 'r') as f:
    content = f.read()

# Replace hardcoded sectionTitles with dsGallerySectionTitles
# We can just remove the hardcoded list and use dsGallerySectionTitles from the package.
content = re.sub(
    r'const sectionTitles = <String>\[.*?\];',
    '// sectionTitles removed in favor of dsGallerySectionTitles from registry.',
    content,
    flags=re.DOTALL
)

# Replace sectionTitles references
content = content.replace('sectionTitles', 'dsGallerySectionTitles')

# Replace DS* with Prism*
replacements = {
    'DSStateSurface': 'PrismStateSurface',
    'DSShimmer': 'PrismShimmer',
    'DSSkeletonTextLine': 'PrismSkeletonTextLine',
    'DSSkeletonCard': 'PrismSkeletonCard',
    'DSSkeletonTableRows': 'PrismSkeletonTableRows',
    'DSOperationalState': 'PrismOperationalState',
    'DSBadge': 'PrismBadge',
    'DSStatusDot': 'PrismStatusDot',
    'DSSidebar': 'PrismSidebar',
}

for ds, prism in replacements.items():
    content = content.replace(ds, prism)

with open('apps/catalog/test/widget_test.dart', 'w') as f:
    f.write(content)
