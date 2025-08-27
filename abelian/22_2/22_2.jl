using Hecke, ProgressMeter
import FileWatching

set_verbosity_level(:AbExt, 0)

function main()
  elementary_divisors = [22]
  conductor_bound = 65689

  res = Hecke.NFDBRecord{1}[]
  pref = "$elementary_divisors: "
  out = join(elementary_divisors, "_") 

  @info pref * "constructing extensions"
  l = abelian_extensions(elementary_divisors, collect(1:conductor_bound))

  for (i, K) in enumerate(l)
    @info pref * "$i/$(length(l))"
    if signature(K)[1] != 0
      continue
    end
    L = number_field(K)
    Labs, = absolute_simple_field(L; simplify = true)
    if Hecke.has_obviously_relative_class_number_not_one(Labs, true)[1]
      continue
    end
    hm = Hecke.relative_class_number(Labs)
    if hm > 1
      continue
    end
    h = order(Hecke.class_group(lll(maximal_order(Labs)))[1])
    r = Hecke._create_record(Labs)
    r[:class_number] = h
    r[:discriminant] = discriminant(maximal_order(Labs))
    push!(res, r)
  end
  nfdb = Hecke.NFDB(res)
  open(joinpath(@__DIR__, out * ".nfdb"), "w") do io
    Base.write(io, nfdb)
  end
  open(joinpath(@__DIR__, out* ".result"), "w") do io
    for K in nfdb
      println(io, collect(coefficients(defining_polynomial(Hecke.field(K; cached = false)))), ",", discriminant(K), ",", Hecke.class_number(K))
    end
  end
end

@time main()

