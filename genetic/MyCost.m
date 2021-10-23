function [z,sol] = MyCost(sol1,model)

    sol=ParseSolution(sol1,model);     
    
    beta=100;                         % Penalty Coefficient
% disp(sol.Violation);
% disp(sol.L);
    z=sol.L*(1+beta*(sol.Violation+0.5*sol.Vio));   % Cost Function Definition
%     z=sum(temp)
end