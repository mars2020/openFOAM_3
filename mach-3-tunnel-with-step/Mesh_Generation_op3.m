%% Generates the mesh for OF3
clear all; close all; clc;

%   Length
L_1=input('Length 1: ');
L_2=input('Length 2: ');
H_1=input('Height 1: ');
H_2=input('Height 2: ');

%   Number of cells per block in each direction
a=input('Cells in x direction: ');
b=input('Cells in y direction: ');
c=input('Cells in z direction: ');

%   Grading in each direction
grad_x=input('Grading in x direction: ');
grad_y=input('Grading in y direction: ');
grad_z=input('Grading in z direction: ');

%   Assembly of cell and grading vector
cells = [a,b,c];
grading = [grad_x,grad_y,grad_z];

%   Z coordinates
z1 = -.05;
z2 = .05;
%% Format of BlockMeshDict

file = fopen('blockMeshDict','w');
fprintf(file,'FoamFile \n{\n\tversion  2.0;\n\tformat   ascii;\n\tclass    dictionary;\n\tobject   blockMeshDict;\n}\n');
fprintf(file,'\n//L_1 = %d\tL_2 = %d\tH_1 = %d\tH_2 = %d\n',L_1,L_2,H_1,H_2);
fprintf(file,'\n//cells (%d %d %d)\n',cells(1,:));
fprintf(file,'\n//grading (%d %d %d)\n',grading(1,:));
fprintf(file,'\nconvertToMeters 1.0;\n');

%% Creating Coordiantes
% Total of N Coordinates - Moves counter-clockwise
N = 16;
global_coord=zeros(N,4);

% Lower z 
for i = 1 : N / 2  
    global_coord(i,1) = i - 1;
    global_coord(i,4) = z1; 
end

% Upper z 
for i = N / 2 + 1 : N 
    global_coord(i,1) = i - 1;
    global_coord(i,4) = z2; 
end

% Setting x 
for i = 0 : 1 
    global_coord(i*8+1 ,2) = 0;
    global_coord(i*8+2,2) = L_1;
    global_coord(i*8+3,2) = 0;
    global_coord(i*8+4,2) = L_1;
    global_coord(i*8+5,2) = L_1 + L_2;
    global_coord(i*8+6,2) = 0;
    global_coord(i*8+7,2) = L_1;
    global_coord(i*8+8,2) = L_1 + L_2;
end

% Setting y 
for i = 0 : 1 
    global_coord(i*8+1,3) = 0;
    global_coord(i*8+2,3) = 0;
    global_coord(i*8+3,3) = H_1;
    global_coord(i*8+4,3) = H_1;
    global_coord(i*8+5,3) = H_1;
    global_coord(i*8+6,3) = H_1 + H_2;
    global_coord(i*8+7,3) = H_1 + H_2;
    global_coord(i*8+8,3) = H_1 + H_2;
end

%   Input vertices to blockmeshDict
fprintf(file,'\nvertices\n(\n');
for i=1:length(global_coord(:,1))
    fprintf(file,'\t(%f %f %f)\t//%d\n', global_coord(i,2:4),i-1);
end
fprintf(file,');\n');


Blocks = [0 1 3 2 8 9 11 10;      % 0
          2 3 6 5 10 11 14 13;     % 1
          3 4 7 6 11 12 15 14];   % 2
     
%   input blocks to file
fprintf(file,'\nblocks\n(\n');
for i=1:length(Blocks(:,1))
    fprintf(file,'\thex (%d %d %d %d %d %d %d %d)',Blocks(i,:));
    fprintf(file,'\t(%d %d %d)', cells(1,:));
    fprintf(file,'\tsimpleGrading (%d %d %d)', grading(1,:));
    fprintf(file,'\t//block %d\n',i-1);
end
fprintf(file,');\n');
    
% Create faces
fprintf(file,'\nboundary\n(\n\tinlet\n\t{\n\ttype patch;\n\tfaces\n\t(\n');

%   Inlet
Inlet = zeros(2,4);
Inlet(1,:) = [0 2 10 8];
Inlet(2,:) = [2 5 13 10]; 

for i=1:2
    fprintf(file,'\t\t(%d %d %d %d)\n',Inlet(i,:));
end
fprintf(file,'\t);\n\t}\n');

%   Outlet
fprintf(file,'\n\toutlet\n\t{\n\ttype patch;\n\tfaces\n\t(\n');
Outlet = [4 12 15 7];
fprintf(file,'\t\t(%d %d %d %d)\n',Outlet);

fprintf(file,'\t);\n\t}\n');


%   Top
fprintf(file,'\n\ttop\n\t{\n\ttype symmetryPlane;\n\tfaces\n\t(\n');
Top = zeros(2,4);
Top(1,:) = [5 13 14 6];
Top(2,:) = [6 14 15 7];
for i=1:2
    fprintf(file,'\t\t(%d %d %d %d)\n',Top(i,:));
end
fprintf(file,'\t);\n\t}\n');

%   Bottom
fprintf(file,'\n\tbottom\n\t{\n\ttype symmetryPlane;\n\tfaces\n\t(\n');
Bottom = zeros(1,4);
Bottom(1,:) = [0 8 9 1];
fprintf(file,'\t\t(%d %d %d %d)\n',Bottom);
fprintf(file,'\t);\n\t}\n');


%  Step 
fprintf(file,'\n\tstep\n\t{\n\ttype wall;\n\tfaces\n\t(\n');
Step = zeros(2,4); 
Step(1,:) = [1 3 11 9];
Step(2,:) = [3 11 12 4];
for i = 1 : 2 
    fprintf(file,'\t\t(%d %d %d %d)\n',Step(i,:));
end
fprintf(file,'\t);\n\t}\n');
fprintf(file,');');
fprintf(file,'\nmergePatchPairs\n(\n);');
fclose(file);
