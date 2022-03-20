function [muComb,varComb]=stats_gaussian_combination(mus,vars)
%calc the mean and variance of the Gaussian distribution that results from combining multiple other Gaussian distributions

weights=(vars.^-1)./sum(vars.^-1);
muComb=sum(weights.*mus);
varComb=sum(vars.^-1).^-1;

%Note for 2 Gaussian cues, the above simplifies to:
%muComb=(mus(1)*vars(2)+mus(2)*vars(1))/(vars(1)+vars(2));
%varComb=(vars(1)*vars(2))/(vars(1)+vars(2));
