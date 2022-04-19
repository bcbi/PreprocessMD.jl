
using Test
@test true

#using Reformat

using DataFrames

A = DataFrame(a=[1,2], b=['x','y'])
@test A == DataFrame(a=[1,2], b=['x','y'])




