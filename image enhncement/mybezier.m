function [cx cy] = mybezier( xpts, ypts,no)
%	Summary of this function goes here
%   mybezier is a function to compute  n-th order bezier curve specified by
%   number of points
%   xpts-array of x-coordinates of control points including start and end
%   ypts-array of y-coordinates of control points including start and end
%   no_pts-number of xy coordinate points
%%
    %Generation of Binomial dist probability @ pascal triangle according to
    %curve order
    no_pts = length(xpts);
    n_order=no_pts-1;
    binom_var = zeros(1,no_pts);
    for n=0:n_order
        binom_var(n+1) = factorial(n_order)/(factorial(n)*factorial(n_order-n));
    end
    
    %For Bernstein polynomials use
    descend = n_order:-1:0;
    ascend = 0:1:n_order;
    
    n = 1;
    t(1) = 0;
    res = 1/(no+eps);
    cx = double(zeros(1,no)); %initial uint8
    cy = double(zeros(1,no));
    
    while t(n) < (1-(res/2))
        for a = 1:no_pts
            cx(n) = cx(n) + (binom_var(a) * (1-t(n))^(descend(a)) * t(n)^(ascend(a)) * xpts(a));
            cy(n) = cy(n) + (binom_var(a) * (1-t(n))^(descend(a)) * t(n)^(ascend(a)) * ypts(a));
        end
        t(n+1) = t(n)+res;
        n = n+1;
        
      
    end
end

