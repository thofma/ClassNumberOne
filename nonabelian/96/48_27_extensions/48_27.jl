using Hecke, ProgressMeter
import FileWatching

set_verbosity_level(:AbExt, 0)

function main()
  expo = 164
  d = 48
  j = 27
  out = "48_27"
  pref = out * ": "

  R = ArbField(1000)

  B = ZZ(10)^164

  first_layer_filename = joinpath(@__DIR__, "..", "$(d)_$(j)", "$(d)_$(j).nfdb")

  if isfile(joinpath(@__DIR__, out * ".nfdb")) || isfile(joinpath(@__DIR__, out* ".result"))
    error("output file already exists")
  end

  local DB1

  @info filesize(first_layer_filename)

  FileWatching.mkpidlock(first_layer_filename * ".pid") do
    @info pref * "File for first layer exists; loading ..."
    if filesize(first_layer_filename) == 0
      @info "File is empty!"
      DB1 = Hecke.NFDB(Hecke.NFDBRecord{1}[])
    else
      DB1 = read(first_layer_filename, Hecke.NFDB)
    end
  end

  current = AbsSimpleNumField[Hecke.field(_K; cached = false) for _K in DB1]
  res = Hecke.NFDBRecord{1}[]

  for (ii, K) in enumerate(current)
    @info pref * " base field no. $(ii)/$(length(current)), constructing abelian extensions"
    local l = abelian_normal_extensions(K, [2], B; only_complex = true)
    @info pref * " base field no. $(ii)/$(length(current)), checking fields: $(length(l))"
    for (j, L) in enumerate(l)
      #next!(p2)
      @info pref * " base field no. $(ii)/$(length(current)), $j/$(length(l)), compute absolute field"
      Labs, = absolute_simple_field(number_field(L; using_norm_relation = true); simplify = true)
      # @info pref * " base field no. $(ii)/$(length(current)), $j/$(length(l)), checking relative class number if subfields"
      # if Hecke.has_obviously_relative_class_number_not_one(Labs, true)[1]
      #   @info pref * " base field no. $(ii)/$(length(current)), $j/$(length(l)), found subfield with relative class number too small"
      #   continue
      # end
      # hm = Hecke.relative_class_number(Labs)
      # if hm > 1
      #   continue
      # end
      # h = order(Hecke.class_group(lll(maximal_order(Labs)))[1])
      r = Hecke._create_record(Labs)
      # r[:class_number] = h
      r[:discriminant] = discriminant(maximal_order(Labs))
      push!(res, r)
    end
  end
  nfdb = Hecke.NFDB(res)
  open(joinpath(@__DIR__, out * ".nfdb"), "w") do io
    Base.write(io, nfdb)
  end
  open(joinpath(@__DIR__, out* ".result"), "w") do io
    for K in nfdb
      println(io, collect(coefficients(defining_polynomial(Hecke.field(K; cached = false)))), ",", discriminant(K))
    end
  end
end

@time main()

