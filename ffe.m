%%%%%%%%%%
h=[0.5 -0.25 0.15625 -0.0625];
x=rand(40,1)*4-1
y=[];

 y = zeros(size(x));
%  Apply FIR filter
 for n = 1:numel(x)%%to sweep over 40 indices
     for k = 1:numel(h)
         if (n-k+1) > 0
             y(n) = y(n) + h(k) * x(n-k+1);
         end
     end
 end
