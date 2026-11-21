regions        := "eu-central-1 eu-west-1"
primary_region := "eu-central-1"
codename       := "trixie"
php_versions   := "8.3 8.5"
ami_prefix     := "codemonauts"
keep_newest    := "3"
min_age_days   := "14"

# Show the available recipes
default:
    @just --list

# Install the required packer plugins
init:
    packer init baseimage.pkr.hcl
    packer init webserver.pkr.hcl

# Lint YAML, ansible and the ASG set catalogue
lint:
    yamllint .
    ansible-lint
    jq empty asg-sets.json

# Validate both packer templates, for one or all php versions (amd64 | arm64)
validate arch cn=codename php='': (_check-arch arch) init
    #!/usr/bin/env bash
    set -euo pipefail
    versions='{{ php }}'
    [ -n "$versions" ] || versions='{{ php_versions }}'
    packer validate -var arch={{ arch }} -var codename='{{ cn }}' baseimage.pkr.hcl
    for v in $versions; do
        packer validate -var arch={{ arch }} -var codename='{{ cn }}' -var php_version="$v" webserver.pkr.hcl
    done

# Run all checks (amd64 | arm64)
test arch cn=codename php='': (_check-arch arch) lint (validate arch cn php)

# Run all checks for both architectures
test-all: lint (validate "amd64") (validate "arm64")

# Build the base AMI and one webserver AMI per php version (asks for the architecture)
build arch='' cn=codename php='':
    #!/usr/bin/env bash
    set -euo pipefail
    arch='{{ arch }}'
    if [ -z "$arch" ]; then
        if [ ! -t 0 ]; then
            echo "error: no architecture given and no terminal to ask on" >&2
            echo "usage: just build (amd64 | arm64)" >&2
            exit 1
        fi
        PS3='Select architecture: '
        select choice in amd64 arm64; do
            [ -n "${choice:-}" ] && arch="$choice" && break
        done
        # Ctrl-D leaves the loop unset
        [ -n "$arch" ] || { echo "error: aborted" >&2; exit 1; }
    fi
    just test "$arch" '{{ cn }}' '{{ php }}'
    versions='{{ php }}'
    [ -n "$versions" ] || versions='{{ php_versions }}'
    # the webserver images build on the base image, so order matters
    packer build -var arch="$arch" -var codename='{{ cn }}' baseimage.pkr.hcl
    for v in $versions; do
        packer build -var arch="$arch" -var codename='{{ cn }}' -var php_version="$v" webserver.pkr.hcl
    done
    stale=$(just _stale-amis | awk -F'\t' '$1 == "stale"' | grep -c . || true)
    if [ "$stale" -gt 0 ]; then
        echo
        echo "$stale amis can be cleaned up, run: just clean-amis"
    fi

# Build the AMIs for both architectures
build-all: (build "amd64") (build "arm64")

# Build only the webserver AMIs on the existing base image (amd64 | arm64)
build-webserver arch cn=codename php='': (_check-arch arch) (validate arch cn php)
    #!/usr/bin/env bash
    set -euo pipefail
    versions='{{ php }}'
    [ -n "$versions" ] || versions='{{ php_versions }}'
    for v in $versions; do
        packer build -var arch={{ arch }} -var codename='{{ cn }}' -var php_version="$v" webserver.pkr.hcl
    done

# List AMIs beyond the newest 3 of their family
stale-amis:
    #!/usr/bin/env bash
    set -euo pipefail
    all=$(just _stale-amis)
    printf '%s\n' "$all" | awk -F'\t' '
        $1 != "stale" { next }
        $2 != r { r = $2; printf "==> %s\n", r }
        { printf "    %-56s %-22s %s days\n", $4, $3, $5 }'
    legacy=$(printf '%s\n' "$all" | awk -F'\t' '$1 == "legacy"')
    if [ -n "$legacy" ]; then
        echo "==> legacy names, not deleted by clean-amis"
        printf '%s\n' "$legacy" | awk -F'\t' '
            { printf "    %-56s %-22s %s days  (%s)\n", $4, $3, $5, $2 }'
        echo "    delete these by hand, including their snapshots"
    fi

