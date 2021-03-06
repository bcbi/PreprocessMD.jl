using PreprocessMD

using Aqua: Aqua
using CSV: File
using Downloads: download
#using Tables: table

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

using Suppressor: @suppress

using Test: @testset
using Test: @test
using Test: @test_throws
using Test: @test_skip

"""
	function MLDemo(df::AbstractDataFrame, output, RNG_VALUE)::Tuple{AbstractFloat, AbstractFloat}
Decision tree classifier on a DataFrame over a given output

# Arguments

- `df::AbstractDataFrame`: DataFrame containing feature and label data
- `output`: column containing label data
- `RNG_VALUE`: 

"""
function MLDemo(df::AbstractDataFrame, output, RNG_VALUE)::Tuple{AbstractFloat, AbstractFloat}
	y = df[:, output]
	X = select(df, Not([:person_id, output]))

	train, test = partition(eachindex(y), 0.8, shuffle = true, rng = RNG_VALUE)

	# Evaluate model
	Tree = @load DecisionTreeClassifier pkg=DecisionTree verbosity=0
	tree_model = Tree(max_depth = 3)
	evaluate(tree_model, X, y)

	# Return scores
	tree = machine(tree_model, X, y)
	fit!(tree, rows = train)
	yhat = predict(tree, X[test, :])
	acc = accuracy(mode.(yhat), y[test])
	f1_score = f1score(mode.(yhat), y[test])

	return acc, f1_score
end


@testset "PreprocessMD" verbose = false begin
	# All external file downloads

	url = "https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv"
	#DRUG = DataFrame(File.(download("$url/drug_exposure.csv")));
	#PERSON = DataFrame(File.(download("$url/person.csv")));
	CONDITION = DataFrame(File.(download("$url/condition_occurrence.csv")));
	#DEATH = DataFrame(File.(download("$url/death.csv")));

#=
	@testset "Medical codes" verbose = false begin
	x = filter(:ethnicity_concept_id => ==(38003563), PERSON) # Hispanic or Latino
	# 38003564 # Not Hispanic or Latino
	@test true
	end
=#


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

#=
# Removed for 3.0 compatability requirements
		@testset "Table inputs" verbose = false begin
			@testset "NonTable" verbose = false begin
			end
			@testset "Table" verbose = false begin
				mat = [1 4.0 "7"; 2 5.0 "8"; 3 6.0 "9"]
				mattbl = table(mat)

				pivot(mattbl)	
			
				@test true
			end
			
		end
=#

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
#=
# Removed for 3.0 compatability requirements
			@testset "NonTable" verbose = false begin

				@test_throws ArgumentError add_label_column!(12, 12, :NONEXISTENT)
			end
=#
#=
# Removed for 3.0 compatability requirements
			@testset "Table" verbose = false begin

				mat = [1 4.0 "7"; 2 5.0 "8"; 3 6.0 "9"]
				mattbl = table(mat)

					X = DataFrame(name=["bbb", "ccc"], r=["BBB", "CCC"], Column1=[1, 2])
			
					add_label_column!(X, mattbl, :Column2)
				#getcolumn(mattbl, :Column3) |> display
				@test true
			end
=#
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
				#@test_throws DomainError set_label_column!(DataFrame(; x=[1, 2]), :NONEXISTENT)
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

#=
# Removed for 3.0 compatability requirements
		@testset "Table inputs" verbose = false begin
			@testset "NonTable" verbose = false begin

				@test_throws ArgumentError set_label_column!(12, :NONEXISTENT)
			end
			@testset "Table" verbose = false begin

				mat = [1 4.0 "7"; 2 5.0 "8"; 3 6.0 "9"]
				mattbl = table(mat)

					X = DataFrame(name=["bbb", "ccc"], r=["BBB", "CCC"], Column1=[1, 2])
			
					set_label_column!(mattbl, :Column2)
				#getcolumn(mattbl, :Column3) |> display
				@test true
			end
		end
=#
#=
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
			set_label_column!(new, X, :r)
			@test new == results

			new = deepcopy(short)
			set_label_column!(new, X, "r")
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
			set_label_column!(new, X, :val)
			@test new == results
		end
=#
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

	###@testset "Full pipeline" verbose = false begin
#=
		p_CONDITION = pivot(CONDITION, :person_id, :condition_concept_id)
		p_DRUG = pivot(DRUG, :person_id, :drug_concept_id)

		p_AGGREGATE = innerjoin(p_CONDITION, p_DRUG; on=:person_id)

		add_label_column!(p_AGGREGATE, DEATH, :death)

		@test size(p_AGGREGATE) == (100, 1878)

		@suppress begin
			MLDemo(p_AGGREGATE, :death, 1234)
		end
=#

#=

		medical_codes = DataFrame(
			CODE = [840544004, 840539006],
			)
		#p_medical_codes = pivot(medical_codes)
		#medical_codes = DataFrame(
			#"840544004" = [],
			#"840539006" = [],
			#)
		#medical_codes = [840544004, 840539006]
		println(names(medical_codes))
		println(names(CONDITION))
		COVID = subsetMD(CONDITION, medical_codes, :CODE)
		add_label_column!(p_AGGREGATE, COVID, label)
		MLDemo(p_AGGREGATE, :label, 9999)
=#

	###end
	@testset "top_n_values()" verbose = false begin
		@test top_n_values(CONDITION, :condition_concept_id, 6) == DataFrame(
			AbstractVector[
				[4145513, 4064452, 4140598, 4092038, 4138456, 433753],
				[6531, 2405, 2302, 502, 390, 181],
			],
			Index(
				Dict(:condition_concept_id => 1, :nrow => 2),
				[:condition_concept_id, :nrow],
			),
		)
	end

	@testset "Aqua.jl" verbose = false begin
		Aqua.test_all(PreprocessMD; ambiguities=false)
	end

end

#=
@testset "Template" verbose = false begin
	@testset "generic_function()" verbose = false begin
		@testset "Intended exceptions" verbose = false begin
			@testset "ArgumentError" verbose = false begin
			end
			@testset "DomainError" verbose = false begin
			end
			@testset "MethodError" verbose = false begin
			end
		end
		@testset "Default options" verbose = false begin
		end
		@testset "Simple examples" verbose = false begin
		end
	end
end
=#
