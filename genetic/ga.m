clc;
clear;
close all;

%% Problem Definition

model=CreateModel();
% CostFunction=@(x) Sphere(x);     % Cost Function
CostFunction=@(x) MyCost(x,model);
% nVar=5;             % Number of Decision Variables
nVar=model.n;
OBS=model.OBS;
VarSize=[1 nVar];   % Decision Variables Matrix Size

% VarMin=-10;         % Lower Bound of Variables
% VarMax= 10;         % Upper Bound of Variables
VarMin.x=model.xmin;           % Lower Bound of Variables
VarMax.x=model.xmax;           % Upper Bound of Variables
VarMin.y=model.ymin;           % Lower Bound of Variables
VarMax.y=model.ymax;           % Upper Bound of Variables


%% GA Parameters

MaxIt=300;      % Maximum Number of Iterations

nPop=100;        % Population Size

pc=0.8;                 % Crossover Percentage
nc=2*round(pc*nPop/2);  % Number of Offsprings (Parnets)

pm=0.1;                 % Mutation Percentage
nm=round(pm*nPop);      % Number of Mutants

gamma=0.9;

mu=1;         % Mutation Rate

alpha=0.1;
VelMax.x=alpha*(VarMax.x-VarMin.x);    % Maximum Velocity
VelMin.x=-VelMax.x;                    % Minimum Velocity
VelMax.y=alpha*(VarMax.y-VarMin.y);    % Maximum Velocity
VelMin.y=-VelMax.y;                    % Minimum Velocity



ANSWER=questdlg('Choose selection method:','Genetic Algorith',...
    'Roulette Wheel','Tournament','Random','Roulette Wheel');

UseRouletteWheelSelection=strcmp(ANSWER,'Roulette Wheel');
UseTournamentSelection=strcmp(ANSWER,'Tournament');
UseRandomSelection=strcmp(ANSWER,'Random');

if UseRouletteWheelSelection
    beta=8;         % Selection Pressure
end

if UseTournamentSelection
    TournamentSize=3;   % Tournamnet Size
end

pause(0.1);

%% Initialization

% empty_individual.Position=[];
% empty_individual.Cost=[];
empty_individual.Position=[];
empty_individual.Velocity=[];
empty_individual.Cost=[];
empty_individual.Sol=[];
empty_individual.Best.Position=[];
empty_individual.Best.Cost=[];
empty_individual.Best.Sol=[];


pop=repmat(empty_individual,nPop,1);

for i=1:nPop
    
    % Initialize Position
%     pop(i).Position=unifrnd(VarMin,VarMax,VarSize);
    pop(i).Position=CreateRandomSolution(model);
    % Initialize Velocity
    pop(i).Velocity.x=zeros(VarSize);
    pop(i).Velocity.y=zeros(VarSize);
    % Evaluation
%     pop(i).Cost=CostFunction(pop(i).Position);
[pop(i).Cost,pop(i).Sol]=CostFunction(pop(i).Position);
    
end
 for i=1:nPop
    pop(i).Cost=mean([pop(i).Cost]);
 
 end
% Sort Population
Costs=[pop.Cost];
[Costs, SortOrder]=sort(Costs);
pop=pop(SortOrder);


% Store Best Solution
BestSol=pop(1);

% Array to Hold Best Cost Values
BestCost=zeros(MaxIt,1);

% Store Cost
WorstCost=mean([pop(end).Cost]);

% Array to Hold Number of Function Evaluations
nfe=zeros(MaxIt,1);


%% Main Loop

for it=1:MaxIt
    
    % Calculate Selection Probabilities
    if UseRouletteWheelSelection
        P=exp(-beta*Costs/WorstCost);
        P=P/sum(P);
    end
    
    % Crossover
    popc=repmat(empty_individual,nc/2,2);
    for k=1:nc/2
        
        % Select Parents Indices
        if UseRouletteWheelSelection
            i1=RouletteWheelSelection(P);
            i2=RouletteWheelSelection(P);
        end
        if UseTournamentSelection
            i1=TournamentSelection(pop,TournamentSize);
            i2=TournamentSelection(pop,TournamentSize);
        end
        if UseRandomSelection
            i1=randi([1 nPop]);
            i2=randi([1 nPop]);
        end

        % Select Parents
        p1=pop(i1);
        p2=pop(i2);
        
        % Apply Crossover
        [popc(k,1).Position popc(k,2).Position]=...
            Crossover(p1.Position,p2.Position,gamma,VarMin,VarMax);
        
        % Evaluate Offsprings
        [popc(k,1).Cost,popc(k,1).Sol]=CostFunction(popc(k,1).Position);
        
       [popc(k,2).Cost,popc(k,2).Sol]=CostFunction(popc(k,2).Position);
        
    end
    popc=popc(:);
    
    
    % Mutation
    popm=repmat(empty_individual,nm,1);
    for k=1:nm
        
        % Select Parent
        i=randi([1 nPop]);
        p=pop(i);
        
        % Apply Mutation
        popm(k).Position=Mutate(p.Position,mu,VarMin,VarMax);
        
        % Evaluate Mutant
        [popm(k).Cost,popm(k).Sol]=CostFunction(popm(k).Position);
        
        
    end
    
    % Create Merged Population
    for i=1:nPop
    pop(i).Cost=mean([pop(i).Cost]);
%     popc(i).Cost=mean([popc(i).Cost]);
%     popm(i).Cost=mean([popm(i).Cost]);
    end
 for(i=1:size(popc))
     popc(i).Cost=mean([popc(i).Cost]);
 end
  for(i=1:size(popm))
     popm(i).Cost=mean([popm(i).Cost]);
 end
    pop=[pop
         popc
         popm];
     
    % Sort Population
    Costs=[pop.Cost];
    [Costs, SortOrder]=sort(Costs);
    pop=pop(SortOrder);
    
    % Update Worst Cost
    WorstCost=max(WorstCost,mean([pop(end).Cost]));
    
    % Truncation
    pop=pop(1:nPop);
    Costs=Costs(1:nPop);
    
    % Store Best Solution Ever Found
    BestSol=pop(1);
    
    % Store Best Cost Ever Found
    BestCost(it)=mean([BestSol.Cost]);
    
    % Store NFE
%     nfe(it)=NFE;
    
    % Show Iteration Information
    disp(['Iteration ' num2str(it) ': NFE = ' num2str(nfe(it)) ', Best Cost = ' num2str(BestCost(it))]);
     PlotSolution(BestSol,model);
end



%% Save Data
SolInfo=(BestSol);
SolInfo.AllBests = BestCost;

nCol=0;
for i=1:OBS
    if SolInfo.Sol.Violation(i)>=0.001
        nCol=nCol+1;
    end
end
SolInfo.nCol=nCol;
%% Plot Solution
PlotSolution(SolInfo,model);
title PSO;
xlabel 'X[m]';
ylabel 'Y[m]';
figure;
semilogx(BestCost,'LineWidth',1.5);
