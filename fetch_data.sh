# bin/bash

wget -O downloaded_data --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" https://gitlab.com/api/v4/projects/13601493/repository/archive?path=objects
tar -xf downloaded_data && rm downloaded_data
rm -rf ./data/editions && mkdir -p ./data/editions
rm -rf ./data/indices && mkdir -p ./data/indices
find -path "*objects/D_*.xml" -exec cp -prv '{}' './data/editions' ';'
rm -rf ./data-*

wget -O downloaded_data --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" https://gitlab.com/api/v4/projects/13601493/repository/archive?path=indices
tar -xf downloaded_data && rm downloaded_data
find -path "*indices/list*.xml" -exec cp -prv '{}' './data/indices' ';'
rm -rf ./data-*
find ./data/indices/ -type f -name "*.xml"  -print0 | xargs -0 sed -i -e 's@<person xml:id="person__@<person xml:id="pmb@g'
find ./data/indices/ -type f -name "*.xml"  -print0 | xargs -0 sed -i -e 's@<org xml:id="org__@<org xml:id="pmb@g'
find ./data/indices/ -type f -name "*.xml"  -print0 | xargs -0 sed -i -e 's@<place xml:id="place__@<place xml:id="pmb@g'
find ./data/indices/ -type f -name "*.xml"  -print0 | xargs -0 sed -i -e 's@<settlement key="@<settlement key="pmb@g'
find ./data/indices/ -type f -name "*.xml"  -print0 | xargs -0 sed -i -e 's@<orgName key="@<orgName key="pmb@g'
find ./data/indices/ -type f -name "*.xml"  -print0 | xargs -0 sed -i -e 's@<placeName key="place__@<placeName key="pmb@g'

python delete_invalid_files.py

find ./data/editions/ -type f -name "D_*.xml"  -print0 | xargs -0 sed -i 's@ref="#@ref="#pmb@g'

find ./data/editions/ -type f -name "D_*.xml"  -print0 | xargs -0 sed -i 's@ref="https://pmb.acdh.oeaw.ac.at/entity/@ref="#pmb@g'

add-attributes -g "./data/editions/*.xml" -b "https://id.acdh.oeaw.ac.at/legalkraus"
add-attributes -g "./data/indices/*.xml" -b "https://id.acdh.oeaw.ac.at/legalkraus"

denormalize-indices -f "./data/editions/D_*.xml" -i "./data/indices/*.xml" -m ".//*[@ref]/@ref" -x ".//tei:titleStmt/tei:title[1]/text()" -b pmb11988