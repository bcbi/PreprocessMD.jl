
using Test
@test true

using PreprocessMD

using DataFrames
using CSV: File

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

@testset verbose = true "wide_to_long()" begin

	@testset verbose = true "Intended exceptions" begin
		@test true
	end

	@testset verbose = true "Simple examples" begin
		long = DataFrame(
		       name=["aaa","bbb","aaa","ccc","ccc","aaa","aaa","ccc","eee"],
		       val=['x',   'w',  'w',  'y',  'z',  'q',  'y',  'a',  'w'],
		       )

		wide = long_to_wide(long)
		new_long = wide_to_long(wide)
		@test new_long == long
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

df=DataFrame(name=["aaa","bbb","ccc","ddd"], x=[1,3,4,3], y=[0,1,1,0], z=[0,1,0,1])



=#

@testset verbose = true "get_data()" begin
	@testset verbose = true "Open files" begin
		# @test_skip
		# @test_broken
		file = joinpath(pkgdir(PreprocessMD), "test", "example.csv")
		df =File(file, header = 1) |> DataFrame
		@test true
	end
end


























































