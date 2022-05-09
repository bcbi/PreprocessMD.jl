using PreprocessMD: PreprocessMD

using Aqua: Aqua
using DataFrames: DataFrames
using Test: Test
using Downloads: Downloads
using CSV: CSV

using PreprocessMD: add_label_column!
using PreprocessMD: pivot
using PreprocessMD: top_n_values

using DataFrames: DataFrame
using DataFrames: innerjoin
using DataFrames: summary
using Test: @testset
using Test: @test
using Test: @test_throws
using Test: @test_skip

@testset "PreprocessMD" begin
    @testset "File IO" begin
        PERSON = DataFrame(
            CSV.File.(
                Downloads.download(
                    "https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv/person.csv",
                )
            ),
        )
        DRUG = DataFrame(
            CSV.File.(
                Downloads.download(
                    "https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv/drug_exposure.csv",
                )
            ),
        )
        CONDITION = DataFrame(
            CSV.File.(
                Downloads.download(
                    "https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv/condition_occurrence.csv",
                )
            ),
        )

        @test summary(PERSON) == "100×18 DataFrame"
        @test names(PERSON) == [
            "person_id",
            "gender_concept_id",
            "year_of_birth",
            "month_of_birth",
            "day_of_birth",
            "birth_datetime",
            "race_concept_id",
            "ethnicity_concept_id",
            "location_id",
            "provider_id",
            "care_site_id",
            "person_source_value",
            "gender_source_value",
            "gender_source_concept_id",
            "race_source_value",
            "race_source_concept_id",
            "ethnicity_source_value",
            "ethnicity_source_concept_id",
        ]

        @test summary(DRUG) == "18229×23 DataFrame"
        @test summary(CONDITION) == "16441×16 DataFrame"
    end

    @testset "add_label_column!()" begin
        @testset "Intended exceptions" begin
            @testset "DomainError" begin
                @test_throws DomainError add_label_column!(DataFrame(), DataFrame())
                @test_throws DomainError add_label_column!(DataFrame(), DataFrame(; x=[]))
                @test_throws DomainError add_label_column!(DataFrame(; x=[]), DataFrame())
                @test_throws DomainError add_label_column!(
                    DataFrame(; x=[]), DataFrame(; x=[])
                )
                @test_throws DomainError add_label_column!(
                    DataFrame(; x=[1, 2]), DataFrame(; x=[])
                )
                @test_throws DomainError add_label_column!(
                    DataFrame(; x=[]), DataFrame(; x=[1, 2])
                )
            end
            @testset "ArgumentError" begin

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
                    LABEL=[false, true, true, false],
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
                @test_throws ArgumentError add_label_column!(new, X, :NONEXISTENT)
            end
            @testset "MethodError" begin
                y = DataFrame(; x=[1, 2, 3], y=['a', 'b', 'c'])
                for x in [12, 1.0, "", x -> x]
                    @test_throws MethodError add_label_column!(x, x)
                    @test_throws MethodError add_label_column!(x, y)
                    @test_throws MethodError add_label_column!(y, x)
                end
            end
        end
        @testset "Default options" begin

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
                LABEL=[false, true, true, false],
            )
            new = deepcopy(short)

            add_label_column!(new, X, :name)
            @test new == results

            new = deepcopy(short)
            add_label_column!(new, X)
            @test new == results
        end

        @testset "Simple examples" begin

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
                LABEL=[false, true, true, false],
            )
            new = deepcopy(short)

            new = deepcopy(short)
            add_label_column!(new, X, :name, :LABEL)
            @test new == results
        end
    end
    @testset "pivot()" begin
        @testset "Intended exceptions" begin
            @testset "MethodError" begin
                for x in [12, 1.0, "", x -> x]
                    @test_throws MethodError pivot(x)
                end
            end

            @testset "DomainError" begin
                for x in [DataFrame(), DataFrame(; x=[0, 1, 2, 3])]
                    @test_throws DomainError pivot(x)
                end
            end
        end
        @testset "Simple examples" begin
            A = DataFrame(; a=[1, 2, 1], b=['x', 'y', 'y'])
            B = pivot(A, :a, :b)
            C = DataFrame(; a=[1, 2], x=[true, false], y=[true, true])
            @test B == C

            B = pivot(A, :a)
            @test B == C

            B = pivot(A)
            @test B == C

            B = pivot(A, "a", "b")
            @test B == C
        end
    end

    @testset "Full pipeline" begin
        CONDITION = DataFrame(
            CSV.File.(
                Downloads.download(
                    "https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv/condition_occurrence.csv",
                )
            ),
        )
        DRUG = DataFrame(
            CSV.File.(
                Downloads.download(
                    "https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv/drug_exposure.csv",
                )
            ),
        )

        p_CONDITION = pivot(CONDITION, :person_id, :condition_concept_id)
        p_DRUG = pivot(DRUG, :person_id, :drug_concept_id)

        p_AGGREGATE = innerjoin(p_CONDITION, p_DRUG; on=:person_id)

        DEATH = DataFrame(
            CSV.File.(
                Downloads.download(
                    "https://physionet.org/files/mimic-iv-demo-omop/0.9/1_omop_data_csv/death.csv",
                )
            ),
        )
        add_label_column!(p_AGGREGATE, DEATH, :person_id, :death)

        @test size(p_AGGREGATE) == (100, 1878)

	@testset "top_n_values()" begin
		display(top_n_values(CONDITION, :condition_concept_id, 6))
	end
    end

    @testset "Aqua.jl" begin
        # Aqua.test_all(PreprocessMD) # TODO: uncomment this line
        Aqua.test_all(PreprocessMD; ambiguities=false) # TODO: delete this line
    end
end
