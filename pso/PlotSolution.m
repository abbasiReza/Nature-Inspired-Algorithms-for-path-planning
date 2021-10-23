function PlotSolution(SolInfo,model)

%% Import Data
xs=model.xs;
ys=model.ys;
xt=model.xt;
yt=model.yt;
xc=model.xc;
yc=model.yc;
r=model.r;
OBS=model.OBS;
XS=SolInfo.Sol.XS;
YS=SolInfo.Sol.YS;
xx=SolInfo.Sol.xx;
yy=SolInfo.Sol.yy;

figure(21)
theta=linspace(0,2*pi,100);
for i=1:OBS
    fill(xc(i)+r(i)*cos(theta),yc(i)+r(i)*sin(theta),'k')
    hold on
end
hold on
plot(xx,yy,'r','linewidth',2);
plot(XS,YS,'ro');
plot(xs,ys,'ks','MarkerSize',12,'MarkerFaceColor','y');
plot(xt,yt,'ks','MarkerSize',12,'MarkerFaceColor','g');
hold off;

grid on;
axis equal;
end