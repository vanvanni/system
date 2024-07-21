#!/bin/bash
# Use/Env - Make use of .env files on shell scripts

function env() {
  if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs) &> /dev/null
  fi

  local vars="$1"
  local missing_vars=()
  IFS=', ' read -r -a vars_array <<< "$vars"
  for var in "${vars_array[@]}"; do
    if [ -z "${!var}" ]; then
      missing_vars+=("$var")
    fi
  done

  if [ ${#missing_vars[@]} -ne 0 ]; then
    write_red "Environment::missing(${missing_vars[*]})"
    exit 1
  else
    write_gre "Environment::loaded"
  fi
}
