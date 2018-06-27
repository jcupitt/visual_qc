#!/bin/bash

# set -x
# set -e

# we must have workbench 1.3+, so we can't use the one from the pipeline
workbench=$HOME/GIT/workbench
wb_command=$workbench/build/CommandLine/wb_command

dollar_zero="$0"
participants_tsv=
ignore_errors=no
log_output=
err_output=
quiet=no
verbose=no

err() {
  echo "$*" >> "$err_output"

  if [ x"$verbose" = x"yes" ]; then
    echo "$*" 
  fi

  if [ x"$ignore_errors" = x"no" ]; then
    exit 1
  fi
}

log() {
  echo "$*" >> "$log_output"

  if [ x"$verbose" = x"yes" ]; then
    echo "$*" 
  fi
}

info() {
  if [ x"$quiet" = x"no" ]; then
    echo "$*" 
  fi
}

run() {
  log "$@"
  "$@" >> "$log_output" 2>> "$err_output"
  if ! [ $? -eq 0 ]; then
    err "failed, see $log_output and $err_output for details"
  fi
}

usage() {
  # dont use info -- we always want to display this
  echo "usage: $dollar_zero [OPTIONS] /path/to/participants.tsv"
  echo "generate a set of surface previews in /path/to/reports/thumbnails/X.png"
  echo ""
  echo "options:"
  echo "  -i | --ignore     ignore errors"
  echo "  -l | --log FILE   log output to FILE"
  echo "  -e | --err FILE   log errors to FILE"
  echo "  -q | --quiet      hide info output"
  echo "  -v | --verbose    show all output"
  echo "  -h | --help       show this message"
}

if [ $# -lt 1 ]; then
  usage
  exit 0
fi

while [ $# -gt 0 ]; do
  case "$1" in
    -i|--ignore)  
      ignore_errors=yes
      ;;

    -l|--log)  
      shift
      log_output="$1"
      ;;

    -e|--err)  
      shift
      err_output="$1"
      ;;

    -q|--quiet)  
      quiet=yes 
      ;;

    -v|--verbose)  
      verbose=yes 
      ;;

    -h|--help)  
      usage
      exit 0 
      ;;

    -*) 
      err "unrecognized option $1" 
      ;;

    *) 
      if [ x$participants_tsv != x"" ]; then
        err "participants set twice"
      fi
      participants_tsv=$(realpath $1)
      ;;

  esac

  shift
done

data_dir=$(dirname "$participants_tsv")
derivatives_dir="$data_dir/derivatives"
reports_dir="$data_dir/reports"
work_dir="$reports_dir/workdir"
thumbnails_dir="$reports_dir/thumbnails"

if [ x$log_output = x"" ]; then
  log_output="$thumbnails_dir/thumbnails.log"
fi

if [ x$err_output = x"" ]; then
  err_output="$thumbnails_dir/thumbnails.err"
fi

log "$dollar_zero - generating surface previews"
log ""
log "settings:"
log "  participants.tsv   $participants_tsv"
log "  data_dir           $data_dir"
log "  derivatives dir    $derivatives_dir"
log "  reports_dir        $reports_dir"
log "  work_dir           $work_dir"
log "  log_output         $log_output"
log "  err_output         $err_output"
log "  ignore_errors      $ignore_errors"
log "  quiet              $quiet"
log ""

if ! [ -f "$participants_tsv" ]; then
  err "$participants_tsv not found"
fi

if ! [ -d "$derivatives_dir" ]; then
  err "$derivatives_dir not found"
fi

run mkdir -p "$reports_dir"
run mkdir -p "$work_dir"
run mkdir -p "$thumbnails_dir"

# sanity-check participants.tsv

sane_participants_tsv="$data_dir/sane_participants.tsv"
echo -e "participant_id\tsession_id\tgender\tbirth_ga" \
  >"$sane_participants_tsv"

# associative array of participant ids
declare -A subject_table

while IFS='' read -r line || [[ -n "$line" ]]; do
  columns=($line)
  subject=${columns[0]}
  gender=${columns[1]}
  age=${columns[2]}

  # header line?
  if [ x"$subject" = x"participant_id" ]; then
    continue
  fi

  if [ x"${subject_table[$subject]}" != x"" ]; then
    log "$subject duplicated"
    continue
  fi
  subject_table[$subject]=present

  if ! [ -d "$derivatives_dir/sub-$subject" ]; then
    # log rather than err since we expect participants to contain some errors
    log "$subject not found $derivatives_dir/sub-$subject"
    continue
  fi

  if [ x"$gender" != x"Male" ] && [ x"$gender" != x"Female" ]; then
    log "$subject bad gender $gender"
    continue
  fi

  if ! [[ $age =~ ^[0-9]+\.[0-9]+$ ]]; then
    log "$subject bad age $age"
    continue
  fi

  for session_path in $derivatives_dir/sub-$subject/ses-*; do
    ses_session=$(basename $session_path)
    session=${ses_session#ses-}

    if ! [ -d "$derivatives_dir/sub-$subject/ses-$session" ]; then
      log "$subject not found $derivatives_dir/sub-$subject/ses-$session"
      continue
    fi

    echo -e "${subject}\t${session}\t${gender}\t${age}" \
      >>"$sane_participants_tsv"

  done

done < "$participants_tsv"

# render scenes

patch_scene() {
  template_scene="$1"
  new_scene="$2"
  subject=$3
  session=$4

  cat >"$work_dir/x.sed" <<EOF
s/@SUB-SUBJECT@/sub-${subject}/g
s/@SES-SESSION@/ses-${session}/g
s/@SUBJECT-SESSION@/${subject}-${session}/g
s/@DERIVATIVES_DIR@/${derivatives_dir//\//\\/}/g
EOF

  sed -f "$work_dir/x.sed" "$template_scene" >"$new_scene"
}

while IFS='' read -r line || [[ -n "$line" ]]; do
  columns=($line)
  subject=${columns[0]}
  session=${columns[1]}
  gender=${columns[2]}
  age=${columns[3]}

  # header line?
  if [ x"$subject" = x"participant_id" ]; then
    continue
  fi

  info "processing $subject ..."

  for template in templates/*; do
    template_name=$(basename "$template")
    template_name=${template_name%.template}

    png_file=sub-${subject}_ses-${session}-${template_name}.png
    scene_file=sub-${subject}_ses-${session}-${template_name}.scene
    png_path="$thumbnails_dir/$png_file"
    scene_path="$thumbnails_dir/$scene_file"

    if ! [ -f $png_path ]; then 
      patch_scene "$template" "$scene_path" $subject $session

      run "$wb_command" -logging SEVERE -show-scene \
        "$scene_path" 1 "$png_path" 640 480
    fi
  done
done < "$sane_participants_tsv"

