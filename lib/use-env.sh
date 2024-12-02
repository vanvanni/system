#!/bin/bash
# Use/Env - Make use of .env files on shell scripts with YAML-style multiline support

function env() {
  if [ -f .env ]; then
    local current_var=""
    local current_value=""
    local in_multiline=false
    local quote_style=""
    local first_line=true

    while IFS= read -r line || [ -n "$line" ]; do
      # Skip empty lines and comments
      if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
        continue
      fi

      # Handle the start of a new variable assignment
      if ! $in_multiline && [[ "$line" =~ ^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]*= ]]; then
        # If we have a previous variable stored, export it now
        if [[ -n "$current_var" ]]; then
          printf -v "$current_var" '%s' "$current_value"
          export "$current_var"
        fi

        # Start collecting new variable
        current_var="${line%%=*}"
        current_var="${current_var%"${current_var##*[![:space:]]}"}" # trim trailing spaces
        current_value="${line#*=}"

        # Remove leading space after equals sign
        current_value="${current_value#"${current_value%%[![:space:]]*}"}"

        # Check for triple quote start
        if [[ "$current_value" =~ ^[[:space:]]*\"\"\" ]]; then
          in_multiline=true
          quote_style='"""'
          first_line=true
          # Remove the opening quotes
          current_value="${current_value#*\"\"\"}"
          # If there's content after the quotes on the same line, keep it
          if [[ -n "${current_value//[[:space:]]/}" ]]; then
            current_value="${current_value}"
            first_line=false
          else
            current_value=""
          fi
        fi
      elif $in_multiline; then
        # Check for the closing triple quotes
        if [[ "$line" =~ \"\"\" ]]; then
          in_multiline=false
          # Only take the part before the quotes
          line="${line%%\"\"\"*}"
          if [[ -n "$line" ]]; then
            if $first_line; then
              current_value="$line"
              first_line=false
            else
              current_value+=$'\n'"$line"
            fi
          fi
        else
          # Add the line with a newline
          if $first_line; then
            current_value="$line"
            first_line=false
          else
            current_value+=$'\n'"$line"
          fi
        fi
      fi
    done <.env

    # Export the last variable if there is one
    if [[ -n "$current_var" ]]; then
      printf -v "$current_var" '%s' "$current_value"
      export "$current_var"
    fi
  fi

  local vars="$1"
  local missing_vars=()
  IFS=', ' read -r -a vars_array <<<"$vars"
  for var in "${vars_array[@]}"; do
    if [ -z "${!var}" ]; then
      missing_vars+=("$var")
    fi
  done

  if [ ${#missing_vars[@]} -ne 0 ]; then
    write_red "Env::missing(${missing_vars[*]})"
    exit 1
  else
    write_gre "Env::loaded"
  fi
}
