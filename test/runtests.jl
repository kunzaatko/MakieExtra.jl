using TestItems
using TestItemRunner
@run_package_tests

@testitem "scales, ticks" begin
    fig = Figure(size=(1200, 300))
    xs = range(-10, 10, length=1000)
    
    series(fig[1,1], [
        (xs, mul .* xs)
        for mul in [1, 3, 10, 100]
    ], axis=(yscale=SymLog(1),))
    
    series(fig[1,2], [
        (xs, mul .* xs)
        for mul in [1, 3, 10, 100]
    ], axis=(yscale=SymLog(1, vmin=0, vmax=10),))
    
    series(fig[1,3], [
        (xs, mul .* xs)
        for mul in [1, 3, 10, 100]
    ], axis=(yscale=SymLog(1, vmin=-10, vmax=0),))
    
    series(fig[1,4], [
        (xs, mul .* xs)
        for mul in [1, 3, 10, 100]
    ], axis=(yscale=AsinhScale(1),))
    
    ax, _ = lines(fig[1,5], xs, xs, axis=(xscale=SymLog(1), yscale=AsinhScale(1), xtickformat=EngTicks(), ytickformat=EngTicks(:symbol)))
    lines!(ax, [Point(0, 0), Point(1, 1)], color=:black, linestyle=:dash, space=:relative)

    unityval =  1.1111111111111112
    @test SymLog(1)(0) == 0
    @test SymLog(1)(0.5) ≈ unityval/2
    @test SymLog(1)(1) ≈ unityval
    @test SymLog(1)(-1) ≈ -unityval
    @test SymLog(1)(10) ≈ 1 + unityval
    @test SymLog(1)(-10) ≈ -(1 + unityval)
    @test SymLog(1)(100) ≈ 2 + unityval

    @test SymLog(10)(0) == 0
    @test SymLog(10)(0.5) ≈ unityval/2
    @test SymLog(10)(1) ≈ unityval
    @test SymLog(10)(5) ≈ 5*unityval
    @test SymLog(10)(10) ≈ 10*unityval
    @test SymLog(10)(100) ≈ 10 + 10*unityval

    @test SymLog(1, linscale=2)(0) == 0
    @test SymLog(1, linscale=2)(0.5) ≈ unityval
    @test SymLog(1, linscale=2)(1) ≈ 2*unityval
    @test SymLog(1, linscale=2)(10) ≈ 1 + 2*unityval
    @test SymLog(1, linscale=2)(100) ≈ 2 + 2*unityval

    # smoke tests to probee the actual inverse:
    Makie.ReversibleScale(SymLog(1))
    Makie.ReversibleScale(AsinhScale(1))

    bmt = BaseMulTicks([1,2,5])
    @test Makie.get_tickvalues(bmt, identity, 0.25, 100) == [0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0]
    @test Makie.get_tickvalues(bmt, identity, 3, 100) == [5.0, 10.0, 20.0, 50.0, 100.0]
    @test Makie.get_tickvalues(bmt, log10, 3, 100) == [5.0, 10.0, 20.0, 50.0, 100.0]
    @test Makie.get_tickvalues(bmt, SymLog(1), 0, 100) == [0, 0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0]
    @test Makie.get_tickvalues(bmt, SymLog(1), -10, 100) == [-10.0, -5.0, -2.0, -1.0, -0.5, 0.0, 0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0]
    @test Makie.get_tickvalues(bmt, SymLog(1), 3, 100) == [5.0, 10.0, 20.0, 50.0, 100.0]
    @test Makie.get_tickvalues(bmt, SymLog(1), 0, 1) == [0, 0.5, 1.0]
    @test Makie.get_tickvalues(bmt, SymLog(1), 0, 0.2) == [0, 0.1, 0.2]

    @test Makie.get_minor_tickvalues(bmt, identity, nothing, 3, 100) == Makie.get_tickvalues(bmt, identity, 3, 100)
    @test Makie.get_minor_tickvalues(bmt, SymLog(1), nothing, -3, 100) == [-2.0, -1.0, -0.5, -0.2, -0.1, 0.0, 0.1, 0.2, 0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0]
    @test Makie.get_minor_tickvalues(bmt, SymLog(1), nothing, 0, 1) == [0, 0.1, 0.2, 0.5, 1.0]
    @test Makie.get_minor_tickvalues(bmt, SymLog(1), nothing, 0, 0.2) == [0, 0.1, 0.2]
end

@testitem "scalebar" begin
    using MakieExtra.Unitful

    X = rand(100, 100)
    
	heatmap(X, axis=(aspect=DataAspect(),), alpha=0.1)
	scalebar!(0.15u"m")
	scalebar!(0.15u"m", position=(0.8, 0.1), color=:black)
	scalebar!((0.15u"m", x -> "a $x b"), position=(0.8, 0.1), color=:black)
	scalebar!((0.15, x -> "a $x b"), color=:black)
    
	heatmap(0..1e-5, 0..1e-5, X, axis=(aspect=DataAspect(),), alpha=0.1)
	scalebar!(0.15u"m")  # XXX: should test that scalebar! call doesn't change limits
end

@testitem "zoom_lines" begin
    fig = Figure()
    ax1, _ = heatmap(fig[1,1], rand(10, 10))
    ax2, _ = heatmap(fig[1,2], rand(100, 100))
    ax3, _ = heatmap(fig[2,1], rand(100, 100))
    ax4, _ = heatmap(fig[2,2], rand(100, 100))
    axs = [ax1, ax2, ax3, ax4]
    for aa in Iterators.product(axs, axs)
        zoom_lines!(aa...)
    end
