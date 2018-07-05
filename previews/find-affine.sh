#!/bin/bash

participants_tsv=


libpipe_usage() {
  echo "usage: $dollar_zero [OPTIONS] /path/to/participants.tsv"
  echo "generate a set of affine DoFs in dofs/*.dof"
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
model=Affine
out=dofs

run mkdir -p $out

# make sane_participants.tsv
sanity_participants "$derivatives_dir" "$participants_tsv" \
  "$data_dir/sane_participants.tsv"

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

  base="$derivatives_dir/sub-${subject}/ses-${session}/anat"
  t2="$base/sub-${subject}_ses-${session}_T2w.nii.gz"

  # find nearest in atlas
  age=$(printf "%.0f\n" "$age")
  while [ ! -f atlas/templates/t2w/t$age.00.nii.gz ]; do
    if [ $age -gt 40 ]; then
      age=$((age - 1))
    else
      age=$((age + 1))
    fi
  done

  # register to an atlas
  dof="$out/sub-${subject}_ses-${session}_age-${age}.dof"
  if ! [ -f "$dof" ]; then 
    run mirtk register \
      -image atlas/templates/t2w/t$age.00.nii.gz \
      -image $t2 \
      -dofout "$dof" \
      -model $model \
      -v 0 
  fi

done < "$data_dir/sane_participants.tsv"
