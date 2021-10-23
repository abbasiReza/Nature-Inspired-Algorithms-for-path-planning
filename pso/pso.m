% clc;
% clear;
% close all;

%% Problem Definition

model=CreateModel();

CostFunction=@(x) MyCost(x,model);    % Cost Function

nVar=model.n;       % Number of Decision Variables
OBS=model.OBS;
VarSize=[1 nVar];   % Size of Decision Variables Matrix

VarMin.x=model.xmin;           % Lower Bound of Variables
VarMax.x=model.xmax;           % Upper Bound of Variables
VarMin.y=model.ymin;           % Lower Bound of Variables
VarMax.y=model.ymax;           % Upper Bound of Variables


%% PSO Parameters

MaxIt=300;          % Maximum Number of Iterations

nPop=100;           % Population Size (Swarm Size)

w=.9;                % Inertia Weight
wdamp=0.99;         % Inertia Weight Damping Ratio
c1=2;               % Personal Learning Coefficient
c2=2;               % Global Learning Coefficient

alpha=0.1;
VelMax.x=alpha*(VarMax.x-VarMin.x);    % Maximum Velocity
VelMin.x=-VelMax.x;                    % Minimum Velocity
VelMax.y=alpha*(VarMax.y-VarMin.y);    % Maximum Velocity
VelMin.y=-VelMax.y;                    % Minimum Velocity

%% Initialization

% Create Empty Particle Structure
empty_particle.Position=[];
empty_particle.Velocity=[];
empty_particle.Cost=[];
empty_particle.Sol=[];
empty_particle.Best.Position=[];
empty_particle.Best.Cost=[];
empty_particle.Best.Sol=[];

% Initialize Global Best
GlobalBest.Cost=inf;

% Create Particles Matrix
particle=repmat(empty_particle,nPop,1);

% Initialization Loop
for i=1:nPop
    
    % Initialize Position
    particle(i).Position=CreateRandomSolution(model);
    
    % Initialize Velocity
    particle(i).Velocity.x=zeros(VarSize);
    particle(i).Velocity.y=zeros(VarSize);
    
    % Evaluation
    [particle(i).Cost,particle(i).Sol]=CostFunction(particle(i).Position);
    
    % Update Personal Best
    particle(i).Best.Position = particle(i).Position;
    particle(i).Best.Cost=particle(i).Cost;
    particle(i).Best.Sol=particle(i).Sol;
    
    % Update Global Best
    if particle(i).Best.Cost<GlobalBest.Cost
        
        GlobalBest=particle(i).Best;
        
    end
    
end

% Array to Hold Best Cost Values at Each Iteration
BestCost=zeros(MaxIt,1);

%% PSO Main Loop

tic
for it=1:MaxIt
    
    for i=1:nPop
        
        % y Part
        
        % Update Velocity
        particle(i).Velocity.x = w*particle(i).Velocity.x ...
            + c1*rand(VarSize).*(particle(i).Best.Position.x-particle(i).Position.x) ...
            + c2*rand(VarSize).*(GlobalBest.Position.x-particle(i).Position.x);
        
        % Update Velocity Bounds
        particle(i).Velocity.x = max(particle(i).Velocity.x,VelMin.x);
        particle(i).Velocity.x = min(particle(i).Velocity.x,VelMax.x);
        
        % Update Position
        particle(i).Position.x = particle(i).Position.x + particle(i).Velocity.x;
        
        % Update Velocity
        particle(i).Velocity.y = w*particle(i).Velocity.y ...
            + c1*rand(VarSize).*(particle(i).Best.Position.y-particle(i).Position.y) ...
            + c2*rand(VarSize).*(GlobalBest.Position.y-particle(i).Position.y);
        
        % Update Velocity Bounds
        particle(i).Velocity.y = max(particle(i).Velocity.y,VelMin.y);
        particle(i).Velocity.y = min(particle(i).Velocity.y,VelMax.y);
        
        % Update Position
        particle(i).Position.y = particle(i).Position.y + particle(i).Velocity.y;
        
        % Evaluation
        [particle(i).Cost,particle(i).Sol]=CostFunction(particle(i).Position);
        
        % Update Personal Best
        if particle(i).Cost<particle(i).Best.Cost
            
            particle(i).Best.Position=particle(i).Position;
            particle(i).Best.Cost=particle(i).Cost;
            particle(i).Best.Sol=particle(i).Sol;
            
            % Update Global Best
            if particle(i).Best.Cost<GlobalBest.Cost
                GlobalBest=particle(i).Best;
            end
            
        end
        
        
    end
    
    % Update Best Cost Ever Found
    BestCost(it)=GlobalBest.Cost(OBS);
    
    % Show Iteration Information
    if GlobalBest.Sol.IsFeasible
        Flag='   No Collision';
    else
        Flag=[', Collision = ' num2str(GlobalBest.Sol.Violation)];
    end
    disp(['Iteration ' num2str(it)  ', Best Cost = ' num2str(BestCost(it)) Flag]);
    % Inertia Weight Damping
    w=w*wdamp;
 
    PlotSolution(GlobalBest,model); 
end
toc
 
%% Save Data
SolInfo=(GlobalBest);
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