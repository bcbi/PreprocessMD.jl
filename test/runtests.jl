using PreprocessMD

using CSV: File

using DataFrames: AbstractDataFrame
using DataFrames: DataFrame
using DataFrames: Index
using DataFrames: innerjoin
using DataFrames: Not
using DataFrames: select
using DataFrames: summary

using MLJ: @load
using MLJ: accuracy
using MLJ: evaluate
using MLJ: f1score
using MLJ: fit!
using MLJ: machine
using MLJ: mode
using MLJ: partition
using MLJ: predict
using MLJDecisionTreeInterface: DecisionTreeClassifier

using Test: @testset
using Test: @test
using Test: @test_throws
using Test: @test_skip

@testset "PreprocessMD" verbose = false begin
	# All external file downloads

	#url = "https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv"
	#DRUG = DataFrame(File.(download("$url/drug_exposure.csv")));
	#PERSON = DataFrame(File.(download("$url/person.csv")));
	#CONDITION = DataFrame(File.(download("$url/condition_occurrence.csv")));
	#DEATH = DataFrame(File.(download("$url/death.csv")));



	@testset "pivot()" verbose = false begin
		@testset "Intended exceptions" verbose = false begin
			@testset "ArgumentError" verbose = false begin
				A = DataFrame(; a=[1, 2, 1], b=['x', 'y', 'y'])
				B = pivot(A, :a, :b)
				C = DataFrame(; a=[1, 2], x=[true, false], y=[true, true])

				@test_throws ArgumentError B = pivot(A, :a, "b")

				@test_throws ArgumentError B = pivot(A, "a", :b)
			end
			@testset "DomainError" verbose = false begin
				for x in [DataFrame(), DataFrame(; x=[0, 1, 2, 3])]
					@test_throws DomainError pivot(x)
				end
			end
			@testset "MethodError" verbose = false begin
				for x in [12, 1.0, "", x -> x]
					#@test_throws MethodError pivot(x)
				end
			end
		end


		@testset "Simple examples" verbose = false begin
			A = DataFrame(; a=[1, 2, 1], b=['x', 'y', 'y'])
			B = pivot(A, :a, :b)
			C = DataFrame(; a=[1, 2], x=[true, false], y=[true, true])
			@test B == C

			B = pivot(A, :a)
			@test B == C

			B = pivot(A, "a")
			@test B == C

			B = pivot(A)
			@test B == C

			B = pivot(A, "a", "b")
			@test B == C

			B = pivot(A, :a, :b)
			@test B == C
		end
	end

	@testset "add_label_column!()" verbose = false begin
		@testset "Intended exceptions" verbose = false begin
			@testset "ArgumentError" verbose = false begin

				# DataFrame definitions
				long = DataFrame(
					name=["aaa", "bbb", "aaa", "ccc", "ccc", "aaa", "aaa", "ccc", "eee"],
					val=['x', 'w', 'w', 'y', 'z', 'q', 'y', 'a', 'w'],
				)
				short = pivot(long)
				X = DataFrame(; name=["bbb", "ccc", "fff"], r=["BBB", "CCC", "FFF"])
				results = DataFrame(;
					name=["aaa", "bbb", "ccc", "eee"],
					x=[true, false, false, false],
					w=[true, true, false, true],
					y=[true, false, true, false],
					z=[false, false, true, false],
					q=[true, false, false, false],
					a=[false, false, true, false],
					LABEL=[false, true, true, false],
				)
				new = deepcopy(short)
				# @test_throws UndefVarError add_label_column!(new, X, :NONEXISTENT)
			end
			@testset "DomainError" verbose = false begin
				@test_throws DomainError add_label_column!(DataFrame(), DataFrame(), :NONEXISTENT)
				@test_throws DomainError add_label_column!(DataFrame(), DataFrame(; x=[]), :NONEXISTENT)
				@test_throws DomainError add_label_column!(DataFrame(; x=[]), DataFrame(), :NONEXISTENT)
				@test_throws DomainError add_label_column!(DataFrame(; x=[]), DataFrame(; x=[]), :NONEXISTENT)
				@test_throws DomainError add_label_column!(DataFrame(; x=[1, 2]), DataFrame(; x=[]), :NONEXISTENT)
				@test_throws DomainError add_label_column!(DataFrame(; x=[]), DataFrame(; x=[1, 2]), :NONEXISTENT)
			end
			@testset "MethodError" verbose = false begin
				y = DataFrame(x=[1, 2, 3], y=['a', 'b', 'c'])
				for x in [12, 1.0, "", x -> x]
					# @test_throws MethodError add_label_column!(x, x)
					# @test_throws MethodError add_label_column!(x, y)
					# @test_throws MethodError add_label_column!(y, x)
				end
			end
		end

		@testset "Table inputs" verbose = false begin
		end
		@testset "Default options" verbose = false begin

			# DataFrame definitions
			long = DataFrame(
				name=["aaa", "bbb", "aaa", "ccc", "ccc", "aaa", "aaa", "ccc", "eee"],
				val=['x', 'w', 'w', 'y', 'z', 'q', 'y', 'a', 'w'],
			)
			short = pivot(long)
			X = DataFrame(name=["bbb", "ccc", "fff"], r=["BBB", "CCC", "FFF"])
			results = DataFrame(
				name=["aaa", "bbb", "ccc", "eee"],
				x=[true, false, false, false],
				w=[true, true, false, true],
				y=[true, false, true, false],
				z=[false, false, true, false],
				q=[true, false, false, false],
				a=[false, false, true, false],
				r=[false, true, true, false],
			)
			new = deepcopy(short)

			new = deepcopy(short)
			add_label_column!(new, X, :r)
			@test new == results

			new = deepcopy(short)
			add_label_column!(new, X, "r")
			@test new == results
		end

		@testset "Simple examples" verbose = false begin

			# DataFrame definitions
			long = DataFrame(;
				name=["aaa", "bbb", "aaa", "ccc", "ccc", "aaa", "aaa", "ccc", "eee"],
				val=['x', 'w', 'w', 'y', 'z', 'q', 'y', 'a', 'w'],
			)
			short = pivot(long)
			X = DataFrame(; name=["bbb", "ccc", "fff"], r=["BBB", "CCC", "FFF"])
			results = DataFrame(;
				name=["aaa", "bbb", "ccc", "eee"],
				x=[true, false, false, false],
				w=[true, true, false, true],
				y=[true, false, true, false],
				z=[false, false, true, false],
				q=[true, false, false, false],
				a=[false, false, true, false],
				val=[false, true, true, false],
			)
			new = deepcopy(short)

			new = deepcopy(short)
			add_label_column!(new, X, :val)
			@test new == results
		end
	end

	@testset "set_label_column!()" verbose = false begin
		@testset "Intended exceptions" verbose = false begin
			@testset "ArgumentError" verbose = false begin

				# DataFrame definitions
				long = DataFrame(
					name=["aaa", "bbb", "aaa", "ccc", "ccc", "aaa", "aaa", "ccc", "eee"],
					val=['x', 'w', 'w', 'y', 'z', 'q', 'y', 'a', 'w'],
				)
				short = pivot(long)
				X = DataFrame(; name=["bbb", "ccc", "fff"], r=["BBB", "CCC", "FFF"])
				results = DataFrame(;
					name=["aaa", "bbb", "ccc", "eee"],
					x=[true, false, false, false],
					w=[true, true, false, true],
					y=[true, false, true, false],
					z=[false, false, true, false],
					q=[true, false, false, false],
					a=[false, false, true, false],
					LABEL=[false, true, true, false],
				)
				new = deepcopy(short)
				# @test_throws UndefVarError set_label_column!(new, X, :NONEXISTENT)
			end
			@testset "DomainError" verbose = false begin
				@test_throws DomainError set_label_column!(DataFrame(), :NONEXISTENT)
				@test_throws DomainError set_label_column!(DataFrame(; x=[]), :NONEXISTENT)
				@test_throws DomainError set_label_column!(DataFrame(; x=[], y=[]), :NONEXISTENT)
			end
			@testset "MethodError" verbose = false begin
				y = DataFrame(x=[1, 2, 3], y=['a', 'b', 'c'])
				for x in [12, 1.0, "", x -> x]
					# @test_throws MethodError set_label_column!(x, x)
					# @test_throws MethodError set_label_column!(x, y)
					# @test_throws MethodError set_label_column!(y, x)
				end
			end
		end