end

@testitem "axis-wide function" begin
    lines(sin)
    lines(sin; color=:black)
    scatter!(sin)
    scatter!(Observable(sin))
    scatter!(Observable(sin); markersize=2)
    band(x -> sin(x)..2sin(x); alpha=0.5)
end

@testitem "contourf fast" begin
    using AxisKeysExtra

    contourf_fast(rand(100, 100))
    contourf_fast(rand(100, 100), levels=[0, 0.3, 1])
    @test current_axis().xlabel[] == ""
    contourf_fast(KeyedArray(rand(100, 100), a=range(0, 1, length=100), b=range(-1, 2, length=100)))
    @test current_axis().xlabel[] == "a"
end

@testitem "to_xy_attrs" begin
    attrs = (a=1, b=123, xyz="4")
    @test to_x_attrs(attrs) == (xa=1, xb=123, xxyz="4")
    @test to_y_attrs(attrs) == (ya=1, yb=123, yxyz="4")
    @test to_xy_attrs(attrs) == (xa=1, xb=123, xxyz="4", ya=1, yb=123, yxyz="4")

    attrs = Attributes(attrs)
    @test NamedTuple(attrs).b[] == 123
    @test_broken (to_x_attrs(attrs); true)
end

@testitem "@define_plotfunc" begin
    struct MyType end
    struct MyTypeVec <: AbstractVector{Float64} end

    MakieExtra.@define_plotfunc scatter MyType
    MakieExtra.default_axis_attributes(::Type{Scatter}, ::MyType) = (;limits=((1, 2), (3, 4)))
    Makie.convert_arguments(::Type{Scatter}, ::MyType) = ([1, 2, 3], [1, 2, 3])

    MakieExtra.@define_plotfunc scatter MyTypeVec
    MakieExtra.default_axis_attributes(::Type{Scatter}, ::MyTypeVec) = (;limits=((1, 2), (3, 4)))
    Makie.expand_dimensions(::PointBased, ::MyTypeVec) = ([1, 2, 3], [1, 2, 3])

    MakieExtra.@define_plotfunc image MyType
    MakieExtra.default_axis_attributes(::Type{Image}, ::MyType) = (;limits=((1, 2), (3, 4)))
    Makie.convert_arguments(CT::Type{Image}, ::MyType) = ([1 2; 3 4],)

    MakieExtra.@define_plotfunc image MyTypeVec
    MakieExtra.default_axis_attributes(::Type{Image}, ::MyTypeVec) = (;limits=((1, 2), (3, 4)))
    Makie.convert_arguments(CT::Type{Image}, ::MyTypeVec) = ([1 2; 3 4],)

    @testset for plotf in (scatter, image),
                 T in (MyType, MyTypeVec)
        fig, ax, plt = plotf(T())
        @test ax.limits[] === ((1, 2), (3, 4))
        fig, ax, plt = plotf(Observable(T()))
        @test ax.limits[] === ((1, 2), (3, 4))
    end
end

@testitem "@define_plotfunc_conv" begin
    struct MyType end
    struct MyTypeVec <: AbstractVector{Float64} end

    MakieExtra.@define_plotfunc_conv scatter MyType
    MakieExtra.default_axis_attributes(::Type{Scatter}, ::MyType) = (;limits=((1, 2), (3, 4)))
    MakieExtra._convert_arguments_singlestep(::Type{Scatter}, ::MyType) = ([1, 2, 3],)

    MakieExtra.@define_plotfunc_conv scatter MyTypeVec
    MakieExtra.default_axis_attributes(::Type{Scatter}, ::MyTypeVec) = (;limits=((1, 2), (3, 4)))
    MakieExtra._convert_arguments_singlestep(::Type{Scatter}, ::MyTypeVec) = ([1, 2, 3],)

    MakieExtra.@define_plotfunc_conv image MyType
    MakieExtra.default_axis_attributes(::Type{Image}, ::MyType) = (;limits=((1, 2), (3, 4)))
    MakieExtra._convert_arguments_singlestep(::Type{Image}, ::MyType) = ([1 2; 3 4],)

    MakieExtra.@define_plotfunc_conv image MyTypeVec
    MakieExtra.default_axis_attributes(::Type{Image}, ::MyTypeVec) = (;limits=((1, 2), (3, 4)))
    MakieExtra._convert_arguments_singlestep(::Type{Image}, ::MyTypeVec) = ([1 2; 3 4],)

    @testset for plotf in (scatter, image),
                 T in (MyType, MyTypeVec)
        fig, ax, plt = plotf(T())
        @test ax.limits[] === ((1, 2), (3, 4))
        fig, ax, plt = plotf(Observable(T()))
        @test ax.limits[] === ((1, 2), (3, 4))
    end
    @testset for plotf in (scatter!, image!),
                 T in (MyType, MyTypeVec)
        plt = plotf(T())
        plt = plotf(Observable(T()))
    end
end

@testitem "_" begin
    import Aqua
    Aqua.test_all(MakieExtra; ambiguities=false, undefined_exports=false, piracies=false, persistent_tasks=false)

    import CompatHelperLocal as CHL
    CHL.@check()
end
