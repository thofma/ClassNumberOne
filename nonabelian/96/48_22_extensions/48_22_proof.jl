using Hecke, ProgressMeter
import FileWatching

set_verbosity_level(:AbExt, 0)

function main()
  out = "48_22"
  DB1 = read("nonabelian/96/48_22_extensions/48_22.nfdb", Hecke.NFDB)
  @assert length(DB1) == 1
  Qx, x = QQ[:x]
  k, = number_field(x^8 - 6*x^7 + 16*x^6 - 30*x^5 + 84*x^4 - 192*x^3 + 505*x^2 - 582*x + 604)
  @info "Subfield defined by x^8 - 6*x^7 + 16*x^6 - 30*x^5 + 84*x^4 - 192*x^3 + 505*x^2 - 582*x + 604"
  fl, = is_subfield(k, Hecke.field(DB1[1]))
  @info "Is subfield of degree 96 field: $(fl)"
  @assert Hecke.relative_class_number(k) == 8
  @info "" !(Hecke.relative_class_number(k) in [1, 2, 4])
end

@time main()

