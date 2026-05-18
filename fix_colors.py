import os
import re

files_to_update = [
    r'd:\Coding\Aetheris Audio Player\lib\pages\home_page.dart',
    r'd:\Coding\Aetheris Audio Player\lib\pages\library_page.dart',
    r'd:\Coding\Aetheris Audio Player\lib\pages\search_page.dart'
]

replacements = [
    (r'AetherisColors\.textPrimary12', r'AetherisColors.textPrimary.withValues(alpha: 0.12)'),
    (r'AetherisColors\.textPrimary54', r'AetherisColors.textPrimary.withValues(alpha: 0.54)'),
    (r'AetherisColors\.textPrimary24', r'AetherisColors.textPrimary.withValues(alpha: 0.24)'),
    (r'const AetherisColors\.surfaceRaised', r'AetherisColors.surfaceRaised'),
    (r'const\s+AetherisColors\.surfaceRaised', r'AetherisColors.surfaceRaised'),
    (r'const\s+AetherisColors\.background', r'AetherisColors.background'),
]

for filepath in files_to_update:
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # also remove const from Divider if color uses withValues
        content = re.sub(r'const Divider\(color: AetherisColors\.textPrimary\.withValues', r'Divider(color: AetherisColors.textPrimary.withValues', content)
        content = re.sub(r'const Icon\((.*?)color: AetherisColors\.textPrimary\.withValues', r'Icon(\1color: AetherisColors.textPrimary.withValues', content)
        content = re.sub(r'const Text\((.*?)color: AetherisColors\.textPrimary\.withValues', r'Text(\1color: AetherisColors.textPrimary.withValues', content)
        content = re.sub(r'const TextStyle\((.*?)color: AetherisColors\.textPrimary\.withValues', r'TextStyle(\1color: AetherisColors.textPrimary.withValues', content)

        for old, new in replacements:
            content = re.sub(old, new, content)
            
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
