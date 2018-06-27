# Render a set of preview images

This script will render a set of previews from the pipeline output. It must
have Workbench 1.3 or later, and Workbench must have been built with support
for `-show-scene`.

Run with eg.:

```
$ ./previews.sh ~/vol/dhcp-derived-data/derived_02Jun2018/participants.tsv 
```

It renders all templates in `templates/` for all scans.

# Making a template

Load one of the spec files into Workbench, perhaps:

```
~/vol/dhcp-derived-data/derived_02Jun2018/derivatives/sub-CC00186BN14/ses-61000/anat/Native/sub-CC00186BN14_ses-61000_wb.spec
```

Then edit to show the view you need, create a scene, and save it.

Load the scene into vim and make a series of edits to swap specific subject,
session and directory names out for generic `@MARKER@` fields. 

```
:%s/sub-CC00050XX01/@SUB-SUBJECT@/g
:%s/ses-7201/@SES-SESSION@/g
:%s/CC00050XX01-7201/@SUBJECT-SESSION@/g
:%s/\/home\/john\/pics\/dhcp\/sample_struct_pipeline/@DERIVATIVES_DIR@/g
:%s/..\/..\/..\/..\/pics\/dhcp\/sample_struct_pipeline/@DERIVATIVES_DIR@/g
:%s/derivatives\///g
```

That last one will need a couple of edits, check the file.
