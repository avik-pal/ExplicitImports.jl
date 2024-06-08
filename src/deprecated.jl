function stale_explicit_imports(mod::Module, file=pathof(mod); strict=true)
    check_file(file)
    @warn "[stale_explicit_imports] deprecated in favor of `improper_explicit_imports`" maxlog = 1
    submodules = find_submodules(mod, file)
    file_analysis = Dict{String,FileAnalysis}()
    fill_cache!(file_analysis, last.(submodules))
    return [submodule => stale_explicit_imports_nonrecursive(submodule, path;
                                                             file_analysis=file_analysis[path],
                                                             strict)
            for (submodule, path) in submodules]
end

function stale_explicit_imports_nonrecursive(mod::Module, file=pathof(mod);
                                             strict=true,
                                             # private undocumented kwarg for hoisting this analysis
                                             file_analysis=get_names_used(file))
    check_file(file)
    @warn "[stale_explicit_imports_nonrecursive] deprecated in favor of `improper_explicit_imports_nonrecursive`" maxlog = 1

    (; unnecessary_explicit_import, tainted) = filter_to_module(file_analysis, mod)
    tainted && strict && return nothing
    ret = [(; nt.name, nt.location) for nt in unnecessary_explicit_import]
    return unique!(nt -> nt.name, sort!(ret))
end

function print_stale_explicit_imports(mod::Module, file=pathof(mod); kw...)
    return print_stale_explicit_imports(stdout, mod, file; kw...)
end

function print_stale_explicit_imports(io::IO, mod::Module, file=pathof(mod); strict=true,
                                      show_locations=false)
    @warn "[print_stale_explicit_imports] deprecated in favor of `print_explicit_imports`" maxlog = 1

    check_file(file)
    for (i, (mod, stale_imports)) in enumerate(stale_explicit_imports(mod, file; strict))
        i == 1 || println(io)
        if isnothing(stale_imports)
            println(io,
                    "Module $mod could not be accurately analyzed, likely due to dynamic `include` statements. You can pass `strict=false` to attempt to get (possibly inaccurate) results anyway.")
        elseif isempty(stale_imports)
            println(io, "Module $mod has no stale explicit imports.")
        else
            println(io,
                    "Module $mod has stale explicit imports for these unused names:")
            for (; name, location) in stale_imports
                if show_locations
                    proof = " (imported at $(location))"
                else
                    proof = ""
                end
                println(io, "- $name", proof)
            end
        end
    end
end

function print_improper_qualified_accesses(mod::Module, file=pathof(mod))
    return print_improper_qualified_accesses(stdout, mod, file)
end

function print_improper_qualified_accesses(io::IO, mod::Module, file=pathof(mod);
                                           report_non_public=VERSION >= v"1.11-")
    @warn "[print_improper_qualified_accesses] deprecated in favor of `print_explicit_imports`" maxlog = 1
    print_explicit_imports(io, mod, file;
                           warn_improper_qualified_accesses=true,
                           warn_improper_explicit_imports=false,
                           warn_implicit_imports=false,
                           report_non_public)
    # We leave this so we can have non-trivial printout when running this function on ExplicitImports:
    ExplicitImports.parent
    return nothing
end
