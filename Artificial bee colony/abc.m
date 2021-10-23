% clc;
% clear;
% close all;

%% Problem Definition
% model=CreateModel();
CostFunction=@(x) MyCost(x,model);        % Cost Function
global OBS

nVar=model.n;                  % Number of Decision Variables

VarSize=[1 nVar];              % Variables Matrix Size
    
VarMin.x=model.xmin;           % Lower Bound of Variables
VarMax.x=model.xmax;           % Upper Bound of Variables
VarMin.y=model.ymin;           % Lower Bound of Variables
VarMax.y=model.ymax;           % Upper Bound of Variables

%% ABC Settings

MaxIt=300;                 % Maximum Number of Iterations

nPop=200;                  % Population Size (Colony Size)

nOnlooker=1*nPop;         % Number of Onlooker Bees

nScout=1*nPop;            % Number of Scout Bees

L=round(1*nVar*nPop);       % Abandonment Limit Parameter

a=1;                      % Acceleration Coefficient Upper Bound
% adamp=1.002;
%% Initialization

% Empty Bee Structure
empty_bee.Position=[];
empty_bee.Cost=[];
empty_bee.Sol=[];

% Initialize Population Array
pop=repmat(empty_bee,nPop,1);

% Initialize Best Solution Ever Found
BestSol.Cost=inf;

% Create Initial Population
for i=1:nPop
    pop(i).Position=CreateRandomSolution(model);
    [pop(i).Cost pop(i).Sol]=CostFunction(pop(i).Position);
    
    if pop(i).Cost<=BestSol.Cost
        BestSol=pop(i);
    end
end

% Abandonment Counter
C=zeros(nPop,1);

% Array to Hold Best Cost Values
BestCost=zeros(MaxIt,1);

%% ABC Main Loop
tic
for it=1:MaxIt
    
    % Recruited Bees
    for i=1:nPop
        
        % Choose k randomly, not equal to i
        K=[1:i-1 i+1:nPop];
        k=K(randi([1 numel(K)]));
        
        % Define Acceleration Coeff.
        phi.x=unifrnd(-a,+a);
        phi.y=unifrnd(-a,+a);


        % New Bee Position
        newbee.Position.x=pop(i).Position.x+phi.x.*(pop(i).Position.x-pop(k).Position.x);
        newbee.Position.y=pop(i).Position.y+phi.y.*(pop(i).Position.y-pop(k).Position.y);

        % Evaluation
        [newbee.Cost newbee.Sol]=CostFunction(newbee.Position);
      
        % Comparision
        if newbee.Cost<=pop(i).Cost
            pop(i)=newbee;
        else
            C(i)=C(i)+1;
        end
        
    end
    
    % Calculate Fitness Values and Selection Probabilities
    F=zeros(nPop,1);
    for i=1:nPop
        if pop(i).Cost>=0
            F(i)=1/(1+mean(pop(i).Cost));
        else
            F(i)=1+abs(mean(pop(i).Cost));
        end
    end
    P=F/sum(F);
    
    % Onlooker Bees
    for m=1:nOnlooker
        
        % Select Source Site
        i=RouletteWheelSelection(P);
        
        % Choose k randomly, not equal to i
        K=[1:i-1 i+1:nPop];
        k=K(randi([1 numel(K)]));
        
        % Define Acceleration Coeff.
        phi.x=unifrnd(-a,+a,VarSize);
        phi.y=unifrnd(-a,+a,VarSize);
        
        % New Bee Position
        newbee.Position.x=pop(i).Position.x+phi.x.*(pop(i).Position.x-pop(k).Position.x);
        newbee.Position.y=pop(i).Position.y+phi.y.*(pop(i).Position.y-pop(k).Position.y);
        
        % Evaluation
        newbee.Cost=CostFunction(newbee.Position);
        
        % Comparision
        if newbee.Cost<=pop(i).Cost
            pop(i)=newbee;
        else
            C(i)=C(i)+1;
        end
        
    end
    
    % Scout Bees
    for i=1:nScout
        if C(i)>=L
            pop(i).Position.y=unifrnd(VarMin.y,VarMax.y,VarSize);
            pop(i).Position.x=unifrnd(VarMin.x,VarMax.x,VarSize);
            pop(i).Cost=CostFunction(pop(i).Position);
            C(i)=0;
        end
    end
    
    % Update Best Solution Ever Found
    for i=1:nPop
        if pop(i).Cost<=BestSol.Cost
            BestSol=pop(i);
        end
    end
    
    % Store Best Cost Ever Found
    BestCost(it)=mean(BestSol.Cost);
    
    % Display Iteration Information
    if BestSol.Sol.IsFeasible
        Flag='    No Collision';
    else
        Flag=[',    Collision = ' num2str(BestSol.Sol.Violation)];
    end
    disp(['Iteration ' num2str(it) ,' Best Cost = ' num2str(BestCost(it)) Flag]);
% a=a*adamp;
PlotSolution(BestSol,model);
end
toc
ETA = toc;
    SolInfo=(BestSol);
    SolInfo.AllBests = BestCost;
% Counting Number of Collisions
        nCol=0;       
    for i=1:OBS
       if SolInfo.Sol.Violation(i)>=0.001
          nCol=nCol+1; 
       end
    end
    SolInfo.nCol=nCol;
 
% Results
    PlotSolution(SolInfo,model);
    title ABC
    xlabel 'X[m]';
    ylabel 'Y[m]';
 figure,
semilogx(BestCost,'LineWidth',1.5);