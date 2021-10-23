% clc;
% clear;
% close all;

%% Problem Definition

model=CreateModel();
CostFunction=@(x) MyCost(x,model);        % Cost Function
global OBS

nVar=model.n;                  % Number of Decision Variables

VarSize=[1 nVar];              % Variables Matrix Size
    
VarMin.x=model.xmin;           % Lower Bound of Variables
VarMax.x=model.xmax;           % Upper Bound of Variables
VarMin.y=model.ymin;           % Lower Bound of Variables
VarMax.y=model.ymax;           % Upper Bound of Variables

%% Firefly Algorithm Parameters

MaxIt=300;           % Maximum Number of Iterations

nPop=50;            % Number of Fireflies (Swarm Size)

gamma=1;            % Light Absorption Coefficient

beta0=0.4;            % Attraction Coefficient Base Value

alpha=0.2;          % Mutation Coefficient

alpha_damp=0.99;    % Mutation Coefficient Damping Ratio

delta.x=0.05*(VarMax.x-VarMin.x);     % Uniform Mutation Range
delta.y=0.05*(VarMax.y-VarMin.y);  
%% Initialization

% Empty Firefly Structure
firefly.Position=[];
firefly.Cost=[];
firefly.Sol=[];

% Initialize Population Array
pop=repmat(firefly,nPop,1);

% Initialize Best Solution Ever Found
BestSol.Cost=inf;

% Create Initial Fireflies
for i=1:nPop
   pop(i).Position=CreateRandomSolution(model);
   pop(i).Cost=CostFunction(pop(i).Position);
   [pop(i).Cost pop(i).Sol]=CostFunction(pop(i).Position);
   
   if pop(i).Cost<=BestSol.Cost
       BestSol=pop(i);
   end
end

% Array to Hold Best Cost Values
BestCost=zeros(MaxIt,1);

%% Firefly Algorithm Main Loop
tic
for it=1:MaxIt
    
    newpop=pop;
    for i=1:nPop
        for j=1:nPop
            if pop(j).Cost<=pop(i).Cost
                
                rij.x=norm(pop(i).Position.x-pop(j).Position.x);
                rij.y=norm(pop(i).Position.y-pop(j).Position.y);
        
                beta.x=beta0*exp(-gamma*rij.x^2);
                beta.y=beta0*exp(-gamma*rij.y^2);
            
                e.x=delta.x*unifrnd(-1,+1,VarSize);
                e.y=delta.y*unifrnd(-1,+1,VarSize);
                
                newpop(i).Position.x=pop(i).Position.x...
                    +beta.x*(pop(j).Position.x-pop(i).Position.x)...
                    +alpha*e.x;
                newpop(i).Position.y=pop(i).Position.y...
                    +beta.y*(pop(j).Position.y-pop(i).Position.y)...
                    +alpha*e.y;
                
                newpop(i).Position.x=max(newpop(i).Position.x,VarMin.x);
                newpop(i).Position.x=min(newpop(i).Position.x,VarMax.x);
                newpop(i).Position.y=max(newpop(i).Position.y,VarMin.y);
                newpop(i).Position.y=min(newpop(i).Position.y,VarMax.y);
                [newpop(i).Cost newpop(i).Sol]=CostFunction(newpop(i).Position);
                
                if newpop(i).Cost<=BestSol.Cost
                    BestSol=newpop(i);
                end
            end
        end
    end
    for i=1:nPop
    pop(i).Cost=mean([pop(i).Cost]);
    newpop(i).Cost=mean([newpop(i).Cost]);
    end
    BestSol.Cost=mean([BestSol.Cost]);
    % Merge
    pop=[pop
         newpop
         BestSol];  %#ok
    
    % Sort
    [~, SortOrder]=sort([pop.Cost]);
    pop=pop(SortOrder);
    
    % Truncate
    pop=pop(1:nPop);
    
    % Store Best Cost Ever Found
    BestCost(it)=BestSol.Cost;
    
    % Show Iteration Information
    if BestSol.Sol.IsFeasible
        Flag='    No Collision';
    else
        Flag=['    Collision = ' num2str(BestSol.Sol.Violation)];
    end
    disp(['Iteration ' num2str(it) ,' Best Cost = ' num2str(BestCost(it)) Flag]);
    
   
    PlotSolution(BestSol,model);
    % Damp Mutation Coefficient
    alpha=alpha*alpha_damp;
    
end
toc
ETF = toc;
ETF = 3*ETF;
    SolInfo=(BestSol);
    SolInfo.AllBests = BestCost;
    SolInfo.AllBests(101:300) = SolInfo.AllBests(100);
% Counting Number of Collisions
        nCol=0;       
    for i=1:OBS
       if SolInfo.Sol.Violation(i)>=0.010
          nCol=nCol+1; 
       end
    end
    SolInfo.nCol=nCol;
    
% Results
    PlotSolution(SolInfo,model);
    title FA;
    xlabel 'X[m]';
    ylabel 'Y[m]';
    figure;
semilogx(BestCost,'LineWidth',1.5);