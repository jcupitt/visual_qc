#!/bin/bash

# we must have workbench 1.3+, so we can't use the one from the pipeline
workbench=$HOME/GIT/workbench
wb_command=$workbench/build/CommandLine/wb_command

participants_tsv=

libpipe_usage() {
  echo "usage: $dollar_zero [OPTIONS] /path/to/participants.tsv"
  echo "generate a set of surface previews in /path/to/reports/thumbnails/X.png"
}

libpipe_arg() {
  if [ x$participants_tsv != x"" ]; then
    err "participants set twice"
  fi

  participants_tsv=$(realpath $1)
}

. libpipe.sh

data_dir=$(dirname "$participants_tsv")
derivatives_dir="$data_dir/derivatives"
reports_dir="$data_dir/reports"
work_dir="$reports_dir/workdir"
thumbnails_dir="$reports_dir/thumbnails"

if [ x$set_log = x"no" ]; then
  log_output="$thumbnails_dir/thumbnails.log"
fi

if [ x$set_err = x"no" ]; then
  err_output="$thumbnails_dir/thumbnails.err"
fi

info "$dollar_zero -- generate surface previews"
info ""
info "settings:"
info "  data_dir           $data_dir"
info "  participants.tsv   $participants_tsv"
info "  derivatives dir    $derivatives_dir"
info "  reports_dir        $reports_dir"
info "  work_dir           $work_dir"
info "  log_output         $log_output"
info "  err_output         $err_output"
info "  ignore_errors      $ignore_errors"
info "  quiet              $quiet"
info ""

if ! [ -f "$participants_tsv" ]; then
  err "$participants_tsv not found"
fi

if ! [ -d "$derivatives_dir" ]; then
  err "$derivatives_dir not found"
fi

run mkdir -p "$reports_dir"
run mkdir -p "$work_dir"
run mkdir -p "$thumbnails_dir"
run mkdir -p tmp

# make sane_participants.tsv
sanity_participants "$derivatives_dir" "$participants_tsv" \
  "tmp/sane_participants.tsv"

# render scenes

patch_scene() {
  local _template_scene="$1"
  local _new_scene="$2"
  local _subject=$3
  local _session=$4
  local -n _matrix=$5

  # we multiply the 3x3 part of the transform matrix by the default WB view
  # matrix
  #      0 -1  0
  #      0  0  1
  #     -1  0  0
  # use 0.9 instead of 1 to zoom out a bit ... otherwise, we can clip the 
  # edges of the brains
  cat >tmp/x.sed <<EOF
s/@SUB-SUBJECT@/sub-${_subject}/g
s/@SES-SESSION@/ses-${_session}/g
s/@SUBJECT-SESSION@/${_subject}-${_session}/g

s/@DERIVATIVES_DIR@/${_derivatives_dir//\//\\/}/g

s/@ROT0@/$(awk '{print  1 * $1}' <<< ${_matrix[4]})/g
s/@ROT1@/$(awk '{print -1 * $1}' <<< ${_matrix[5]})/g
s/@ROT2@/$(awk '{print  1 * $1}' <<< ${_matrix[6]})/g
s/@ROT3@/${_matrix[3]}/g

s/@ROT4@/$(awk '{print  1 * $1}' <<< ${_matrix[8]})/g
s/@ROT5@/$(awk '{print -1 * $1}' <<< ${_matrix[9]})/g
s/@ROT6@/$(awk '{print  1 * $1}' <<< ${_matrix[10]})/g
s/@ROT7@/${_matrix[7]}/g

s/@ROT8@/$(awk '{print -1 * $1}' <<< ${_matrix[0]})/g
s/@ROT9@/$(awk '{print  1 * $1}' <<< ${_matrix[1]})/g
s/@ROT10@/$(awk '{print -1 * $1}' <<< ${_matrix[2]})/g
s/@ROT11@/${_matrix[11]}/g

s/@ROT12@/${_matrix[12]}/g
s/@ROT13@/${_matrix[13]}/g
s/@ROT14@/${_matrix[14]}/g
s/@ROT15@/${_matrix[15]}/g

s/@SCALE@/0.9/g
EOF

  sed -f tmp/x.sed "$_template_scene" >"$_new_scene"
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

  # the corresponding DoF
  dof=$(ls dofs/sub-${subject}_ses-${session}_age-*.dof)
  if ! [ -f "$dof" ]; then 
    err "$dof not found"
    continue
  fi

  # aladin format is a simple 4x4 text matrix
  run mirtk convert-dof "$dof" tmp/x -output-format aladin
  run ./extract_rotation_from_affine.py --affine tmp/x --outname tmp/y
  matrix=($(cat tmp/y))

  for template in templates/*; do
    template_name=$(basename "$template")
    template_name=${template_name%.template}

    png_file=sub-${subject}_ses-${session}-${template_name}.png
    scene_file=sub-${subject}_ses-${session}-${template_name}.scene
    png_path="$thumbnails_dir/$png_file"
    scene_path="$thumbnails_dir/$scene_file"

    if ! [ -f $png_path ]; then 
      patch_scene "$template" "$scene_path" $subject $session matrix

      run "$wb_command" -logging SEVERE -show-scene \
        "$scene_path" 1 "$png_path" 640 480
    fi
  done

done < "tmp/sane_participants.tsv"

