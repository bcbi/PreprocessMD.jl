
using Test
@test true

using Reformat

using DataFrames

A = DataFrame(a=[1,2], b=['x','y'])
@test A == DataFrame(a=[1,2], b=['x','y'])

A = DataFrame(a=[1,2,1], b=['x','y','y'])
B = long_to_wide(A, :a, :b)
C = DataFrame(a=[1,2], x=[true,false], y=[true,true])
@test B == C

#=
A = DataFrame(x = [0,1,5,1,2,5,4,3,8,6,9,9,5,1,1,3], 
	y = ['a','b','c','a','a','a','c','d', 'a','b','c','a','a','a','c','d'],
	z = ['1','3','3','2','1','4','4','5', '4','3','3','2','2','4','3','1'],
)

US_coins = DataFrame(
	name = ["Penny","Nickel","Dime","Quarter"],
	value = [1, 5, 10, 25] .// 100,
	mass = [2.500, 5.000, 2.268, 5.67],
)
=#