@testset "Functionality" verbose = false begin
	X = DataFrame(name=["Cookie Monster", "Elmo", "Oscar", "Grover"],
		lovable = [true, true, false, true],
		furry = [true, true, true, true],
		old = [false, false, true, true]
		);
	set_label_column!(X,:lovable)
	#@test typeof(X.lovable[1]) == CategoricalArrays.CategoricalValue{Bool, UInt32}
	@test true

end	



	end




























	@testset "subsetMD()" verbose = false begin
		@testset "Intended exceptions" verbose = false begin
			@testset "ArgumentError" verbose = false begin
			end
			@testset "DomainError" verbose = false begin
			end
			@testset "MethodError" verbose = false begin
			end
		end
		@testset "Simple examples" verbose = false begin

				X = DataFrame(;
					name=["aaa", "bbb", "ccc", "eee"],
					x=[true, false, false, false],
					w=[true, true, false, true],
					y=[true, false, true, false],
					z=[false, false, true, false],
					q=[true, false, false, false],
					a=[false, false, true, false],
					LABEL=[false, true, true, false],
				)

				Y = DataFrame(
					name=["aaa", "ccc"],
					d =[1, 2],
				)
				Z = subsetMD(X,Y,:name,:name)

				@test Z == DataFrame(
					name=["aaa", "ccc", ],
					x=[true, false, ],
					w=[true, false, ],
					y=[true, true, ],
					z=[false, true, ],
					q=[true, false, ],
					a=[false, true, ],
					LABEL=[false, true, ],
				)


		end
		@testset "Default options" verbose = false begin

				X = DataFrame(;
					name=["aaa", "bbb", "ccc", "eee"],
					x=[true, false, false, false],
					w=[true, true, false, true],
					y=[true, false, true, false],
					z=[false, false, true, false],
					q=[true, false, false, false],
					a=[false, false, true, false],
					LABEL=[false, true, true, false],
				)

				Y = DataFrame(
					name=["aaa", "ccc"],
					d =[1, 2],
				)


				Z = subsetMD(X,Y, "name")

				@test Z == DataFrame(
					name=["aaa", "ccc", ],
					x=[true, false, ],
					w=[true, false, ],
					y=[true, true, ],
					z=[false, true, ],
					q=[true, false, ],
					a=[false, true, ],
					LABEL=[false, true, ],
				)


				Z = subsetMD(X,Y, :name)

				@test Z == DataFrame(
					name=["aaa", "ccc", ],
					x=[true, false, ],
					w=[true, false, ],
					y=[true, true, ],
					z=[false, true, ],
					q=[true, false, ],
					a=[false, true, ],
					LABEL=[false, true, ],
				)

				Z = subsetMD(X,Y)

				@test Z == DataFrame(
					name=["aaa", "ccc", ],
					x=[true, false, ],
					w=[true, false, ],
					y=[true, true, ],
					z=[false, true, ],
					q=[true, false, ],
					a=[false, true, ],
					LABEL=[false, true, ],
				)

		end
	end


	@testset "top_n_values()" verbose = false begin

df = DataFrame(name=["Cookie Monster", "Elmo", "Oscar", "Grover", "Big Bird", "Ernie", "Bert", "Rosita"],
                      fur_color=["blue", "red", "green", "blue", "yellow", "orange", "yellow", "blue"]);
@test top_n_values(df, :fur_color, 4) == DataFrame(AbstractVector[["blue", "yellow", "red", "green"], [3, 2, 1, 1]], Index(Dict(:nrow => 2, :fur_color => 1), [:fur_color, :nrow]))


	end


end

