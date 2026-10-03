import re

with open("lib/data/database/app_database.dart", "r") as f:
    content = f.read()

# Change schemaVersion to 5
content = re.sub(r'int get schemaVersion => 4;', 'int get schemaVersion => 5;', content)

# Find onUpgrade block and add if (from < 5) migrator.createTable(appSettingsTable);
target = r"""          if \(from < 4\) \{
            await migrator\.addColumn\(trackedItems, trackedItems\.temporarySince\);
            await \(update\(trackedItems\)
                  \.\.where\(
                    \(row\) => row\.category\.equals\(ItemCategory\.temporary\.name\),
                  \)\)
                \.write\(
              TrackedItemsCompanion\(temporarySince: Value\(DateTime\.now\(\)\)\),
            \);
          \}"""

replacement = r"""          if (from < 4) {
            await migrator.addColumn(trackedItems, trackedItems.temporarySince);
            await (update(trackedItems)
                  ..where(
                    (row) => row.category.equals(ItemCategory.temporary.name),
                  ))
                .write(
              TrackedItemsCompanion(temporarySince: Value(DateTime.now())),
            );
          }
          if (from < 5) {
            await migrator.createTable(appSettingsTable);
          }"""

content = re.sub(target, replacement, content)

with open("lib/data/database/app_database.dart", "w") as f:
    f.write(content)
