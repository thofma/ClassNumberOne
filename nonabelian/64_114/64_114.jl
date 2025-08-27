using Hecke, ProgressMeter
import FileWatching

set_verbosity_level(:AbExt, 0)

function discard(K)
  # test for subfields:
  # a CM subfield must have relative class number 1,2,4
  fl, _ = Hecke.is_cm_field(K)
  if !fl
    return false
  end
  hm = Hecke.relative_class_number(K)
  if hm == 3 || hm > 4
    return true
  end
  return false
end

function main()
  expo = 108
  elementary_divisors_chain = [[2, 2, 4], [2, 2]]
  galois_group_of_subfields = Tuple{ZZRingElem, ZZRingElem}[(16, 10), (64, 114)]
  GG = galois_group_of_subfields[end]
  d = 64
  dlength = 3
  out = "64_114"
  pref = out * ": "

  R = ArbField(1000)

  @assert prod(prod(x) for x in elementary_divisors_chain) == d
  @assert dlength - 1 == length(elementary_divisors_chain) == length(galois_group_of_subfields)

  first_layer = elementary_divisors_chain[1]

  bound = ZZ(10)^expo

  abs_bound_layer(i) = Hecke.upper_bound(ZZRingElem, root(R(bound), Int(divexact(d, prod(prod(elementary_divisors_chain[j]) for j in 1:i)))))

  first_layer_filename = joinpath(@__DIR__, "..", "..", "maxab", join(["$x" for x in first_layer], "_") * "_e_$(abs_bound_layer(1)).nfdb")

  if isfile(joinpath(@__DIR__, out * ".nfdb")) || isfile(joinpath(@__DIR__, out* ".result"))
    error("output file already exists")
  end

  local DB1

  B = abs_bound_layer(1)

  FileWatching.mkpidlock(first_layer_filename * ".pid") do
    if isfile(first_layer_filename)
      @info pref * "File for first layer exists $(first_layer), $(B); loading ..."
      DB1 = read(first_layer_filename, Hecke.NFDB)
    else
      @info pref * "File for first layer does not exist; computing $(first_layer)..."
      firstlayerdeg = prod(first_layer)
      rdeg = divexact(d, firstlayerdeg)
      @info pref * "Discriminant bound: $B"
      l = abelian_extensions(QQ, first_layer, B)
      res = eltype(Hecke.NFDB{1})[]
      @info pref * "Computing simplified defining polynomials for fields and sieving bad CM-fields"
      for (i, x) in enumerate(l)
        @info pref * "$(i)/$(length(l))"
        K, = absolute_simple_field(number_field(x); simplify = true)
        Ks, = simplify(K)
        dd = discriminant(maximal_order(Ks))
        if discard(Ks)
          continue
        end
        r = Hecke._create_record(Ks)
        r[:discriminant] = dd
        push!(res, r)
      end
      DB1 = Hecke.NFDB(res)
      title = "abelian_extension(QQ, $(first_layer), $(B)"
      Hecke.add_meta!(DB1, :title => title)
      open(first_layer_filename, "w") do io
        Base.write(io, DB1)
      end
    end
  end

  next = AbsSimpleNumField[Hecke.field(_K; cached = false) for _K in DB1]
  current = AbsSimpleNumField[]

  res = Hecke.NFDBRecord{1}[]

  for i in 2:length(elementary_divisors_chain)
    empty!(current)
    append!(current, next)
    empty!(next)
    # now the second layer
    #p1 = Progress(length(DB1), 0, "Constructing layer $i"; offset = 1)
    for (ii, K) in enumerate(current)
      #next!(p1)
      @info pref * "layer $i/$(dlength - 1), base field no. $(ii)/$(length(current)), constructing abelian extensions"
      local B = abs_bound_layer(i)
      local l = abelian_normal_extensions(K, elementary_divisors_chain[i], B; only_complex = i == dlength - 1)
      #p2 = Progress(length(l), 0, "Sieving extensions"; offset = 2)
      @info pref * "layer $i/$(dlength - 1), base field no. $(ii)/$(length(current)), checking fields: $(length(l))"
      for (j, L) in enumerate(l)
        #next!(p2)
        @info pref * "layer $i/$(dlength - 1), base field no. $(ii)/$(length(current)), $j/$(length(l))"
        Labs, = absolute_simple_field(number_field(L; using_norm_relation = true); simplify = true)
        if !is_normal(Labs)
          continue
        end
        G, = automorphism_group(Labs)
        idd, = Hecke.find_small_group(G)
        if idd != galois_group_of_subfields[i]
          continue
        end
        if i == dlength - 1 # last step
          if !Hecke.is_cm_field(Labs)[1]
            continue
          end
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
        else
          if discard(Labs)
            continue
          end
          push!(next, Labs)
        end
      end
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
end

@time main()

