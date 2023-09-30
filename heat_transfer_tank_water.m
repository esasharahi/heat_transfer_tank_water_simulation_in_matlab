%% esasharahi@gmail.com

clear;
clc;
%
% modeling
%
% geometry
H = 150; % height (cm)
dR = 1; % thickness (cm)
R1 = 25 / 2; % inner radius (cm)
R2 = R1 + dR; % outer radius (cm)

% height limitations for circular heater.
% a pair (z{n}, z{n + 1}) when n is odd, describes a circular heater. 
dz = 15; % heater height (cm)
z1 = 30;
z2 = z1 + dz;
z3 = z2 + 60;
z4 = z3 + dz;

% water 
Cp1 = 0.4150;
rho1 = 1; % density
k1 = 0.0014; % thermal conduction
% iron
Cp2 = 0.444; 
rho2 = 7.874; % density
k2 = 0.163; % thermal conduction

% heater power (J)
tdelta = 30;
hpw = 5000; % (w)
hp = hpw * Cp2 * tdelta; % inityial heat (j)

% time utils
dt = 100;
tfinal = 3000;

%
% solver unit
%

% model creation
model = createpde('thermal','transient');
gm = multicylinder([R1 R2],H,'Void',[false,false]);
model.Geometry = gm;
generateMesh(model);

% plots of faces and cells ...
figure;
pdegplot(model,'FaceLabels','on');
figure;
pdegplot(model,'CellLabels','on','FaceAlpha',0.5);

% apply thermal conditions
thermalProperties(model,'Cell',1,'ThermalConductivity',k1,'SpecificHeat',Cp1,'MassDensity',rho1);
thermalProperties(model,'Cell',2,'ThermalConductivity',k2,'SpecificHeat',Cp2,'MassDensity',rho2);
% thermal boundary conditions
TB0 = @(location,~) hp * ((z1 < location.z) | (location.z < z2) | (z3 < location.z) | (location.z < z4));
thermalBC(model,'Face',3,'Face',6,'HeatFlux',TB0);
% thermal initial conditions 
thermalIC(model,0);

% solve
t = 0:dt:tfinal;
Result = solve(model,t);
figure;
pdeplot3D(model,'ColorMapData',Result.Temperature(:,4));
