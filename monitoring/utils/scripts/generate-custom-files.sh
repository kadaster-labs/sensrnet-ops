#!/bin/bash

# Dashboards - compress all dashboards ./generated-manifests/dashboards and copy to dashboard-directory ./base/grafana/dashboards 
for f in ./dashboards/*.json
do
#        echo   $(basename $f)
#        echo $f
        cat $f | gojsontoyaml -yamltojson > ../base/grafana/dashboards/$(basename $f)
done