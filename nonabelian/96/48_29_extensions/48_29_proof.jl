using Hecke, ProgressMeter
import FileWatching

set_verbosity_level(:AbExt, 0)

function main()
  out = "48_29"
  DB1 = read("nonabelian/96/48_29_extensions/48_29.nfdb", Hecke.NFDB)
  @assert length(DB1) == 1
  Qx, x = QQ[:x]
  k, = number_field(x^2 - x + 92)
  @info "Subfield defined by x^2 - x + 92"
  fl, = is_subfield(k, Hecke.field(DB1[1]))
  @info "Is subfield of degree 96 field: $(fl)"
  @assert Hecke.relative_class_number(k) == 9
  @info "" !(Hecke.relative_class_number(k) in [1, 2, 4])
end

@time main()

