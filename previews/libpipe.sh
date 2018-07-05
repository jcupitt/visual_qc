# some useful utility things for writing image processing pipelines in bash

# set -x
# set -e

dollar_zero="$0"
ignore_errors=no
log_output=/dev/stdout
set_log=no
err_output=/dev/stderr
set_err=no
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

# detailed message to log
log() {
  echo "$*" >> "$log_output"

  if [ x"$verbose" = x"yes" ]; then
    echo "$*" 
  fi
}

# short informational message to user
info() {
  if [ x"$quiet" = x"no" ]; then
    echo "$*" 

    # if log output is not to the display
    if [ x"$set_log" = x"yes" ]; then
      echo "$*" >> "$log_output"
    fi
  fi
}

run() {
  log "$@"
  "$@" >> "$log_output" 2>> "$err_output"
  if ! [ $? -eq 0 ]; then
    err "failed, see $log_output and $err_output for details"
  fi
}

_usage() {
  libpipe_usage
  # dont use info -- we always want to display this, even in quiet mode
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
  _usage
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
      set_log=yes
      ;;

    -e|--err)  
      shift
      err_output="$1"
      set_err=yes
      ;;

    -q|--quiet)  
      quiet=yes 
      ;;

    -v|--verbose)  
      verbose=yes 
      ;;

    -h|--help)  
      _usage
      exit 0 
      ;;

    -*) 
      err "unrecognized option $1" 
      ;;

    *) 
      libpipe_arg $1
      ;;

  esac

  shift
done

# make a new participants file, but sanity checked
sanity_participants() {
  _derivatives_dir="$1"
  _participants_tsv="$2"
  _sane_participants_tsv="$3"

  info "scanning participants.tsv ..."

  echo -e "participant_id\tsession_id\tgender\tbirth_ga" \
    >"$_sane_participants_tsv"

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

    if ! [ -d "$_derivatives_dir/sub-$subject" ]; then
      # log rather than err since we expect participants to contain some errors
      log "$subject not found $_derivatives_dir/sub-$subject"
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

    for session_path in $_derivatives_dir/sub-$subject/ses-*; do
      ses_session=$(basename $session_path)
      session=${ses_session#ses-}
      base="$derivatives_dir/sub-${subject}/ses-${session}"

      if ! [ -d "$base" ]; then
        log "$subject not found $base"
        continue
      fi


      # must at least have T2
      if ! [ -f "$base/anat/sub-${subject}_ses-${session}_T2w.nii.gz" ]; then
        log "$subject not found sub-${subject}_ses-${session}_T2w.nii.gz"
        continue
      fi

      echo -e "${subject}\t${session}\t${gender}\t${age}" \
        >>"$_sane_participants_tsv"

    done

  done < "$_participants_tsv"
}
