  function mlib_AM, yrs, population
  
    yrs_uniq = yrs[UNIQ(yrs, SORT(yrs))]
    pop_max  = make_array(n_elements(yrs_uniq), type = SIZE(population, /TYPE ))
    
    for int_yr = 0, n_elements(yrs_uniq) - 1 do begin
      sub_tmp = where (yrs eq yrs_uniq[int_yr], count_tmp)
      pop_max [int_yr] = max(population[sub_tmp])
    endfor
    
    yrs = yrs_uniq
    population = pop_max
 
    return , 1

  end
