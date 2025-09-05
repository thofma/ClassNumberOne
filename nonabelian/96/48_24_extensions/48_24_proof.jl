using Hecke, ProgressMeter
import FileWatching

set_verbosity_level(:AbExt, 0)

function main()
  out = "48_24"
  DB1 = read("nonabelian/96/48_24_extensions/48_24.nfdb", Hecke.NFDB)
  @assert length(DB1) == 1
  Qx, x = QQ[:x]
  k, = number_field(x^8 - 3*x^7 + 8*x^6 - 71*x^5 + 275*x^4 - 466*x^3 + 648*x^2 - 608*x + 256)
  @info "Subfield defined by x^8 - 3*x^7 + 8*x^6 - 71*x^5 + 275*x^4 - 466*x^3 + 648*x^2 - 608*x + 256"
  fl, = is_subfield(k, Hecke.field(DB1[1]))
  @info "Is subfield of degree 96 field: $(fl)"
  @assert Hecke.relative_class_number(k) == 10
  @info "" !(Hecke.relative_class_number(k) in [1, 2, 4])
end

@time main()

