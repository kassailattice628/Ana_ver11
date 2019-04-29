function f = Select_vonMises(i)

if i == 1
    f = @(b, x) b(1) * exp(b(2) * cos(x - b(3))) + b(4);
    
elseif i == 2
    f = @(b, x) b(1) * exp(b(2) * cos(x - b(5))) .*...
                exp(b(3) * cos(2*x - 2*(b(5)+b(6)))) + b(4);
end
    

end