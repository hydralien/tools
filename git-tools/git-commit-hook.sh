#!/bin/bash

retcode=0
for f in $( git diff --cached --name-status|awk '$1 != "R" { print $2 }' ); do
  echo "Veryfying $f..."
  filename=$(basename "$f")
  extension="${filename##*.}"
  if [ "$extension" = "pl" ] || [ "$extension" = "pm" ]; then
      perl -c $f
      lineretcode=$?
      if [ $lineretcode != 0 ]; then
          retcode=$lineretcode
      fi
  fi
done

if [ $retcode != 0 ]; then
    echo
    echo "Pre-commit validation failed. Please fix issues or run 'git commit --no-verify' if you're certain in skipping validation step."
    exit 1
fi

exit 0
