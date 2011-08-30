pro test 

x = fltarr(10)

x[0]= -0.369791670000000
x[1]=-0.781250000000000
x[2]=-0.729166670000000
x[3]=-0.406250000000000
x[4]=-0.0937500000000000
x[5]=0.0885416670000000
x[6]=0.380208330000000
x[7]=0.567708330000000
x[8]=0.536458330000000
x[9]=0.255208330000000

x = transpose (x)

y = fltarr(10)

y[0] =0.500000000000000
y[1] =0.135416670000000
y[2] =-0.276041670000000
y[3] =-0.395833330000000
y[4] =-0.453125000000000
y[5] =-0.244791670000000
y[6] =-0.0677083330000000
y[7] =0.250000000000000
y[8] =0.515625000000000
y[9] =0.703125000000000

y = transpose(y)

print, fit_ellipse (x,y)

plot, x, y 
end

function fit_ellipse,x,y
;x:x-coordinate sequence of the vertices 
;y:y-coordinate sequence of the vertices

num=n_elements(x)

;solve LS with constraint 
D1=[x^2,x*y,y^2]
D2=[x,y,replicate(1,1,num)]
S1=transpose(D1)##D1
S2=transpose(D1)##D2
S3=transpose(D2)##D2
T=-invert(S3)##transpose(S2)
M=S1+S2##T
M=[[0.5*M(*,2)],[-M(*,1)],[0.5*M(*,0)]]
evals=HQR(ELMHES(M), /DOUBLE) 
evecs=real_part(EIGENVEC(M,evals)) 
cond=4*evecs(0,*)*evecs(2,*)-evecs(1,*)^2
a1=evecs(*,where(cond>0))
a2=a1##transpose(T)

;for convenience of understanding, rename the parameters:
a=a1(0)
b=a1(1)
c=a1(2)
d=a2(0)
e=a2(1)
f=a2(2)

theta= 0.5*atan(b/(a-c));inclination angle theta
co=cos(theta)
si=sin(theta)

;rotation:
 a0 = a*co^2 +b*co*si + c*si^2   
 c0 = a*si^2 -b*co*si + c*co^2               
 d0 = d*co+e*si
 e0 = -d*si+e*co 
 f00 = f-d0^2/(4*a0)-e0^2/(4*c0)

;find center:
 x0=-d0/(2*a0)
 y0=-e0/(2*c0)
 
 para=replicate(0.0,5) 
 para(0)  =   co*x0-si*y0;x-coordinate of center 
 para(1)  =   si*x0+co*y0;y-coordinate of center
 para(2)  =   sqrt( -( f00/a0 ) );length of axis A
 para(3)  =   sqrt( -( f00/c0 ) );length of axis B
 para(4)  =   !RADEG*theta;inclination angle to x-axis in degree 

return,para
end

