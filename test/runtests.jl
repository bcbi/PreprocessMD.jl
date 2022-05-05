
using CSV: File
using DataFrames
using PreprocessMD
using Test


@testset verbose = true "PreprocessMD" begin

@testset verbose = true "Sanity check" begin
	@test true
end

@testset verbose = true "add_label_column!()" begin

#testsets: bad options, default options


	long = DataFrame(
	       name=["aaa","bbb","aaa","ccc","ccc","aaa","aaa","ccc","eee"],
	       val=['x',   'w',  'w',  'y',  'z',  'q',  'y',  'a',  'w'],
	       )
	short = pivot(long)

	X = DataFrame(
		name=["bbb","ccc","fff"],
		r=["BBB","CCC","FFF"],
	)

	results = DataFrame(
		name=["aaa","bbb","ccc","eee"],
		x=[ true, false, false, false,],
		w=[ true,  true, false,  true,],
		y=[ true, false,  true, false,],
		z=[false, false,  true, false,],
		q=[ true, false, false, false,],
		a=[false, false,  true, false,],
		LABEL=[false,  true,  true, false,],
	)

	@testset verbose = true "Intended exceptions" begin
		@testset "DomainError" begin
				@test_throws DomainError add_label_column!(DataFrame(), DataFrame)
				@test_throws DomainError add_label_column!(
						DataFrame(x = []),
						DataFrame(x = []),
					)
			end
		end
		@testset verbose = true "ArgumentError" begin

			new = deepcopy(short)
			@test_throws ArgumentError add_label_column!(
				new, X, :name, :name, :w
			)

			new = deepcopy(short)
			@test_throws ArgumentError add_label_column!(
				new, X, :name, :NONEXISTENT
			)

			new = deepcopy(short)
			@test_throws ArgumentError add_label_column!(
				new, X, :NONEXISTENT
			)

		end
	end

	@testset verbose = true "Default options" begin
		new = deepcopy(short)
		add_label_column!(new, X, :name, :name)
		@test new == results

		new = deepcopy(short)
		add_label_column!(new, X, :name)
		@test new == results

		new = deepcopy(short)
		add_label_column!(new, X)
		@test new == results
	end


	@testset verbose = true "Simple examples" begin
		new = deepcopy(short)
		add_label_column!(new, X, :name, :name, :LABEL)
		@test new == results
	end

end

@testset verbose = true "pivot()" begin

	@testset verbose = true "Intended exceptions" begin
		@testset "MethodError" begin
			for x in [12, 1.0, "", x -> x]
				@test_throws MethodError pivot(x)
			end
		end

		@testset "DomainError" begin
			for x in [
				DataFrame(),
				DataFrame(x = [0,1,2,3]),
			]
				@test_throws DomainError pivot(x)
			end
		end
	end
	@testset verbose = true "Simple examples" begin
		A = DataFrame(a=[1,2,1], b=['x','y','y'])
		B = pivot(A, :a, :b)
		C = DataFrame(a=[1,2], x=[true,false], y=[true,true])
		@test B == C

		B = pivot(A, :a)
		@test B == C

		B = pivot(A)
		@test B == C

		B = pivot(A, "a", "b")
		@test B == C

	end

end

#=
@testset verbose = true "pivot!()" begin

	A = DataFrame(a=[1,2,1], b=['x','y','y'])
	pivot!(A, :a, :b)
	C = DataFrame(a=[1,2], x=[true,false], y=[true,true])
	@test A == C

end
=#

#=
@testset verbose = true "wide_to_long()" begin

	@testset verbose = true "Intended exceptions" begin
		@test true
	end

	@testset verbose = true "Simple examples" begin
		long = DataFrame(
		       name=["aaa","bbb","aaa","ccc","ccc","aaa","aaa","ccc","eee"],
		       val=['x',   'w',  'w',  'y',  'z',  'q',  'y',  'a',  'w'],
		       )
		sort!(long)
		display(long)

		wide = pivot(long)
		new_long = wide_to_long(wide)
		@test new_long == long
	end
end
=#

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

end

