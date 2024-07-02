#!/bin/basb
# A wrapper for running corb with minimum configuration
#
#

main() {
  local start=$(date +%s)
  local type="validate"
  local job=$1
  local date=$2
  if [ ! -d ./reports ]; then
    echo "Creating reports folder"
    mkdir -p ./reports
  fi
  local dataReport=./reports/corb-report-latest.txt
  touch $dataReport
  local javaReport=./reports/corb-output-latest.log
  II "" >$dataReport
  II "" >$javaReport

  if [ -z "$job" ]; then
    echo "No job provided. Exiting."
    exit 1
  fi

  echo "Storing corb log for job [$job] in [$javaReport]"
  echo "Storing corb report for job [$job] in [$dataReport]"

  # Split ML_HOST string into an array
  IFS=',' read -ra ML_HOSTS <<< "$ML_HOST"
  if [ ${#ML_HOSTS[@]} -eq 0 ]; then
    echo "No ML_HOST provided. Exiting."
    exit 1
  fi

  # Generate -DXCC-CONNECTION-URI variable
  connection_uri=""
  for host in "${ML_HOSTS[@]}"; do
    connection_uri+="${ML_XCC_PROTOCOL}://${ML_USER}:${ML_PASS}@${host}:${ML_PORT},"
  done
  connection_uri=${connection_uri%,} # remove the last comma

  # Ensure there are no invisible characters
  connection_uri=$(echo $connection_uri | tr -d '\r\n')

  echo "CI: $connection_uri"

  export cutoff_date="${date}T00:00:00Z"
  envsubst < src/purge.properties > src/purge.properties.tmp
  cat src/purge.properties.tmp
  corbOpts=(
    -server -cp .:$CORB_JAR:$XCC_JAR
    "-DXCC-CONNECTION-URI=$connection_uri"
    -DOPTIONS-FILE="src/purge.properties.tmp"
    -DEXPORT-FILE-NAME="$dataReport"
  )

  # Run corb job

  set -o xtrace
  java "${corbOpts[@]}" com.marklogic.developer.corb.Manager >$javaReport 2>&1
  set +o xtrace

  now=$(date +%s)

  echo " ----------------- " >>$javaReport
  echo "-> Corb job [$job] took [$(($(date +%s) - $start))] seconds"
  echo "-> Report [$dataReport]"

  # reduce space on disk
  mv $dataReport ./reports/corb-report-${job}-${now}.txt
  mv $javaReport ./reports/corb-output-${job}-${now}.log
  mv src/purge.properties.tmp ./reports/purge-${now}.properties
  gzip ./reports/*.txt
  gzip ./reports/*.log
}


II() { echo "$(date +%Y-%m-%dT%H:%M:%S%z): $@"; }

export CORB_JAR="./artefacts/corb.jar"
export XCC_JAR="./artefacts/xcc.jar"

if [ ! -f $CORB_JAR ];then
  echo "Please download corb2 and save in artefacts folder. See readme in same folder"
  exit 1
fi
if [ ! -f $XCC_JAR ];then
  echo "Please download xcc and save in artefacts folder. See readme in same folder"
  exit 1
fi

main purge "$1"
