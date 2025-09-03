using Oscar

d = 48
for j in 1:number_of_small_groups(48)
  @info d, j
  G = small_group(d, j)
  path = joinpath("nonabelian", "96", "$(d)_$(j)", "$(d)_$(j)")
  @assert isfile(path * ".result") && isfile(path * ".nfdb")
end

@info "All good for the first part of the 96 computation"
