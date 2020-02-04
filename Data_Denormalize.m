function XRecos = Data_Denormalize(Xnorm,a,b,MAX,MIN)

L = size(Xnorm,1);
XRecos = zeros(L, size(Xnorm,2));
for i = 1:L
    % Xrecos = (Xnorm-a)*(max-min)/(b-a) + min
    XRecos(:,i) = ((Xnorm(:,i)-a).*(MAX(1,i)-MIN(1,i)))./(b-a) + MIN(1,i);
end

end