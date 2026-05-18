import os
import re

files_to_update = [
    r'd:\Coding\Aetheris Audio Player\lib\pages\home_page.dart',
    r'd:\Coding\Aetheris Audio Player\lib\pages\library_page.dart',
    r'd:\Coding\Aetheris Audio Player\lib\pages\search_page.dart'
]

replacements = [
    (r'Colors\.black', r'AetherisColors.background'),
    (r'Color\(0xFF1C1C1E\)', r'AetherisColors.surfaceRaised'),
    (r'Color\(0xFF2A2A2A\)', r'AetherisColors.surfaceRaised'),
    (r'Color\(0xFF282828\)', r'AetherisColors.surfaceRaised'),
    (r'Colors\.white', r'AetherisColors.textPrimary'),
    (r'Colors\.grey', r'AetherisColors.textSecondary'),
    (r'Colors\.white54', r'AetherisColors.textSecondary'),
    (r'Colors\.redAccent', r'AetherisColors.accent'),
]

for filepath in files_to_update:
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        if 'AetherisColors' not in content:
            content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n\nimport '../theme/aetheris_colors.dart';")
            
        for old, new in replacements:
            content = re.sub(old, new, content)
            
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
