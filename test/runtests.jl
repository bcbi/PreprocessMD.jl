
using Test
@test true

using PreprocessMD

using DataFrames

@testset verbose = true "long_to_wide()" begin

	@testset verbose = true "Intended exceptions" begin
		@testset "MethodError" begin
			for x in [12, 1.0, "", x -> x]
				@test_throws MethodError long_to_wide(x)
			end
		end
		@testset "DomainError" begin
			for x in [DataFrame(), DataFrame(x = [0,1,2,3])]
				@test_throws DomainError long_to_wide(x)
			end
		end
	end
	@testset verbose = true "Simple examples" begin
		A = DataFrame(a=[1,2], b=['x','y'])
		@test A == DataFrame(a=[1,2], b=['x','y'])

		A = DataFrame(a=[1,2,1], b=['x','y','y'])
		B = long_to_wide(A, :a, :b)
		C = DataFrame(a=[1,2], x=[true,false], y=[true,true])
		@test B == C

		B = long_to_wide(A, :a)
		@test B == C

		B = long_to_wide(A)
		@test B == C

		B = long_to_wide(A, "a", "b")
		@test B == C
	end
end

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

@testset verbose = true "get_data()" begin
	@testset verbose = true "Open files" begin
		df = get_data("DXCCSR_v2022-1.CSV")
		@test true
	end
end


























































