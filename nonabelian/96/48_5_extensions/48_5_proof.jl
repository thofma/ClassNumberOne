using Hecke, ProgressMeter
import FileWatching

set_verbosity_level(:AbExt, 0)

function main()
  out = "48_5"
  DB1 = read("nonabelian/96/48_5_extensions/48_5.nfdb", Hecke.NFDB)
  @assert length(DB1) == 1
  Qx, x = QQ[:x]
  k, = number_field(x^2 - x + 24)
  @info "Subfield defined by x^2 - x + 24"
  fl, = is_subfield(k, Hecke.field(DB1[1]))
  @info "Is subfield of degree 96 field: $(fl)"
  @assert Hecke.relative_class_number(k) == 8
  @info "" !(Hecke.relative_class_number(k) in [1, 2, 4])
end

@time main()

