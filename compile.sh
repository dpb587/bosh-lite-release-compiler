#!/bin/sh -eu

bosh -n target "$( cat $target_file )" || break

bosh login admin admin

uuid=$( bosh status --uuid )

tar -xzf release/*.tgz ./release.MF
release_name=$( grep '^name:' release.MF | awk '{print $2}' | tr -d "\"'" )
release_version=$( grep '^version:' release.MF | awk '{print $2}' | tr -d "\"'" )

tar -xzf stemcell/*.tgz stemcell.MF
stemcell_name=$( grep '^name:' stemcell.MF | awk '{print $2}' | tr -d "\"'" )
stemcell_os=$( grep '^operating_system:' stemcell.MF | awk '{print $2}' | tr -d "\"'" )
stemcell_version=$( grep '^version:' stemcell.MF | awk '{print $2}' | tr -d "\"'" )

deployment_name="$release_name-$release_version-on-$stemcell_os-stemcell-$stemcell_version"

bosh upload stemcell --skip-if-exists stemcell/*.tgz
bosh upload release --skip-if-exists release/*.tgz

cat > deployment.yml <<EOF
name: "$deployment_name"
director_uuid: $uuid
releases:
  - name: "$release_name"
    version: "$release_version"
networks:
  - name: "default"
    type: "manual"
    subnets:
      - range: "10.244.1.0/24"
        gateway: "10.244.1.1"
resource_pools:
  - name: "default"
    network: "default"
    stemcell:
      name: "$stemcell_name"
      version: "$stemcell_version"
compilation:
  workers: $compilation_workers
  reuse_compilation_vms: true
  resource_pool: "default"
  network: "default"
update:
  canaries: 1
  max_in_flight: 10
  canary_watch_time: 1000-30000
  update_watch_time: 1000-30000
jobs: []
EOF

bosh deployment deployment.yml

bosh -n deploy

bosh export release "$release_name/$release_version" "$stemcell_os/$stemcell_version"

mv *.tgz compiled-release/$( echo *.tgz | sed "s/\.tgz$/-compiled-$( date -u +%Y%m%d%H%M%S ).tgz/" )
