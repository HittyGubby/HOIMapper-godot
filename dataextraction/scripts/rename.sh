#!/bin/bash
#desc: renaming province and state name with ' - ' to '-'
for FILE in ./*; do
  if [[ "$FILE" == *' - '* ]]; then
    NEW_FILE="${FILE// - /-}"
    mv "$FILE" "$NEW_FILE"
    echo "Renamed: '$FILE' to '$NEW_FILE'"
  fi
done
