import os
import re

lib_dir = r"C:\Users\prava\OneDrive\Desktop\bonding\frontend\lib"

import_statement = "import 'package:flutter/foundation.dart';\n"

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith(".dart"):
            filepath = os.path.join(root, file)
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()

            if "print(" in content:
                # Replace print( with debugPrint(
                # Use regex to match print as a function call, not part of another word
                new_content = re.sub(r'\bprint\(', 'debugPrint(', content)
                
                # Check if debugPrint is now in content and import is missing
                if "debugPrint(" in new_content and import_statement.strip() not in new_content:
                    # insert import after first line or other imports
                    lines = new_content.splitlines(True)
                    # Find a good place to insert (after first import or at top)
                    insert_idx = 0
                    for i, line in enumerate(lines):
                        if line.startswith("import "):
                            insert_idx = i + 1
                    
                    lines.insert(insert_idx, import_statement)
                    new_content = "".join(lines)

                with open(filepath, "w", encoding="utf-8") as f:
                    f.write(new_content)
                print(f"Updated {filepath}")
