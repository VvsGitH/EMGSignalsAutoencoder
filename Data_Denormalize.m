function XRecos = Data_Denormalize(Xnorm,a,b,MAX,MIN)
% Denormalizazzione PER RIGA!
L = size(Xnorm,1);
XRecos = zeros(L, size(Xnorm,2));
for i = 1:L
    % Xrecos = (Xnorm-a)*(max-min)/(b-a) + min
    XRecos(i,:) = ((Xnorm(i,:)-a).*(MAX(i,1)-MIN(i,1)))./(b-a) + MIN(i,1);
end

end