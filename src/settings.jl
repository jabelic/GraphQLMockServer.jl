using PackageCompiler
using Pkg
Pkg.add("PackageCompiler")
Pkg.add("Genie")
Pkg.add("TimerOutputs")
Pkg.add("Test")
Pkg.add("BenchmarkTools")
using PackageCompiler

PackageCompiler.create_sysimage([:Genie, :BenchmarkTools, :TimerOutputs, :Test]; sysimage_path="Sysimage.so")