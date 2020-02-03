function XRecos = Data_Denormalize(Xnorm,MAX,MIN)
b = max(max(Xnorm,[],2));
a = min(min(Xnorm,[],2));
L = size(Xnorm,1);
% Xrecos = (Xnorm-a)*(max-min)/(b-a) + min
XRecos = zeros(L, size(Xnorm,2));
for i = 1:L
    XRecos(:,i) = ((Xnorm(:,i)-a).*(MAX(1,i)-MIN(1,i)))./(b-a) + MIN(1,i);
end

end