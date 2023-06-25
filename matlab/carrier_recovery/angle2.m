function ph2 = angle2(x)

ph1 = angle(x);
ph2 = zeros(size(x));
b=ph1 >= 0;
w=find(b==1);
n=find(b==0);
ph2(w) = ph1(w);
ph2(n) = 2*pi + ph1(n);

end