# Delete unused AMIs and their snapshots after confirmation
clean-amis:
    #!/usr/bin/env bash
    set -euo pipefail
    stale=$(just _stale-amis | awk -F'\t' '$1 == "stale"')
    if [ -z "$stale" ]; then
        echo "nothing to clean"
        exit 0
    fi
    just stale-amis
    count=$(printf '%s\n' "$stale" | wc -l)
    if [ ! -t 0 ]; then
        echo "error: refusing to delete without a terminal to confirm on" >&2
        exit 1
    fi
    read -r -p "delete $count AMIs and their snapshots? [y/N] " answer
    case "$answer" in
        y|Y) ;;
        *) echo "aborted"; exit 1 ;;
    esac
    while IFS=$'\t' read -r _ region id name _; do
        echo "==> $region $id $name"
        snapshots=$(aws ec2 describe-images --region "$region" --image-ids "$id" \
            --query 'Images[].BlockDeviceMappings[].Ebs.SnapshotId' --output text)
        aws ec2 deregister-image --region "$region" --image-id "$id"
        for snapshot in $snapshots; do
            [ "$snapshot" = "None" ] && continue
            echo "    snapshot $snapshot"
            aws ec2 delete-snapshot --region "$region" --snapshot-id "$snapshot"
        done
    done <<< "$stale"

# Print unused AMIs as: kind<TAB>region<TAB>id<TAB>name<TAB>age_days
# kind is "stale" (safe to delete) or "legacy" (old naming, listed only)
_stale-amis:
    #!/usr/bin/env bash
    set -euo pipefail
    now=$(date +%s)
    # names produced by our packer builds, and the older naming we no longer use
    strict='^{{ ami_prefix }}-(amd64|arm64)-.+_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]$'
    loose='^{{ ami_prefix }}[-_].+_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]-[0-9][0-9]$'

    # id<TAB>name<TAB>created for one region, newest first; $2 selects strict or legacy
    images() {
        aws ec2 describe-images --region "$1" --owners self \
            --filters "Name=name,Values={{ ami_prefix }}-*,{{ ami_prefix }}_*" \
            --query 'Images[].[ImageId,Name,CreationDate]' --output text \
        | awk -F'\t' -v st="$strict" -v lo="$loose" -v want="$2" '
            want == "strict" { if ($2 ~ st) print; next }
            { if ($2 ~ lo && $2 !~ st) print }' \
        | sort -t$'\t' -k3,3r
    }

    # image ids referenced by any launch template version in the primary region
    in_use=$(
        for lt in $(aws ec2 describe-launch-templates --region {{ primary_region }} \
                --query 'LaunchTemplates[].LaunchTemplateId' --output text); do
            aws ec2 describe-launch-template-versions --region {{ primary_region }} \
                --launch-template-id "$lt" \
                --query 'LaunchTemplateVersions[].LaunchTemplateData.ImageId' \
                --output text
        done | tr '\t' '\n' | awk 'NF && $0 != "None"' | sort -u
    )

    # the primary region decides what to keep; other regions mirror it by name
    # keep the newest per family, not per region: this repo holds many
    # families at once (base/webserver x arch x codename x php)
    keep_names=$(
        images {{ primary_region }} strict \
        | awk -F'\t' -v keep={{ keep_newest }} -v inuse="$in_use" '
            BEGIN { split(inuse, u, "\n"); for (i in u) used[u[i]] = 1 }
            {
                family = $2; sub(/_[^_]*$/, "", family)
                n[family]++
                if (n[family] <= keep || ($1 in used)) print $2
            }'
    )
    legacy_keep=$(
        images {{ primary_region }} legacy \
        | awk -F'\t' -v inuse="$in_use" '
            BEGIN { split(inuse, u, "\n"); for (i in u) used[u[i]] = 1 }
            $1 in used { print $2 }'
    )

    for region in {{ regions }}; do
        for kind in strict legacy; do
            [ "$kind" = strict ] && keep="$keep_names" || keep="$legacy_keep"
            [ "$kind" = strict ] && label=stale || label=legacy
            images "$region" "$kind" \
            | awk -F'\t' -v now="$now" -v minage={{ min_age_days }} -v region="$region" \
                  -v kn="$keep" -v label="$label" '
                BEGIN { split(kn, k, "\n"); for (i in k) if (k[i] != "") keep[k[i]] = 1 }
                $2 in keep { next }
                {
                    cmd = "date -d \"" $3 "\" +%s"; cmd | getline ts; close(cmd)
                    age = int((now - ts) / 86400)
                    if (age < minage) next
                    printf "%s\t%s\t%s\t%s\t%s\n", label, region, $1, $2, age
                }' | sort -t$'\t' -k5,5nr
        done
    done

# Fail on unsupported architectures
_check-arch arch:
    @if [ "{{ arch }}" != "amd64" ] && [ "{{ arch }}" != "arm64" ]; then \
        echo "error: unknown architecture '{{ arch }}' (expected amd64 or arm64)" >&2; \
        exit 1; \
    fi
