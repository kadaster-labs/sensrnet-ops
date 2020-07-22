#!/bin/bash

# Alerts - generate alerts.yaml file based on all yaml-files in 'alerts' directory and (re)place it in .base/prometheus/:
cat <<-EOF > ../base/prometheus/alerts.yaml
"groups":
EOF

for f in ./alerts/*.yaml
do
	./scripts/wrap-file.sh $f | sed '/"groups":/d' >> ../base/prometheus/alerts.yaml	
done

# Rules - generate rules.yaml filebased on all yaml-files in 'rules' directory and (re)place it in .base/prometheus/:
cat <<-EOF > ../base/prometheus/rules.yaml
"groups":
EOF

for f in ./rules/*.yaml
do
    ./scripts/wrap-file.sh $f | sed '/"groups":/d' >> ../base/prometheus/rules.yaml
done

# Dashboards - compress all dashboards ./generated-manifests/dashboards and copy to dashboard-directory ./base/grafana/dashboards 
for f in ./dashboards/*.json
do
#        echo   $(basename $f)
#        echo $f
        cat $f | gojsontoyaml -yamltojson > ../base/grafana/dashboards/$(basename $f)
done