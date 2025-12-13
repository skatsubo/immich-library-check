#!/usr/bin/env bash

# Adjust variables below to match your Immich setup
datadir=${DATA_DIR:-/data}
# datadir=/usr/src/app/upload
immich_container=${IMMICH_CONTAINER:-immich_server}
postgres_container=${POSTGRES_CONTAINER:-immich_postgres}
postgres_user=${POSTGRES_USER:-postgres}
postgres_db=${POSTGRES_DB:-immich}

sql=$(cat <<'EOF'
select 'db' as source, 'asset' as type, "originalPath", "fileSizeInByte", "createdAt", "deletedAt", status, visibility, id
from asset
left join asset_exif on "assetId" = "id"
where not "isExternal"
EOF
)
find_cmd=$(cat <<EOF
{
find "$datadir/library"       -type f -not -iname ".immich" -not -iname "*.xmp" -exec stat -t -c "fs|library|%n|%s|%.19y" {} +
find "$datadir/upload"        -type f -not -iname ".immich" -not -iname "*.xmp" -exec stat -t -c "fs|upload|%n|%s|%.19y" {} +
find "$datadir/encoded-video" -type f -not -iname ".immich" -name "*-MP.mp4"    -exec stat -t -c "fs|encoded-video|%n|%s|%.19y" {} +
} | sort -k3,3 -t '|'
EOF
)
cmd=$(cat <<EOF
echo "source|type|path|size|ts|source|type|path|size|ts|del_ts|status|visibility|id"
join -j3 -t '|' -a1 -a2 -o 1.1,1.2,1.3,1.4,1.5,2.1,2.2,2.3,2.4,2.5,2.6,2.7,2.8,2.9 \
  <($find_cmd) \
  <(sort -k3,3 -t '|')
EOF
)
docker exec "$postgres_container" psql -U "$postgres_user" -d "$postgres_db" --tuples-only --no-align -c "$sql" \
  | docker exec -i "$immich_container" bash -c "$cmd" \
  | tr '|' $'\t' > library.tsv

# normal assets have both "fs" and "db" sources
normal='^fs.*'$'\t'db$'\t'
grep -v "$normal" library.tsv > library.mismatch.tsv

echo "Files written:
  library.tsv
  library.mismatch.tsv
Total assets/files:
$(wc -l <library.tsv)
Inconsistencies found:
$(wc -l <library.mismatch.tsv)"
