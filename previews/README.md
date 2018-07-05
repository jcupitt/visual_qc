# Render a set of preview images

These scripts will render a set of previews from the pipeline output. They
need Workbench 1.3 or later, and Workbench must have been built with support
for `-show-scene`.

# Regenerating the DoFs

Run with eg.:

```
$ ./find-affine.sh ~/vol/dhcp-derived-data/derived_02Jun2018/participants.tsv 
```

To make a set of DoFs in `dofs/`. These give an affine transform from each
scan to atlas space.

You'll need to copy the atlas in from somewhere, they are too big to include
in the repository.

# Regenerating the previews

Run with eg.:

```
$ ./previews.sh ~/vol/dhcp-derived-data/derived_02Jun2018/participants.tsv 
```

It renders all templates in `templates/` for all scans, rotating each scan
into atlas space by pasting the roll, pitch and yaw into the scene files.
Rotation is calculated with `extract_rotation_from_affine.py`.

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

You also need to mark the view transform for substitution. Search for
`m_viewingTransformation` and swap the scale line for this:

```xml
<Object Type="float" Name="m_scaling">@SCALE@</Object>
```

And swap the 16 numbers in the following `m_rotationMatrix` for 
`@ROT0@`, `@ROT1@`, etc.

```xml
<Element Index="0">@ROT0@</Element>
<Element Index="1">@ROT1@</Element>
<Element Index="2">@ROT2@</Element>
<Element Index="3">@ROT3@</Element>
<Element Index="4">@ROT4@</Element>
<Element Index="5">@ROT5@</Element>
<Element Index="6">@ROT6@</Element>
<Element Index="7">@ROT7@</Element>
<Element Index="8">@ROT8@</Element>
<Element Index="9">@ROT9@</Element>
<Element Index="10">@ROT10@</Element>
<Element Index="11">@ROT11@</Element>
<Element Index="12">@ROT12@</Element>
<Element Index="13">@ROT13@</Element>
<Element Index="14">@ROT14@</Element>
<Element Index="15">@ROT15@</Element>
```
