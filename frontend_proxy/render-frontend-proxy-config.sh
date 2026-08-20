#!/bin/sh
set -eu

TEMPLATE_PATH="/etc/nginx/templates/default.conf.template"
RENDERED_PATH="/tmp/default.conf"
OUTPUT_PATH="/etc/nginx/conf.d/default.conf"
GROUPS_PATH="/tmp/proxy-auth-groups.conf"
CHUNKS_PATH="/tmp/proxy-auth-groups.chunks"

# Build set directives for X-Auth-Groups in <=3000 char chunks to avoid nginx parser limits.
if [ -n "${PROXY_AUTH_GROUPS:-}" ]; then
  : > "$GROUPS_PATH"
  : > "$CHUNKS_PATH"
  printf '%s' "$PROXY_AUTH_GROUPS" | fold -w 3000 > "$CHUNKS_PATH"

  i=0
  while IFS= read -r chunk || [ -n "$chunk" ]; do
    i=$((i + 1))
    escaped_chunk=$(printf '%s' "$chunk" | sed "s/\\\\/\\\\\\\\/g; s/'/\\\\'/g")
    printf "set \$proxy_auth_groups_%s '%s';\n" "$i" "$escaped_chunk" >> "$GROUPS_PATH"
  done < "$CHUNKS_PATH"

  concat=""
  idx=1
  while [ "$idx" -le "$i" ]; do
    concat="${concat}\$proxy_auth_groups_${idx}"
    idx=$((idx + 1))
  done
  printf "set \$proxy_auth_groups \"%s\";\n" "$concat" >> "$GROUPS_PATH"
else
  printf "set \$proxy_auth_groups \"\";\n" > "$GROUPS_PATH"
fi

envsubst "\$PROXY_UPSTREAM \$PROXY_AUTH_USER_ID \$PROXY_AUTH_TOKEN \$PROXY_AUTH_USERNAME \$PROXY_AUTH_SUBJECT \$PROXY_AUTH_ROLES" \
  < "$TEMPLATE_PATH" > "$RENDERED_PATH"

awk -v include_file="$GROUPS_PATH" '
  /__PROXY_AUTH_GROUPS_SET__/ {
    while ((getline line < include_file) > 0) {
      print "    " line;
    }
    close(include_file);
    next;
  }
  { print; }
' "$RENDERED_PATH" > "$OUTPUT_PATH"

nginx -t


