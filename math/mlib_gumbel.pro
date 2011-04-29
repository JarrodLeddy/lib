  function mlib_Gumbel,population, alph = alph,sita =sita, samples = samples, rp = rp
  
    ; moment estimation on alpha and sita
    ; reference: ....
    if n_elements(population) gt 2 then begin
      alph = 1/(0.7797*STDDEV(population))
      sita = mean(population)-0.45005*STDDEV(population)
    endif else begin
      return, -1
    endelse
    
    if keyword_set(samples) and keyword_set(rp) then begin
      gumbel_cdf = exp(-exp(-alph*(samples - sita)))
      RP = 1/((1-gumbel_cdf))
    endif
    
    return,1
    
  end