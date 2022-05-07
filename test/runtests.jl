
using DataFrames
using PreprocessMD
using Test
using Downloads
using CSV


@testset verbose = true "PreprocessMD" begin

	@testset verbose = true "Sanity check" begin
		@test true
		@test_throws UndefVarError NONEXISTENT_FUNCTION()
	end

	@testset verbose = true "File IO" begin

		try
			PERSON    = Downloads.download("https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv/person.csv")               |> CSV.File |> DataFrame 
			DRUG      = Downloads.download("https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv/drug_exposure.csv")        |> CSV.File |> DataFrame
			CONDITION = Downloads.download("https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv/condition_occurrence.csv") |> CSV.File |> DataFrame

			@test PERSON |> summary == "100×18 DataFrame"
			@test names(PERSON) == ["person_id", "gender_concept_id", "year_of_birth", "month_of_birth",
							"day_of_birth", "birth_datetime", "race_concept_id", "ethnicity_concept_id",
							"location_id", "provider_id", "care_site_id", "person_source_value", "gender_source_value",
							"gender_source_concept_id", "race_source_value", "race_source_concept_id",
							"ethnicity_source_value", "ethnicity_source_concept_id"
							]

			@test DRUG |> summary == "18229×23 DataFrame"
			@test CONDITION |> summary == "16441×16 DataFrame"

		catch
			@test_skip false	
		end
		
	end

	@testset verbose = true "add_label_column!()" begin
		@testset verbose = true "Intended exceptions" begin
			@testset "DomainError" begin
					@test_throws DomainError add_label_column!(
						DataFrame(),
						DataFrame()
					)
					@test_throws DomainError add_label_column!(
						DataFrame(),
						DataFrame(x = []),
					)
					@test_throws DomainError add_label_column!(
						DataFrame(x = []),
						DataFrame(),
					)
					@test_throws DomainError add_label_column!(
						DataFrame(x = []),
						DataFrame(x = []),
					)
					@test_throws DomainError add_label_column!(
						DataFrame(x = [1,2]),
						DataFrame(x = []),
					)
					@test_throws DomainError add_label_column!(
						DataFrame(x = []),
						DataFrame(x = [1,2]),
					)
			end
			@testset verbose = true "ArgumentError" begin

				# DataFrame definitions
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

#=
				new = deepcopy(short)
				@test_throws ArgumentError add_label_column!(
					new, X, :name, :name, :w
				)

				new = deepcopy(short)
				@test_throws ArgumentError add_label_column!(
					new, X, :name, :NONEXISTENT
				)
=#

				new = deepcopy(short)
				@test_throws ArgumentError add_label_column!(
					new, X, :NONEXISTENT
				)

			end
			@testset "MethodError" begin
				y=DataFrame(x=[1,2,3],y=['a','b','c'])
				for x in [12, 1.0, "", x -> x]
					@test_throws MethodError add_label_column!(x, x)
					@test_throws MethodError add_label_column!(x, y)
					@test_throws MethodError add_label_column!(y, x)
				end
			end
		end
		@testset verbose = true "Default options" begin

			# DataFrame definitions
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
			new = deepcopy(short)

			add_label_column!(new, X, :name,)
			@test new == results

			new = deepcopy(short)
			add_label_column!(new, X)
			@test new == results

		end

		@testset verbose = true "Simple examples" begin

			# DataFrame definitions
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
			new = deepcopy(short)

			new = deepcopy(short)
			add_label_column!(new, X, :name, :LABEL)
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

end

