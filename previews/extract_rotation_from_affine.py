#!/usr/bin/python3

# -*- coding: utf-8 -*-
"""
Extract the rotational component from an affine matrix and write in affine form.
"""

import numpy as np
from numpy.linalg import svd 
import argparse

# parse arguments
parser = argparse.ArgumentParser(
    description='''Extract the rotational component from an affine matrix and write in affine form''')
parser.add_argument('--affine', type=str, 
                    help='path to text file containing 4x4 affine matrix')
parser.add_argument('--outname', type=str, 
                    help='path to text file containing 4x4 affine matrix')
args = parser.parse_args()

# read in affine matrix from text file
A = np.loadtxt(args.affine)
# print('A \n {}'.format(A))
# decompose using SVD e.g. http://nghiaho.com/?page_id=671
U, S, V = svd(A[:3,:3])

# print(U.shape, np.diag(S).shape, V.shape)
# print('new A 1 \n {}'.format(np.dot(np.diag(S), V.T)))
# print('new A \n {}'.format(np.dot(U, np.dot(np.diag(S), V))))

# estimate rotation matrix
R = np.dot(U, V)

# print('R \n {}'.format(R))
# print('is rotation?', np.dot(R, R.transpose()))
# print('determinant', np.linalg.det(R))

# create new 4x4 affine from rotation matrix
# we need to invert R to get the transform to rotate by to get the brain
# upright again
new_affine = np.zeros((4, 4))
new_affine[:3, :3] = np.linalg.inv(R)
new_affine[3,3] = 1

# print(new_affine)

np.savetxt(args.outname, new_affine)
